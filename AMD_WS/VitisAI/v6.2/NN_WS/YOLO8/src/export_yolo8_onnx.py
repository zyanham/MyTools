#!/usr/bin/env python3

import argparse
import os
import subprocess
import sys
from pathlib import Path

os.environ["YOLO_AUTOINSTALL"] = "false"


def _block_onnxruntime_auto_install() -> None:
    original_run = subprocess.run
    original_check_call = subprocess.check_call

    def is_onnxruntime_install(cmd) -> bool:
        cmd_str = " ".join(cmd) if isinstance(cmd, (list, tuple)) else str(cmd)
        return "pip" in cmd_str and "onnxruntime" in cmd_str

    def patched_run(*args, **kwargs):
        cmd = args[0] if args else kwargs.get("args", [])
        if is_onnxruntime_install(cmd):
            print(f"Blocked auto-install attempt: {cmd}")
            return subprocess.CompletedProcess(args=cmd, returncode=0, stdout=b"", stderr=b"")
        return original_run(*args, **kwargs)

    def patched_check_call(*args, **kwargs):
        cmd = args[0] if args else kwargs.get("args", [])
        if is_onnxruntime_install(cmd):
            print(f"Blocked auto-install attempt: {cmd}")
            return 0
        return original_check_call(*args, **kwargs)

    subprocess.run = patched_run
    subprocess.check_call = patched_check_call


def main() -> None:
    parser = argparse.ArgumentParser(description="Export Ultralytics YOLO8 s/m detection model to ONNX.")
    parser.add_argument("--variant", choices=["s", "m"], required=True)
    parser.add_argument("--output_dir", default="models")
    parser.add_argument("--opset", type=int, default=17)
    parser.add_argument("--imgsz", type=int, default=640)
    args = parser.parse_args()

    try:
        import onnxruntime
    except ImportError:
        print("onnxruntime is not installed.", file=sys.stderr)
        raise

    print(f"onnxruntime: {onnxruntime.__version__}")
    _block_onnxruntime_auto_install()

    from ultralytics import YOLO

    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    weights = output_dir / f"yolov8{args.variant}.pt"
    model = YOLO(str(weights))
    exported = Path(model.export(format="onnx", opset=args.opset, imgsz=args.imgsz, dynamic=False, simplify=False))
    target = output_dir / f"yolov8{args.variant}.onnx"
    if exported.resolve() != target.resolve():
        exported.replace(target)
    print(f"exported: {target}")


if __name__ == "__main__":
    main()
