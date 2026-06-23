#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

VARIANT="${1:-all}"
PYTHON_BIN="${PYTHON_BIN:-venv/bin/python}"

if [[ ! -x "$PYTHON_BIN" ]]; then
  echo "Python not found: $PYTHON_BIN" >&2
  echo "Run: bash 01_setup.bash" >&2
  exit 1
fi

run_export() {
  local variant="$1"
  "$PYTHON_BIN" src/export_yolo8_onnx.py --variant "$variant" --output_dir models --opset 17 --imgsz 640
}

case "$VARIANT" in
  s|m) run_export "$VARIANT" ;;
  all)
    run_export s
    run_export m
    ;;
  *)
    echo "usage: bash 02_export.bash [s|m|all]" >&2
    exit 2
    ;;
esac
