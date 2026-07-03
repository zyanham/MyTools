#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$ROOT/vitisai_config.json" || ! -f "$ROOT/src/quantize.py" || ! -f "$ROOT/src/runmodel.py" ]]; then
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

echo "Cleaning generated Resnet50_Quark artifacts under: $ROOT"

run rm -rf \
  "$ROOT/resnet50-v1-12_quantized" \
  "$ROOT/results" \
  "$ROOT/runs" \
  "$ROOT/venv" \
  "$ROOT/input" \
  "$ROOT/output_cpu" \
  "$ROOT/output_cpu_vint8" \
  "$ROOT/output_vek385" \
  "$ROOT/__pycache__" \
  "$ROOT/src/__pycache__" \
  "$ROOT/.pytest_cache"

run rm -f \
  "$ROOT/models/"*.onnx \
  "$ROOT/calib_data/"*.jpg \
  "$ROOT/calib_data/"*.png \
  "$ROOT/val_data/"*.jpg \
  "$ROOT/val_data/"*.png

if [[ "$DRY_RUN" == "0" ]]; then
  mkdir -p "$ROOT/models" "$ROOT/calib_data" "$ROOT/val_data" "$ROOT/results"
  touch "$ROOT/models/.gitkeep" "$ROOT/calib_data/.gitkeep" "$ROOT/val_data/.gitkeep" "$ROOT/results/.gitkeep"
fi

echo "Clean complete."
