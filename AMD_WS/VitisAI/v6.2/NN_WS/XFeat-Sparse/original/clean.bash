#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$ROOT/src/capture_original_pipeline.py" || ! -f "$ROOT/src/make_test_images.py" ]]; then
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

echo "Cleaning generated original XFeat-Sparse artifacts under: $ROOT"
run rm -rf "$ROOT/third_party" "$ROOT/test_images" "$ROOT/test_vectors" "$ROOT/results" "$ROOT/venv" "$ROOT/__pycache__" "$ROOT/src/__pycache__" "$ROOT/.pytest_cache"
if [[ "$DRY_RUN" == "0" ]]; then
  mkdir -p "$ROOT/models" "$ROOT/original" "$ROOT/results"
  touch "$ROOT/models/.gitkeep" "$ROOT/original/.gitkeep" "$ROOT/results/.gitkeep"
fi
echo "Clean complete."
