#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

QUERY="${1:-../Dataset/HumanFaces/matz01.jpg}"
GALLERY="${2:-../Dataset/HumanFaces}"
OUTPUT="${3:-results/search_npu_matz01}"
CACHE_DIR="${CACHE_DIR:-my_cache_dir}"
PYTHON_BIN="${PYTHON_BIN:-python3}"

"$PYTHON_BIN" src/search_identity.py \
  --device npu \
  --model models/auraface.onnx \
  --query "$QUERY" \
  --gallery "$GALLERY" \
  --output_dir "$OUTPUT" \
  --config vitisai_config.json \
  --cache_dir "$CACHE_DIR" \
  --cache_key auraface_fp32_bf16 \
  --threshold "${THRESHOLD:-0.30}" \
  --top_k "${TOP_K:-20}"

echo "NPU search output: $OUTPUT"
