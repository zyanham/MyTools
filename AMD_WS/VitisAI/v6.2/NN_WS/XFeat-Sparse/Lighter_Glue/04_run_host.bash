#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

PYTHON_BIN="${PYTHON_BIN:-venv/bin/python}"
REPORT="${1:-results/lighterglue_cpu_report.json}"

"$PYTHON_BIN" src/check_lighterglue_model.py \
  --model models/lighterglue_model.onnx \
  --vectors_dir ../original/test_vectors \
  --device cpu \
  --rtol 5e-2 \
  --atol 5e-2 \
  --report "$REPORT"

echo "Host CPU report: $REPORT"
