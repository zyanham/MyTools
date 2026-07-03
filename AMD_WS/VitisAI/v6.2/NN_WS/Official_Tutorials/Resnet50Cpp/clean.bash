#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$ROOT/vitisai_config.json" || ! -f "$ROOT/src/input.cpp" || ! -f "$ROOT/src/compile.py" ]]; then
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

echo "Cleaning generated Resnet50Cpp artifacts under: $ROOT"

run rm -rf \
  "$ROOT/vek385_cache_dir" \
  "$ROOT/results" \
  "$ROOT/runs" \
  "$ROOT/venv" \
  "$ROOT/__pycache__" \
  "$ROOT/src/__pycache__" \
  "$ROOT/.pytest_cache"

run rm -f \
  "$ROOT/models/"*.onnx \
  "$ROOT/input.o" \
  "$ROOT/model-app.elf" \
  "$ROOT/input0.bin" \
  "$ROOT/output0.bin" \
  "$ROOT/output0_py.bin"

if [[ "$DRY_RUN" == "0" ]]; then
  mkdir -p "$ROOT/models" "$ROOT/results"
  touch "$ROOT/models/.gitkeep" "$ROOT/results/.gitkeep"
fi

echo "Clean complete."
