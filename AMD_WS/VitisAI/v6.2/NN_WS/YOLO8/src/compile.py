#!/usr/bin/env python3

# ===========================================================
# Copyright ﾂｩ 2025 Advanced Micro Devices, Inc. All rights reserved.
# MIT License
# ===========================================================

import onnxruntime
import argparse
import os

def main():
    parser = argparse.ArgumentParser(description="Compile YOLOv8s model for Vitis AI VAIML")
    parser.add_argument(
        "--model_path",
        type=str,
        default="models/yolov8s_VINT8_skipNodes.onnx",
        help="Path to the quantized ONNX model"
    )
    parser.add_argument(
        "--cache_dir",
        type=str,
        default="compiled",
        help="Directory to store compiled cache files"
    )
    parser.add_argument(
        "--cache_key",
        type=str,
        default="yolov8s_VINT8_skipNodes",
        help="Cache key for the compiled model"
    )
    parser.add_argument(
        "--config_file",
        type=str,
        default="vitisai_config.json",
        help="Vitis AI VAIML compiler config JSON"
    )
    args = parser.parse_args()
    
    # Verify model exists
    if not os.path.exists(args.model_path):
        raise FileNotFoundError(f"Model not found: {args.model_path}")
    if not os.path.exists(args.config_file):
        raise FileNotFoundError(f"Config not found: {args.config_file}")
    
    # Create cache directory if it doesn't exist
    # Ensure cache_dir is absolute path
    cache_dir_abs = os.path.abspath(args.cache_dir)
    os.makedirs(cache_dir_abs, exist_ok=True)
    
    print("="*70)
    print("YOLOv8s VitisAI Model Compilation")
    print("="*70)
    print(f"Model path:   {os.path.abspath(args.model_path)}")
    print(f"Cache dir:    {cache_dir_abs}")
    print(f"Cache key:    {args.cache_key}")
    print("="*70)
    
    # Compile for VEK385 (using absolute path for cache_dir)
    provider_options_dict = {
        "config_file": os.path.abspath(args.config_file),
        "cache_dir": cache_dir_abs,
        "cache_key": args.cache_key,
        "ai_analyzer_visualization": True,
        "ai_analyzer_profiling": True,
        "target": "VAIML"
    }
    
    session = onnxruntime.InferenceSession(
        args.model_path,
        providers=["VitisAIExecutionProvider"],
        provider_options=[provider_options_dict]
    )
    
if __name__ == "__main__":
    main()


