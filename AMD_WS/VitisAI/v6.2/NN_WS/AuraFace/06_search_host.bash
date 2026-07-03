#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

QUERY="${1:-../Dataset/HumanFaces/matz01.jpg}"
GALLERY="${2:-../Dataset/HumanFaces}"
OUTPUT="${3:-results/search_host_matz01}"
PYTHON_BIN="${PYTHON_BIN:-venv/bin/python}"

if [[ ! -x "$PYTHON_BIN" ]]; then
  echo "Python not found: $PYTHON_BIN" >&2
  echo "Run: bash 01_setup.bash" >&2
  exit 1
fi

"$PYTHON_BIN" src/search_identity.py \
  --device cpu \
  --model models/auraface.onnx \
  --query "$QUERY" \
  --gallery "$GALLERY" \
  --output_dir "$OUTPUT" \
  --threshold "${THRESHOLD:-0.30}" \
  --top_k "${TOP_K:-20}"

echo "Host CPU search output: $OUTPUT"
