#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

VARIANT="${VARIANT:-s}"
INPUT="${1:-../Dataset/Pixabay}"
OUTPUT="${2:-results/npu_yolov8${VARIANT}}"
CACHE_DIR="${CACHE_DIR:-my_cache_dir}"
PYTHON_BIN="${PYTHON_BIN:-python3}"

"$PYTHON_BIN" src/infer_file2file.py \
  --device npu \
  --model "models/yolov8${VARIANT}.onnx" \
  --input "$INPUT" \
  --output_dir "$OUTPUT" \
  --config vitisai_config.json \
  --cache_dir "$CACHE_DIR" \
  --cache_key "yolov8${VARIANT}_fp32_bf16" \
  --conf_threshold "${CONF_THRESHOLD:-0.25}"

echo "NPU output: $OUTPUT"
