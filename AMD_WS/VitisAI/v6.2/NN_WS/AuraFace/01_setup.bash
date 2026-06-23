#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

PYTHON_VERSION="${PYTHON_VERSION:-3.12.3}"

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
python -m pip install -r requirements-host.txt

python - <<'PY'
import cv2
import numpy
import onnx
import onnxruntime

print("opencv:", cv2.__version__)
print("numpy:", numpy.__version__)
print("onnx:", onnx.__version__)
print("onnxruntime:", onnxruntime.__version__)
print("providers:", onnxruntime.get_available_providers())
PY

mkdir -p src models original results
cat > original/AuraFace-v1_reference.txt <<'TXT'
AuraFace-v1 source:
https://huggingface.co/fal/AuraFace-v1

This workspace uses the recognition model:
glintr100.onnx -> auraface.onnx

The detector model from AuraFace-v1 is not compiled here. Inputs are expected to
be already face-centered/cropped test images from ../Dataset/HumanFaces.
TXT
