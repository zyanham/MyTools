#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

INPUT="${1:-../Dataset/Web}"
OUTPUT="${2:-results/host_carvana_unet}"
PYTHON_BIN="${PYTHON_BIN:-venv/bin/python}"

if [[ ! -x "$PYTHON_BIN" ]]; then
  echo "Python not found: $PYTHON_BIN" >&2
  echo "Run: bash 01_setup.bash" >&2
  exit 1
fi

"$PYTHON_BIN" src/infer_file2file.py \
  --device cpu \
  --model models/carvana_unet.onnx \
  --input "$INPUT" \
  --output_dir "$OUTPUT"

echo "Host CPU output: $OUTPUT"
