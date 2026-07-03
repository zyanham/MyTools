#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

PYTHON_BIN="${PYTHON_BIN:-venv/bin/python}"
REPORT="${1:-results/xfeat_cpu_report.json}"

"$PYTHON_BIN" src/check_xfeat_model.py \
  --model models/xfeat_model.onnx \
  --vectors_dir ../original/test_vectors \
  --image_index 0 \
  --device cpu \
  --report "$REPORT"

echo "Host CPU report: $REPORT"
