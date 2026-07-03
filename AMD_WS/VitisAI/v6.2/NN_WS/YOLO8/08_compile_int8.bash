#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

VARIANT="${VARIANT:-${1:-s}}"
CACHE_DIR="${CACHE_DIR:-my_cache_dir}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
LOG_DIR="${LOG_DIR:-results}"
mkdir -p "$LOG_DIR"
COMPILE_LOG="${COMPILE_LOG:-$LOG_DIR/compile_int8_yolov8${VARIANT}.log}"

case "$VARIANT" in
  s|m) ;;
  *)
    echo "usage: VARIANT=s|m bash 08_compile_int8.bash, or bash 08_compile_int8.bash [s|m]" >&2
    exit 2
    ;;
esac

MODEL_PATH="${MODEL_PATH:-models/yolov8${VARIANT}_vint8.onnx}"
CACHE_KEY="${CACHE_KEY:-yolov8${VARIANT}_vint8}"

{
  echo "Compile INT8 log: $COMPILE_LOG"
  echo "Compile INT8 started: $(date -Is)"
  echo "Compile INT8 env: VARIANT=$VARIANT CACHE_DIR=$CACHE_DIR CACHE_KEY=$CACHE_KEY PYTHON_BIN=$PYTHON_BIN"

  if [[ ! -f "$MODEL_PATH" ]]; then
    echo "Missing INT8 model: $MODEL_PATH. Run bash 07_quark_int8.bash $VARIANT first." >&2
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
