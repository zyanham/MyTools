#!/usr/bin/env python3

import argparse
import json
import time
from pathlib import Path
from typing import List

import cv2
import numpy as np
import onnxruntime as ort

from npu_runtime_check import add_npu_runtime_args, make_vitisai_session


def list_images(input_path: Path) -> List[Path]:
    if input_path.is_file():
        return [input_path]
    suffixes = {".jpg", ".jpeg", ".png", ".bmp", ".tif", ".tiff"}
    return sorted(p for p in input_path.rglob("*") if p.is_file() and p.suffix.lower() in suffixes)


def create_session(args) -> ort.InferenceSession:
    if args.device == "cpu":
        return ort.InferenceSession(args.model, providers=["CPUExecutionProvider"])
    return make_vitisai_session(args.model, args.config, args.cache_dir, args.cache_key, args.strict_npu)


def prepare_lr(image: np.ndarray, width: int, height: int) -> np.ndarray:
    rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    lr = cv2.resize(rgb, (width, height), interpolation=cv2.INTER_AREA)
    tensor = np.transpose(lr.astype(np.float32), (2, 0, 1))[None, :, :, :]
    return tensor


def to_bgr_uint8(sr: np.ndarray) -> np.ndarray:
    sr = np.squeeze(sr)
    if sr.ndim != 3:
        raise ValueError(f"Unexpected RCAN output shape: {sr.shape}")
    sr = np.transpose(sr, (1, 2, 0))
    sr = np.clip(np.rint(sr), 0, 255).astype(np.uint8)
    return cv2.cvtColor(sr, cv2.COLOR_RGB2BGR)


def main() -> None:
    parser = argparse.ArgumentParser(description="RCAN file-to-file super-resolution for host CPU or VEK385 NPU.")
    parser.add_argument("--model", default="models/rcan_bix2_x2_128x128.onnx")
    parser.add_argument("--input", required=True, help="Input image file or directory.")
    parser.add_argument("--output_dir", default="results/file2file")
    parser.add_argument("--device", choices=["cpu", "npu"], default="cpu")
    parser.add_argument("--config", default="vitisai_config.json")
    parser.add_argument("--cache_dir", default="my_cache_dir")
    parser.add_argument("--cache_key", default="rcan_bix2_x2_128x128_fp32_bf16")
    add_npu_runtime_args(parser)
    parser.add_argument("--width", type=int, default=128)
    parser.add_argument("--height", type=int, default=128)
    parser.add_argument("--scale", type=int, default=2)
    args = parser.parse_args()

    input_path = Path(args.input)
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    images = list_images(input_path)
    if not images:
        raise FileNotFoundError(f"No input images found: {input_path}")

    total_start = time.perf_counter()
    session_create_start = time.perf_counter()
    session = create_session(args)
    session_create_time = time.perf_counter() - session_create_start
    input_name = session.get_inputs()[0].name
    results = []
    run_times = []

    for image_path in images:
        image = cv2.imread(str(image_path), cv2.IMREAD_COLOR)
        if image is None:
            print(f"skip unreadable image: {image_path}")
            continue

        lr_tensor = prepare_lr(image, args.width, args.height)
        run_start = time.perf_counter()
        sr = session.run(None, {input_name: lr_tensor})[0]
        run_times.append(time.perf_counter() - run_start)
        sr_bgr = to_bgr_uint8(sr)

        lr_bgr = cv2.cvtColor(np.transpose(lr_tensor[0], (1, 2, 0)).astype(np.uint8), cv2.COLOR_RGB2BGR)
        bicubic = cv2.resize(lr_bgr, (args.width * args.scale, args.height * args.scale), interpolation=cv2.INTER_CUBIC)

        lr_path = output_dir / f"{image_path.stem}_lr{image_path.suffix}"
        bicubic_path = output_dir / f"{image_path.stem}_bicubic_x{args.scale}{image_path.suffix}"
        sr_path = output_dir / f"{image_path.stem}_rcan_x{args.scale}{image_path.suffix}"
        npy_path = output_dir / f"{image_path.stem}_sr.npy"

        cv2.imwrite(str(lr_path), lr_bgr)
        cv2.imwrite(str(bicubic_path), bicubic)
        cv2.imwrite(str(sr_path), sr_bgr)
        np.save(npy_path, sr.astype(np.float32))

        result = {
            "input": str(image_path),
            "lr_image": str(lr_path),
            "bicubic_image": str(bicubic_path),
            "sr_image": str(sr_path),
            "sr_npy": str(npy_path),
            "lr_shape": [1, 3, args.height, args.width],
            "sr_shape": list(sr.shape),
            "sr_min": float(np.min(sr)),
            "sr_max": float(np.max(sr)),
            "sr_mean": float(np.mean(sr)),
        }
        results.append(result)
        print(f"{image_path.name}: SR {list(sr.shape)} -> {sr_path}")

    manifest = output_dir / "super_resolution_manifest.json"
    with open(manifest, "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2)
    print(f"wrote {manifest}")
    if run_times:
        inference_total = sum(run_times)
        end_to_end_total = time.perf_counter() - total_start
        print(
            "[PERF] "
            f"device={args.device} items={len(run_times)} "
            f"session_create_s={session_create_time:.6f} "
            f"inference_total_s={inference_total:.6f} "
            f"inference_avg_ms={(inference_total / len(run_times)) * 1000.0:.3f} "
            f"inference_fps={len(run_times) / inference_total if inference_total > 0 else 0.0:.3f} "
            f"end_to_end_total_s={end_to_end_total:.6f} "
            f"end_to_end_avg_ms={(end_to_end_total / len(run_times)) * 1000.0:.3f}"
        )


if __name__ == "__main__":
    main()
