#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

INPUT="${1:-../Dataset/Web}"
OUTPUT="${2:-results/npu_carvana_unet}"
CACHE_DIR="${CACHE_DIR:-my_cache_dir}"
PYTHON_BIN="${PYTHON_BIN:-python3}"

"$PYTHON_BIN" src/infer_file2file.py \
  --device npu \
  --model models/carvana_unet.onnx \
  --input "$INPUT" \
  --output_dir "$OUTPUT" \
  --config vitisai_config.json \
  --cache_dir "$CACHE_DIR" \
  --cache_key carvana_unet_fp32_bf16

echo "NPU output: $OUTPUT"
