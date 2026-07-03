#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -d "$ROOT/original" || ! -d "$ROOT/xfeat" || ! -d "$ROOT/Lighter_Glue" ]]; then
  echo "Refusing to clean unexpected directory: $ROOT" >&2
  exit 2
fi

for sub in original xfeat Lighter_Glue; do
  bash "$ROOT/$sub/clean.bash" "${1:-}"
done

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

run rm -rf \
  "$ROOT/calib_data" \
  "$ROOT/compiled" \
  "$ROOT/models" \
  "$ROOT/output_original_host" \
  "$ROOT/test_images" \
  "$ROOT/test_vectors" \
  "$ROOT/third_party" \
  "$ROOT/val_data" \
  "$ROOT/__pycache__" \
  "$ROOT/.pytest_cache"

run rm -f \
  "$ROOT/original-info-signature.txt" \
  "$ROOT/original-model-signature.txt"

echo "XFeat-Sparse clean complete."
