#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$ROOT/src/export_lighterglue_onnx.py" || ! -f "$ROOT/src/check_lighterglue_model.py" ]]; then
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

echo "Cleaning generated Lighter_Glue artifacts under: $ROOT"
run rm -rf "$ROOT/my_cache_dir" "$ROOT/compiled" "$ROOT/results" "$ROOT/venv" "$ROOT/__pycache__" "$ROOT/src/__pycache__" "$ROOT/.pytest_cache"
run rm -f \
  "$ROOT/models/"*.onnx \
  "$ROOT/original-info-signature.txt" \
  "$ROOT/original-model-signature.txt"
if [[ "$DRY_RUN" == "0" ]]; then
  mkdir -p "$ROOT/models" "$ROOT/original" "$ROOT/results"
  touch "$ROOT/models/.gitkeep" "$ROOT/original/.gitkeep" "$ROOT/results/.gitkeep"
fi
echo "Clean complete."
