#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

CACHE_DIR="${CACHE_DIR:-my_cache_dir}"
PYTHON_BIN="${PYTHON_BIN:-python3}"

"$PYTHON_BIN" src/compile.py \
  --model_path models/auraface.onnx \
  --cache_dir "$CACHE_DIR" \
  --cache_key auraface_fp32_bf16 \
  --config_file vitisai_config.json

echo "Compiled FP32/BF16 cache directory: ${CACHE_DIR}/auraface_fp32_bf16"
