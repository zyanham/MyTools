#!/usr/bin/env python3

import argparse
import json
import os
from pathlib import Path
from typing import List, Tuple

import cv2
import numpy as np
import onnxruntime as ort


MEAN = np.array([0.485, 0.456, 0.406], dtype=np.float32)
STD = np.array([0.229, 0.224, 0.225], dtype=np.float32)
CARVANA_SIZE = (959, 640)


def list_images(input_path: Path) -> List[Path]:
    if input_path.is_file():
        return [input_path]
    suffixes = {".jpg", ".jpeg", ".png", ".bmp"}
    return sorted(p for p in input_path.rglob("*") if p.is_file() and p.suffix.lower() in suffixes)


def preprocess(image: np.ndarray, width: int, height: int) -> Tuple[np.ndarray, Tuple[int, int]]:
    original_h, original_w = image.shape[:2]
    resized = cv2.resize(image, (width, height), interpolation=cv2.INTER_CUBIC)
    rgb = cv2.cvtColor(resized, cv2.COLOR_BGR2RGB).astype(np.float32) / 255.0
    rgb = (rgb - MEAN) / STD
    tensor = np.transpose(rgb, (2, 0, 1))[None].astype(np.float32)
    return tensor, (original_w, original_h)


def create_session(args) -> ort.InferenceSession:
    if args.device == "cpu":
        return ort.InferenceSession(args.model, providers=["CPUExecutionProvider"])
    provider_options = {
        "config_file": os.path.abspath(args.config),
        "cache_dir": os.path.abspath(args.cache_dir),
        "cache_key": args.cache_key,
        "target": "VAIML",
    }
    return ort.InferenceSession(
        args.model,
        providers=["VitisAIExecutionProvider"],
        provider_options=[provider_options],
    )


def colorize_mask(mask: np.ndarray) -> np.ndarray:
    colored = np.zeros((*mask.shape, 3), dtype=np.uint8)
    colored[mask == 1] = (0, 0, 255)
    return colored


def overlay_mask(image: np.ndarray, mask: np.ndarray) -> np.ndarray:
    color = colorize_mask(mask)
    return cv2.addWeighted(image, 0.6, color, 0.4, 0.0)


def main() -> None:
    parser = argparse.ArgumentParser(description="Carvana U-Net file-to-file segmentation for host CPU or VEK385 NPU.")
    parser.add_argument("--model", default="models/carvana_unet.onnx")
    parser.add_argument("--input", required=True, help="Input image file or directory.")
    parser.add_argument("--output_dir", default="results/file2file")
    parser.add_argument("--device", choices=["cpu", "npu"], default="cpu")
    parser.add_argument("--config", default="vitisai_config.json")
    parser.add_argument("--cache_dir", default="my_cache_dir")
    parser.add_argument("--cache_key", default="carvana_unet_fp32_bf16")
    parser.add_argument("--width", type=int, default=CARVANA_SIZE[0])
    parser.add_argument("--height", type=int, default=CARVANA_SIZE[1])
    args = parser.parse_args()

    input_path = Path(args.input)
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    images = list_images(input_path)
    if not images:
        raise FileNotFoundError(f"No input images found: {input_path}")

    session = create_session(args)
    input_name = session.get_inputs()[0].name
    all_results = []

    for image_path in images:
        image = cv2.imread(str(image_path), cv2.IMREAD_COLOR)
        if image is None:
            print(f"skip unreadable image: {image_path}")
            continue

        tensor, _original_size = preprocess(image, args.width, args.height)
        logits = session.run(None, {input_name: tensor})[0][0]
        pred = np.argmax(logits, axis=0).astype(np.uint8)
        pred_original = cv2.resize(pred, (image.shape[1], image.shape[0]), interpolation=cv2.INTER_NEAREST)

        logits_path = output_dir / f"{image_path.stem}_logits.npy"
        mask_path = output_dir / f"{image_path.stem}_mask.png"
        color_path = output_dir / f"{image_path.stem}_mask_color.png"
        overlay_path = output_dir / f"{image_path.stem}_overlay.png"

        np.save(logits_path, logits)
        cv2.imwrite(str(mask_path), pred_original * 255)
        cv2.imwrite(str(color_path), colorize_mask(pred_original))
        cv2.imwrite(str(overlay_path), overlay_mask(image, pred_original))

        result = {
            "input": str(image_path),
            "logits_npy": str(logits_path),
            "mask_png": str(mask_path),
            "mask_color_png": str(color_path),
            "overlay_png": str(overlay_path),
            "logits_shape": list(logits.shape),
            "car_pixel_ratio": float(np.mean(pred_original == 1)),
        }
        all_results.append(result)
        print(f"{image_path.name}: car ratio={result['car_pixel_ratio']:.4f} -> {overlay_path}")

    with open(output_dir / "segmentation_manifest.json", "w", encoding="utf-8") as f:
        json.dump(all_results, f, indent=2)
    print(f"wrote {output_dir / 'segmentation_manifest.json'}")


if __name__ == "__main__":
    main()
