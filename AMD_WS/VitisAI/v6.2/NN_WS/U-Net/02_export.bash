#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

PYTHON_BIN="${PYTHON_BIN:-venv/bin/python}"

if [[ ! -x "$PYTHON_BIN" ]]; then
  echo "Python not found: $PYTHON_BIN" >&2
  echo "Run: bash 01_setup.bash" >&2
  exit 1
fi

bash 01_fetch_official.bash

"$PYTHON_BIN" src/export_carvana_onnx.py \
  --weights third_party/unet-pytorch/weights/last.pt \
  --output models/carvana_unet.onnx \
  --height 640 \
  --width 959 \
  --opset 17

test -f models/carvana_unet.onnx
echo "ONNX ready: models/carvana_unet.onnx"
