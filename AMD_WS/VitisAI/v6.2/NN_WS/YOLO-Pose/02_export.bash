#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

PYTHON_BIN="${PYTHON_BIN:-venv/bin/python}"

if [[ ! -x "$PYTHON_BIN" ]]; then
  echo "Python not found: $PYTHON_BIN" >&2
  echo "Run: bash 01_setup.bash" >&2
  exit 1
fi

"$PYTHON_BIN" src/export_yolo_pose_onnx.py \
  --weights yolov8s-pose.pt \
  --output_dir models \
  --output_name yolo_pose.onnx \
  --opset 17 \
  --imgsz 640

test -f models/yolo_pose.onnx
echo "ONNX ready: models/yolo_pose.onnx"
