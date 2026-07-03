#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$ROOT/vitisai_config.json" || ! -f "$ROOT/src/quantize.py" || ! -f "$ROOT/src/run_inference.py" ]]; then
  echo "Refusing to clean unexpected directory: $ROOT" >&2
  exit 2
fi

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
fi

run() {
  if [[ "$DRY_RUN" == "1" ]]; then
    printf '[dry-run]'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

echo "Cleaning generated yolov8m artifacts under: $ROOT"

run rm -rf \
  "$ROOT/my_cache_dir" \
  "$ROOT/results" \
  "$ROOT/runs" \
  "$ROOT/venv" \
  "$ROOT/output" \
  "$ROOT/output_VINT8" \
  "$ROOT/input_vart" \
  "$ROOT/datasets" \
  "$ROOT/.ultralytics" \
  "$ROOT/__pycache__" \
  "$ROOT/src/__pycache__" \
  "$ROOT/models/__pycache__" \
  "$ROOT/.pytest_cache"

run rm -f \
  "$ROOT/models/"*.onnx \
  "$ROOT/models/"*.pt \
  "$ROOT/models/"*.pth

if [[ "$DRY_RUN" == "0" ]]; then
  mkdir -p "$ROOT/models" "$ROOT/calib_data" "$ROOT/val_data" "$ROOT/results"
  touch "$ROOT/models/.gitkeep" "$ROOT/calib_data/.gitkeep" "$ROOT/val_data/.gitkeep" "$ROOT/results/.gitkeep"
fi

echo "Clean complete."
