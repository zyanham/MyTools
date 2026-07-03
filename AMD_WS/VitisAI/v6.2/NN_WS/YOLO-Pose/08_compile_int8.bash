#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

CACHE_DIR="${CACHE_DIR:-my_cache_dir}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
LOG_DIR="${LOG_DIR:-results}"
mkdir -p "$LOG_DIR"
COMPILE_LOG="${COMPILE_LOG:-$LOG_DIR/compile_int8_yolo_pose.log}"
MODEL_PATH="${MODEL_PATH:-models/yolo_pose_vint8.onnx}"
CACHE_KEY="${CACHE_KEY:-yolo_pose_vint8}"

{
  echo "Compile INT8 log: $COMPILE_LOG"
  echo "Compile INT8 started: $(date -Is)"
  echo "Compile INT8 env: CACHE_DIR=$CACHE_DIR CACHE_KEY=$CACHE_KEY PYTHON_BIN=$PYTHON_BIN"

  if [[ ! -f "$MODEL_PATH" ]]; then
    echo "Missing INT8 model: $MODEL_PATH. Run bash 07_quark_int8.bash first." >&2
    exit 1
  fi

  "$PYTHON_BIN" src/compile.py \
    --model_path "$MODEL_PATH" \
    --cache_dir "$CACHE_DIR" \
    --cache_key "$CACHE_KEY" \
    --config_file vitisai_config.json

  echo "Compiled INT8 cache directory: ${CACHE_DIR}/${CACHE_KEY}"
  echo "Compile INT8 finished: $(date -Is)"
} 2>&1 | tee "$COMPILE_LOG"
