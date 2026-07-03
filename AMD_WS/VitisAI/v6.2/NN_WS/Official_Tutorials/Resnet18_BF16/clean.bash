#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$ROOT/vitisai_config.json" || ! -f "$ROOT/src/compile.py" || ! -f "$ROOT/src/runmodel.py" ]]; then
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

echo "Cleaning generated Resnet18_BF16 artifacts under: $ROOT"

run rm -rf \
  "$ROOT/my_cache_dir" \
  "$ROOT/results" \
  "$ROOT/runs" \
  "$ROOT/venv" \
  "$ROOT/__pycache__" \
  "$ROOT/src/__pycache__" \
  "$ROOT/.pytest_cache"

run rm -f \
  "$ROOT/models/"*.onnx \
  "$ROOT/models/"*.pt \
  "$ROOT/models/"*.pth

if [[ "$DRY_RUN" == "0" ]]; then
  mkdir -p "$ROOT/models" "$ROOT/results"
  touch "$ROOT/models/.gitkeep" "$ROOT/results/.gitkeep"
fi

echo "Clean complete."
