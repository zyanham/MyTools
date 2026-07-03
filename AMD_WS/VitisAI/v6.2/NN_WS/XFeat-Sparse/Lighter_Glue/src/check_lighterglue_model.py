#!/usr/bin/env python3

import argparse
import json
import os
import sys
import time
from pathlib import Path

import numpy as np
import onnxruntime as ort

from npu_runtime_check import add_npu_runtime_args, make_vitisai_session


def create_session(args) -> ort.InferenceSession:
    if args.device == "cpu":
        return ort.InferenceSession(args.model, providers=["CPUExecutionProvider"])
    return make_vitisai_session(args.model, args.config, args.cache_dir, args.cache_key, args.strict_npu)


def compare(name: str, actual: np.ndarray, expected: np.ndarray) -> dict:
    diff = np.abs(actual.astype(np.float32) - expected.astype(np.float32))
    return {
        "name": name,
        "shape": list(actual.shape),
        "expected_shape": list(expected.shape),
        "max_abs": float(diff.max()),
        "mean_abs": float(diff.mean()),
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Check LighterGlue ONNX model against captured npy vectors.")
    parser.add_argument("--model", default="models/lighterglue_model.onnx")
    parser.add_argument("--vectors_dir", default="../original/test_vectors")
    parser.add_argument("--device", choices=["cpu", "npu"], default="cpu")
    parser.add_argument("--config", default="vitisai_config.json")
    parser.add_argument("--cache_dir", default="my_cache_dir")
    parser.add_argument("--cache_key", default="lighterglue_model_fp32_bf16")
    add_npu_runtime_args(parser)
    parser.add_argument("--rtol", type=float, default=1e-3)
    parser.add_argument("--atol", type=float, default=1e-3)
    parser.add_argument("--report", default=None, help="Optional JSON report path.")
    args = parser.parse_args()

    vectors_dir = Path(args.vectors_dir)
    inputs = {
        "keypoints0": np.load(vectors_dir / "lighterglue_keypoints0.npy").astype(np.float32),
        "keypoints1": np.load(vectors_dir / "lighterglue_keypoints1.npy").astype(np.float32),
        "descriptors0": np.load(vectors_dir / "lighterglue_descriptors0.npy").astype(np.float32),
        "descriptors1": np.load(vectors_dir / "lighterglue_descriptors1.npy").astype(np.float32),
        "image_size0": np.load(vectors_dir / "lighterglue_image_size0.npy").astype(np.float32),
        "image_size1": np.load(vectors_dir / "lighterglue_image_size1.npy").astype(np.float32),
    }
    expected_all = {
        "log_assignment": np.load(vectors_dir / "lighterglue_log_assignment.npy"),
        "matches0": np.load(vectors_dir / "lighterglue_matches0.npy").astype(np.float32),
        "matches1": np.load(vectors_dir / "lighterglue_matches1.npy").astype(np.float32),
        "matching_scores0": np.load(vectors_dir / "lighterglue_matching_scores0.npy"),
        "matching_scores1": np.load(vectors_dir / "lighterglue_matching_scores1.npy"),
    }

    total_start = time.perf_counter()
    session_create_start = time.perf_counter()
    session = create_session(args)
    session_create_time = time.perf_counter() - session_create_start
    feed = {inp.name: inputs[inp.name] for inp in session.get_inputs()}
    run_start = time.perf_counter()
    outputs = session.run(None, feed)
    inference_time = time.perf_counter() - run_start
    end_to_end_time = time.perf_counter() - total_start
    names = [o.name for o in session.get_outputs()]
    actual = dict(zip(names, outputs))
    expected = {name: expected_all[name] for name in names}

    metrics = [compare(name, actual[name], expected[name]) for name in expected]
    ok = all(np.allclose(actual[name], expected[name], rtol=args.rtol, atol=args.atol) for name in expected)
    performance = {
        "items": 1,
        "session_create_s": session_create_time,
        "inference_total_s": inference_time,
        "inference_avg_ms": inference_time * 1000.0,
        "inference_fps": 1.0 / inference_time if inference_time > 0 else 0.0,
        "end_to_end_total_s": end_to_end_time,
        "end_to_end_avg_ms": end_to_end_time * 1000.0,
    }
    result = {"device": args.device, "ok": ok, "metrics": metrics, "performance": performance}
    print(json.dumps(result, indent=2))
    print(
        "[PERF] "
        f"device={args.device} items=1 "
        f"session_create_s={performance['session_create_s']:.6f} "
        f"inference_total_s={performance['inference_total_s']:.6f} "
        f"inference_avg_ms={performance['inference_avg_ms']:.3f} "
        f"inference_fps={performance['inference_fps']:.3f} "
        f"end_to_end_total_s={performance['end_to_end_total_s']:.6f} "
        f"end_to_end_avg_ms={performance['end_to_end_avg_ms']:.3f}"
    )
    if args.report:
        report = Path(args.report)
        report.parent.mkdir(parents=True, exist_ok=True)
        with open(report, "w", encoding="utf-8") as f:
            json.dump(result, f, indent=2)
    if not ok:
        raise SystemExit(1)
    if args.device == "npu":
        sys.stdout.flush()
        sys.stderr.flush()
        os._exit(0)


if __name__ == "__main__":
    main()
