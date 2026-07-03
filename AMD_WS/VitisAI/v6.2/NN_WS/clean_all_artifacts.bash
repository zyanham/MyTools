#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN="${1:-}"

found=0
for clean_script in "$ROOT"/*/clean_artifacts.bash; do
  [[ -f "$clean_script" ]] || continue
  found=1
  echo "==> $(dirname "$clean_script")"
  if [[ "$DRY_RUN" == "--dry-run" ]]; then
    bash "$clean_script" --dry-run
  else
    bash "$clean_script"
  fi
done

if [[ "$found" == "0" ]]; then
  echo "No model clean_artifacts.bash scripts found under $ROOT"
fi
