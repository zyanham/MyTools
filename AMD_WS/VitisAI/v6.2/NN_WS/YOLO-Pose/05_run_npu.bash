#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

INPUT="${1:-../Dataset/HumanFaces}"
OUTPUT="${2:-results/npu_yolo_pose}"
CACHE_DIR="${CACHE_DIR:-my_cache_dir}"
PYTHON_BIN="${PYTHON_BIN:-python3}"

"$PYTHON_BIN" src/infer_file2file.py \
  --device npu \
  --model models/yolo_pose.onnx \
  --input "$INPUT" \
  --output_dir "$OUTPUT" \
  --config vitisai_config.json \
  --cache_dir "$CACHE_DIR" \
  --cache_key yolo_pose_fp32_bf16 \
  --conf_threshold "${CONF_THRESHOLD:-0.25}" \
  --keypoint_threshold "${KEYPOINT_THRESHOLD:-0.25}"

echo "NPU output: $OUTPUT"
