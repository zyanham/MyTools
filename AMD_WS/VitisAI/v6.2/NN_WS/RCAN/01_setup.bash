#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

PYTHON_VERSION="${PYTHON_VERSION:-3.12.3}"
TORCH_VERSION="${TORCH_VERSION:-2.12.1}"

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
TXT
      exit 1
    fi
  fi
fi

source venv/bin/activate
python -m pip install --upgrade pip
python -m pip install --index-url https://download.pytorch.org/whl/cpu "torch==${TORCH_VERSION}+cpu"
python -m pip install -r requirements-host.txt

mkdir -p src models original results third_party

python - <<'PY'
import cv2
import numpy
import onnx
import onnxruntime
import PIL
import torch

print("opencv:", cv2.__version__)
print("numpy:", numpy.__version__)
print("onnx:", onnx.__version__)
print("onnxruntime:", onnxruntime.__version__)
print("Pillow:", PIL.__version__)
print("torch:", torch.__version__)
PY

cat > original/RCAN_reference.txt <<'TXT'
Official implementation:
https://github.com/yulunzhang/RCAN

Paper:
https://arxiv.org/abs/1807.02758

This workspace uses the official RCAN architecture and expects the official
BI pretrained checkpoint, normally named RCAN_BIX2.pt for the default x2 flow.
TXT
