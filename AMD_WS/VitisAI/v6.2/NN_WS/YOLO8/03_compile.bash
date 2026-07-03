#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

VARIANT="${1:-all}"
CACHE_DIR="${CACHE_DIR:-my_cache_dir}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
LOG_DIR="${LOG_DIR:-results}"
mkdir -p "$LOG_DIR"
COMPILE_LOG="${COMPILE_LOG:-$LOG_DIR/compile.log}"

run_compile() {
  local variant="$1"
  "$PYTHON_BIN" src/compile.py \
    --model_path "models/yolov8${variant}.onnx" \
    --cache_dir "$CACHE_DIR" \
    --cache_key "yolov8${variant}_fp32_bf16" \
    --config_file vitisai_config.json
}

{
  echo "Compile log: $COMPILE_LOG"
  echo "Compile started: $(date -Is)"
  echo "Compile env: CACHE_DIR=$CACHE_DIR VARIANT=$VARIANT PYTHON_BIN=$PYTHON_BIN"

  case "$VARIANT" in
    s|m) run_compile "$VARIANT" ;;
    all)
      run_compile s
      run_compile m
      ;;
    *)
      echo "usage: bash 03_compile.bash [s|m|all]" >&2
      exit 2
      ;;
  esac

  echo "Compile finished: $(date -Is)"
} 2>&1 | tee "$COMPILE_LOG"
