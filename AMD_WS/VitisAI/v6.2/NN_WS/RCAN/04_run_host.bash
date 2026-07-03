#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

PYTHON_BIN="${PYTHON_BIN:-venv/bin/python}"
SCALE="${SCALE:-2}"
HEIGHT="${HEIGHT:-128}"
WIDTH="${WIDTH:-128}"
INPUT="${1:-../Dataset/SR_IMG}"
OUTPUT="${2:-results/host_rcan_bix${SCALE}}"
MODEL="${MODEL:-models/rcan_bix${SCALE}_x${SCALE}_${HEIGHT}x${WIDTH}.onnx}"

if [[ ! -x "$PYTHON_BIN" ]]; then
  echo "Python not found: $PYTHON_BIN" >&2
  echo "Run: bash 01_setup.bash" >&2
  exit 1
fi

"$PYTHON_BIN" src/infer_file2file.py \
  --device cpu \
  --model "$MODEL" \
  --input "$INPUT" \
  --output_dir "$OUTPUT" \
  --scale "$SCALE" \
  --height "$HEIGHT" \
  --width "$WIDTH"

echo "Host output: $OUTPUT"
