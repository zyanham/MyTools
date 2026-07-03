#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

PYTHON_BIN="${PYTHON_BIN:-venv/bin/python}"

if [[ ! -d ../original/third_party/accelerated_features || ! -d ../original/test_vectors ]]; then
  cat >&2 <<'TXT'
Missing original repository or captured npy vectors.
Run first:
  cd ../original
  bash 01_setup.bash
  bash 03_run_host.bash
TXT
  exit 1
fi

"$PYTHON_BIN" - <<'PY'
import onnx
import torch

if not torch.__version__.startswith("2.5.1"):
    print(
        "WARNING: xfeat compile was verified with the Vitis AI Docker Python "
        f"stack: torch 2.5.1+cpu / onnx 1.16.1. Current stack is "
        f"torch {torch.__version__} / onnx {onnx.__version__}."
    )
PY

"$PYTHON_BIN" src/export_xfeat_onnx.py \
  --repo ../original/third_party/accelerated_features \
  --weights ../original/third_party/accelerated_features/weights/xfeat.pt \
  --input_npy ../original/test_vectors/xfeat_image0_input.npy \
  --output models/xfeat_model.onnx

echo "ONNX ready: models/xfeat_model.onnx"
