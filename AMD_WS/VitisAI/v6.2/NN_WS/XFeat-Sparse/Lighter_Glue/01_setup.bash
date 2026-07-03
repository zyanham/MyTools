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
    python3 -m venv venv
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
import kornia
import numpy
import onnx
import onnxruntime
import torch

print("opencv:", cv2.__version__)
print("kornia:", kornia.__version__)
print("numpy:", numpy.__version__)
print("onnx:", onnx.__version__)
print("onnxruntime:", onnxruntime.__version__)
print("torch:", torch.__version__)
PY

mkdir -p src models original results
