#!/usr/bin/env python3

import argparse
import os

import onnxruntime


def main() -> None:
    parser = argparse.ArgumentParser(description="Compile RCAN ONNX model for Vitis AI VAIML.")
    parser.add_argument("--model_path", default="models/rcan_bix2_x2_128x128.onnx")
    parser.add_argument("--cache_dir", default="my_cache_dir")
    parser.add_argument("--cache_key", default="rcan_bix2_x2_128x128_fp32_bf16")
    parser.add_argument("--config_file", default="vitisai_config.json")
    parser.add_argument("--enable_ai_analyzer", action="store_true")
    args = parser.parse_args()

    if not os.path.exists(args.model_path):
        raise FileNotFoundError(f"Model not found: {args.model_path}")
    if not os.path.exists(args.config_file):
        raise FileNotFoundError(f"Config not found: {args.config_file}")

    cache_dir = os.path.abspath(args.cache_dir)
    os.makedirs(cache_dir, exist_ok=True)
    print("=" * 70)
    print("RCAN VitisAI Model Compilation")
    print("=" * 70)
    print(f"Model path:   {os.path.abspath(args.model_path)}")
    print(f"Cache dir:    {cache_dir}")
    print(f"Cache key:    {args.cache_key}")
    print("=" * 70)

    provider_options = {
        "config_file": os.path.abspath(args.config_file),
        "cache_dir": cache_dir,
        "cache_key": args.cache_key,
        "ai_analyzer_visualization": args.enable_ai_analyzer,
        "ai_analyzer_profiling": args.enable_ai_analyzer,
        "target": "VAIML",
    }
    onnxruntime.InferenceSession(
        args.model_path,
        providers=["VitisAIExecutionProvider"],
        provider_options=[provider_options],
    )


if __name__ == "__main__":
    main()
