#!/usr/bin/env python3

import json
import os
import re
from pathlib import Path
from typing import Any, Dict, List, Tuple

import onnxruntime as ort


TAG = "[NPU-RUNTIME-CHECK]"
PROVIDER = "VitisAIExecutionProvider"


def add_npu_runtime_args(parser) -> None:
    parser.add_argument(
        "--strict_npu",
        action="store_true",
        help="Fail before inference if Vitis AI EP/cache/AIE evidence is missing.",
    )


def _print(level: str, message: str) -> None:
    print(f"{TAG}[{level}] {message}", flush=True)


def _read_json(path: Path) -> Dict[str, Any]:
    try:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
        return data if isinstance(data, dict) else {}
    except Exception as exc:
        return {"_read_error": str(exc)}


def _parse_preliminary_summary(path: Path) -> Dict[str, Any]:
    if not path.is_file():
        return {}
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except Exception as exc:
        return {"read_error": str(exc)}

    patterns: List[Tuple[str, str, Any]] = [
        ("model_ops", r"Number of operators in the model:\s*([0-9]+)", int),
        ("model_gops", r"GOPs of the model:\s*([0-9.]+)", float),
        ("vaiml_supported_ops", r"Number of operators supported by VAIML:\s*([0-9]+)", int),
        ("vaiml_supported_ops_pct", r"Number of operators supported by VAIML:\s*[0-9]+\(([0-9.]+)%\)", float),
        ("vaiml_supported_gops", r"GOPs supported by VAIML:\s*([0-9.]+)", float),
        ("vaiml_supported_gops_pct", r"GOPs supported by VAIML:\s*[0-9.]+ \(([0-9.]+)%\)", float),
        ("vaiml_supported_subgraphs", r"Number of subgraphs supported by VAIML:\s*([0-9]+)", int),
    ]
    result: Dict[str, Any] = {"path": str(path)}
    for key, pattern, caster in patterns:
        match = re.search(pattern, text)
        if match:
            try:
                result[key] = caster(match.group(1))
            except ValueError:
                result[key] = match.group(1)
    return result


def _collect_cache_evidence(cache_root: Path) -> Dict[str, Any]:
    evidence: Dict[str, Any] = {
        "cache_root": str(cache_root),
        "cache_root_exists": cache_root.is_dir(),
    }
    if not cache_root.is_dir():
        return evidence

    summary = _parse_preliminary_summary(cache_root / "preliminary-vaiml-pass-summary.txt")
    if summary:
        evidence["preliminary_summary"] = summary

    important = [
        "subgraphs_cache.json",
        "preliminary-vaiml-pass-summary.txt",
        "vaiml_partition_fe.flexml",
        "vaiml_par_0",
    ]
    evidence["important_paths"] = {name: (cache_root / name).exists() for name in important}

    fail_safe = []
    for path in sorted(cache_root.rglob("fail_safe_summary.json")):
        data = _read_json(path)
        fail_safe.append({"path": str(path), "offload_map": data.get("offload_map"), "raw": data})
    evidence["fail_safe_summaries"] = fail_safe

    partitions = []
    for path in sorted(cache_root.rglob("partition-info.json")):
        data = _read_json(path)
        partitions.append({
            "path": str(path),
            "runner_type": data.get("runner_type"),
            "status": data.get("status"),
            "num_aie_partitions": data.get("num_aie_partitions"),
            "aie_partition_call_order_len": len(data.get("aie_partition_call_order", []) or []),
            "hardwarePlatformID": data.get("hardwarePlatformID"),
        })
    evidence["partition_infos"] = partitions
    return evidence


def _evaluate_preflight(evidence: Dict[str, Any]) -> Tuple[bool, List[str], List[str]]:
    errors: List[str] = []
    warnings: List[str] = []

    available = evidence.get("available_providers", [])
    if PROVIDER not in available:
        errors.append(f"{PROVIDER} is not in onnxruntime.get_available_providers().")

    if evidence.get("env", {}).get("XLNX_ENABLE_CACHE") == "0":
        errors.append("XLNX_ENABLE_CACHE=0 disables/reduces cache use and can force deployment-time compile.")

    cache = evidence.get("cache", {})
    if not cache.get("cache_root_exists"):
        errors.append("Compiled cache directory for cache_key was not found.")
    else:
        important = cache.get("important_paths", {})
        if not important.get("preliminary-vaiml-pass-summary.txt"):
            warnings.append("preliminary-vaiml-pass-summary.txt was not found in cache.")
        if not cache.get("fail_safe_summaries"):
            warnings.append("fail_safe_summary.json was not found in cache.")
        if not cache.get("partition_infos"):
            warnings.append("partition-info.json was not found in cache.")

    aie_values: List[float] = []
    cpu_values: List[float] = []
    for item in cache.get("fail_safe_summaries", []) or []:
        offload = item.get("offload_map") or {}
        if isinstance(offload, dict):
            if isinstance(offload.get("AIE"), (int, float)):
                aie_values.append(float(offload["AIE"]))
            if isinstance(offload.get("CPU"), (int, float)):
                cpu_values.append(float(offload["CPU"]))

    if aie_values:
        if max(aie_values) <= 0.0:
            errors.append("Compiled cache reports AIE offload as 0%.")
        elif max(cpu_values or [0.0]) > 0.0:
            warnings.append(f"Compiled cache is hybrid AIE/CPU. max AIE={max(aie_values):.3f}%, max CPU={max(cpu_values):.3f}%.")
    elif cache.get("cache_root_exists"):
        warnings.append("AIE offload percentage could not be read from fail_safe_summary.json.")

    return not errors, errors, warnings


def make_vitisai_session(model: str, config: str, cache_dir: str, cache_key: str, strict_npu: bool = False) -> ort.InferenceSession:
    provider_options = {
        "config_file": os.path.abspath(config),
        "cache_dir": os.path.abspath(cache_dir),
        "cache_key": cache_key,
        "target": "VAIML",
    }
    if os.environ.get("AI_ANALYZER", "0") == "1":
        provider_options["ai_analyzer_visualization"] = True
        provider_options["ai_analyzer_profiling"] = True
    cache_root = Path(provider_options["cache_dir"]) / cache_key
    evidence: Dict[str, Any] = {
        "model": os.path.abspath(model),
        "provider_options": provider_options,
        "onnxruntime_version": getattr(ort, "__version__", "unknown"),
        "available_providers": ort.get_available_providers(),
        "env": {
            "XLNX_ENABLE_CACHE": os.environ.get("XLNX_ENABLE_CACHE", "<unset>"),
            "XRT_AIARM": os.environ.get("XRT_AIARM", "<unset>"),
            "XRT_ELF_FLOW": os.environ.get("XRT_ELF_FLOW", "<unset>"),
            "AI_ANALYZER": os.environ.get("AI_ANALYZER", "<unset>"),
        },
        "cache": _collect_cache_evidence(cache_root),
    }

    _print("INFO", f"onnxruntime_version={evidence['onnxruntime_version']}")
    _print("INFO", f"available_providers={evidence['available_providers']}")
    _print("INFO", f"model={evidence['model']}")
    _print("INFO", f"config_file={provider_options['config_file']}")
    _print("INFO", f"cache_root={cache_root}")
    _print("INFO", f"cache_root_exists={evidence['cache']['cache_root_exists']}")
    _print("INFO", f"env={evidence['env']}")

    summary = evidence["cache"].get("preliminary_summary", {})
    if summary:
        _print(
            "INFO",
            "vaiml_summary="
            f"ops {summary.get('vaiml_supported_ops')}/{summary.get('model_ops')} "
            f"({summary.get('vaiml_supported_ops_pct')}%), "
            f"gops {summary.get('vaiml_supported_gops')}/{summary.get('model_gops')} "
            f"({summary.get('vaiml_supported_gops_pct')}%), "
            f"subgraphs {summary.get('vaiml_supported_subgraphs')}",
        )

    for item in evidence["cache"].get("fail_safe_summaries", []) or []:
        _print("INFO", f"fail_safe_summary={item['path']} offload_map={item.get('offload_map')}")
    for item in evidence["cache"].get("partition_infos", []) or []:
        _print(
            "INFO",
            f"partition_info={item['path']} runner_type={item.get('runner_type')} "
            f"status={item.get('status')} num_aie_partitions={item.get('num_aie_partitions')} "
            f"call_order_len={item.get('aie_partition_call_order_len')}",
        )

    ok, errors, warnings = _evaluate_preflight(evidence)
    for warning in warnings:
        _print("WARN", warning)
    for error in errors:
        _print("FAIL", error)
    if strict_npu and not ok:
        _print("FAIL", "strict_npu is enabled; aborting before inference.")
        print("NPU_RUNTIME_CHECK_JSON: " + json.dumps(evidence, sort_keys=True), flush=True)
        raise SystemExit(2)

    session = ort.InferenceSession(
        model,
        providers=[PROVIDER],
        provider_options=[provider_options],
    )
    evidence["session_providers"] = session.get_providers()
    try:
        evidence["session_provider_options"] = session.get_provider_options()
    except Exception as exc:
        evidence["session_provider_options_error"] = str(exc)

    if PROVIDER in evidence["session_providers"]:
        _print("OK", f"session_providers={evidence['session_providers']}")
    else:
        _print("FAIL", f"session_providers={evidence['session_providers']} does not include {PROVIDER}")
        if strict_npu:
            _print("FAIL", "strict_npu is enabled; aborting after session creation.")
            print("NPU_RUNTIME_CHECK_JSON: " + json.dumps(evidence, sort_keys=True), flush=True)
            raise SystemExit(2)

    if ok:
        _print("OK", "precompiled cache evidence indicates Vitis AI EP/AIE offload should be used.")
    else:
        _print("WARN", "NPU execution is not proven by this log; check for deployment-time compile errors or CPU fallback.")
    print("NPU_RUNTIME_CHECK_JSON: " + json.dumps(evidence, sort_keys=True), flush=True)
    return session
