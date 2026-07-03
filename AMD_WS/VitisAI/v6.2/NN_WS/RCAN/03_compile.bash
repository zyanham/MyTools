#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

PYTHON_BIN="${PYTHON_BIN:-python3}"
SCALE="${SCALE:-2}"
HEIGHT="${HEIGHT:-128}"
WIDTH="${WIDTH:-128}"
CACHE_DIR="${CACHE_DIR:-my_cache_dir}"
MODEL="${MODEL:-models/rcan_bix${SCALE}_x${SCALE}_${HEIGHT}x${WIDTH}.onnx}"
CACHE_KEY="${CACHE_KEY:-rcan_bix${SCALE}_x${SCALE}_${HEIGHT}x${WIDTH}_fp32_bf16}"
LOG_DIR="${LOG_DIR:-results}"
mkdir -p "$LOG_DIR"
COMPILE_LOG="${COMPILE_LOG:-$LOG_DIR/compile.log}"

{
  echo "Compile log: $COMPILE_LOG"
  echo "Compile started: $(date -Is)"
  echo "Compile env: CACHE_DIR=$CACHE_DIR CACHE_KEY=$CACHE_KEY MODEL=$MODEL PYTHON_BIN=$PYTHON_BIN"

  "$PYTHON_BIN" src/compile.py \
    --model_path "$MODEL" \
    --cache_dir "$CACHE_DIR" \
    --cache_key "$CACHE_KEY" \
    --config_file vitisai_config.json

  echo "Compiled cache: $CACHE_DIR/$CACHE_KEY"
  echo "Compile finished: $(date -Is)"
} 2>&1 | tee "$COMPILE_LOG"
