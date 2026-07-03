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

"$PYTHON_BIN" src/export_lighterglue_onnx.py \
  --repo ../original/third_party/accelerated_features \
  --weights ../original/third_party/accelerated_features/weights/xfeat-lighterglue.pt \
  --vectors_dir ../original/test_vectors \
  --output models/lighterglue_model.onnx

echo "ONNX ready: models/lighterglue_model.onnx"
