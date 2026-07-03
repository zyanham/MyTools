#!/usr/bin/env python3

import argparse
import os

import onnxruntime


def main() -> None:
    parser = argparse.ArgumentParser(description="Compile YOLO-Pose ONNX model for Vitis AI VAIML.")
    parser.add_argument("--model_path", default="models/yolo_pose.onnx", help="Path to the ONNX model.")
    parser.add_argument("--cache_dir", default="my_cache_dir", help="Directory to store compiled cache files.")
    parser.add_argument("--cache_key", default="yolo_pose_fp32_bf16", help="Cache key for the compiled model.")
    parser.add_argument("--config_file", default="vitisai_config.json", help="Vitis AI VAIML compiler config JSON.")
    args = parser.parse_args()

    if not os.path.exists(args.model_path):
        raise FileNotFoundError(f"Model not found: {args.model_path}")
    if not os.path.exists(args.config_file):
        raise FileNotFoundError(f"Config not found: {args.config_file}")

    cache_dir_abs = os.path.abspath(args.cache_dir)
    os.makedirs(cache_dir_abs, exist_ok=True)

    print("=" * 70)
    print("YOLO-Pose Vitis AI Model Compilation")
    print("=" * 70)
    print(f"Model path:   {os.path.abspath(args.model_path)}")
    print(f"Cache dir:    {cache_dir_abs}")
    print(f"Cache key:    {args.cache_key}")
    print("=" * 70)

    provider_options = {
        "config_file": os.path.abspath(args.config_file),
        "cache_dir": cache_dir_abs,
        "cache_key": args.cache_key,
        "ai_analyzer_visualization": True,
        "ai_analyzer_profiling": True,
        "target": "VAIML",
    }

    onnxruntime.InferenceSession(
        args.model_path,
        providers=["VitisAIExecutionProvider"],
        provider_options=[provider_options],
    )


if __name__ == "__main__":
    main()
