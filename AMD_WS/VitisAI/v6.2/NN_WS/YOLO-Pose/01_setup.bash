#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

PYTHON_VERSION="${PYTHON_VERSION:-3.12.3}"
TORCH_VERSION="${TORCH_VERSION:-2.12.1}"
TORCHVISION_VERSION="${TORCHVISION_VERSION:-0.27.1}"

if [[ -d venv && ( ! -x venv/bin/python || ! -f venv/bin/activate ) ]]; then
  echo "Removing incomplete venv directory."
  rm -rf venv
fi

if [[ ! -d venv ]]; then
  if command -v pyenv >/dev/null 2>&1; then
    pyenv install -s "$PYTHON_VERSION"
    PYENV_VERSION="$PYTHON_VERSION" pyenv exec python -m venv venv
  else
    if ! python3 -m venv venv; then
      cat >&2 <<'TXT'
Failed to create Python venv.

On Ubuntu 24.04, install the venv package and rerun:
  sudo apt-get update
  sudo apt-get install -y python3.12-venv

Alternatively install pyenv and rerun this script.
TXT
      exit 1
    fi
  fi
fi

source venv/bin/activate
python -m pip install --upgrade pip
python -m pip install --index-url https://download.pytorch.org/whl/cpu \
  "torch==${TORCH_VERSION}+cpu" \
  "torchvision==${TORCHVISION_VERSION}+cpu"
python -m pip install -r requirements-host.txt

python - <<'PY'
import cv2
import numpy
import onnx
import onnxruntime
import torch
import torchvision
import ultralytics

print("opencv:", cv2.__version__)
print("numpy:", numpy.__version__)
print("onnx:", onnx.__version__)
print("onnxruntime:", onnxruntime.__version__)
print("torch:", torch.__version__)
print("torchvision:", torchvision.__version__)
print("ultralytics:", ultralytics.__version__)
PY

mkdir -p src models original results
cat > original/Ultralytics_YOLOv8s_pose_reference.txt <<'TXT'
Upstream model source:
https://github.com/ultralytics/ultralytics

This workspace uses the pretrained Ultralytics yolov8s-pose.pt model and exports
it to models/yolo_pose.onnx.
TXT
