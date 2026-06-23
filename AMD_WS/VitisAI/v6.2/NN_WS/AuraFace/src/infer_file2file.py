#!/usr/bin/env python3

import argparse
import json
import os
from pathlib import Path
from typing import List

import cv2
import numpy as np
import onnxruntime as ort


def list_images(input_path: Path) -> List[Path]:
    if input_path.is_file():
        return [input_path]
    suffixes = {".jpg", ".jpeg", ".png", ".bmp"}
    return sorted(p for p in input_path.rglob("*") if p.is_file() and p.suffix.lower() in suffixes)


def preprocess(image_path: Path, size: int, rgb: bool) -> np.ndarray:
    image = cv2.imread(str(image_path), cv2.IMREAD_COLOR)
    if image is None:
        raise ValueError(f"Failed to read image: {image_path}")
    image = cv2.resize(image, (size, size), interpolation=cv2.INTER_LINEAR)
    if rgb:
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    tensor = image.astype(np.float32)
    tensor = (tensor - 127.5) / 127.5
    tensor = np.transpose(tensor, (2, 0, 1))[None, :, :, :]
    return tensor


def l2_normalize(x: np.ndarray) -> np.ndarray:
    norm = np.linalg.norm(x, axis=1, keepdims=True)
    return x / np.maximum(norm, 1e-12)


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


def main() -> None:
    parser = argparse.ArgumentParser(description="AuraFace file-to-file embedding extraction.")
    parser.add_argument("--model", default="models/auraface.onnx")
    parser.add_argument("--input", required=True, help="Input image file or directory.")
    parser.add_argument("--output_dir", default="results/file2file")
    parser.add_argument("--device", choices=["cpu", "npu"], default="cpu")
    parser.add_argument("--config", default="vitisai_config.json")
    parser.add_argument("--cache_dir", default="my_cache_dir")
    parser.add_argument("--cache_key", default="auraface_fp32_bf16")
    parser.add_argument("--img_size", type=int, default=112)
    parser.add_argument("--rgb", action="store_true", help="Use RGB channel order instead of InsightFace-style BGR.")
    args = parser.parse_args()

    input_path = Path(args.input)
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    images = list_images(input_path)
    if not images:
        raise FileNotFoundError(f"No input images found: {input_path}")

    session = create_session(args)
    input_name = session.get_inputs()[0].name
    results = []

    for image_path in images:
        tensor = preprocess(image_path, args.img_size, args.rgb)
        embedding = session.run(None, {input_name: tensor})[0]
        embedding = l2_normalize(np.asarray(embedding, dtype=np.float32))

        npy_path = output_dir / f"{image_path.stem}_embedding.npy"
        json_path = output_dir / f"{image_path.stem}_embedding.json"
        np.save(npy_path, embedding)
        with open(json_path, "w", encoding="utf-8") as f:
            json.dump({
                "input": str(image_path),
                "embedding_shape": list(embedding.shape),
                "embedding_l2_norm": float(np.linalg.norm(embedding[0])),
                "embedding_preview": embedding[0, :8].astype(float).tolist(),
                "npy": str(npy_path),
            }, f, indent=2)

        results.append({
            "input": str(image_path),
            "npy": str(npy_path),
            "json": str(json_path),
            "embedding_shape": list(embedding.shape),
        })
        print(f"{image_path.name}: embedding {embedding.shape} -> {npy_path}")

    with open(output_dir / "embeddings_manifest.json", "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2)
    print(f"wrote {output_dir / 'embeddings_manifest.json'}")


if __name__ == "__main__":
    main()
