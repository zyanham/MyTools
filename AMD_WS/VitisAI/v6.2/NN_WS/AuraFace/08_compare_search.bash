#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

CPU_CSV="${1:-results/search_host_matz01/search_results.csv}"
NPU_CSV="${2:-results/search_npu_matz01/search_results.csv}"
OUTPUT="${3:-results/search_compare_matz01}"
PYTHON_BIN="${PYTHON_BIN:-venv/bin/python}"

if [[ ! -x "$PYTHON_BIN" ]]; then
  echo "Python not found: $PYTHON_BIN" >&2
  echo "Run: bash 01_setup.bash" >&2
  exit 1
fi

"$PYTHON_BIN" src/compare_search_results.py \
  --cpu_csv "$CPU_CSV" \
  --npu_csv "$NPU_CSV" \
  --output_dir "$OUTPUT" \
  --top_k "${TOP_K:-20}"

echo "CPU/NPU search compare output: $OUTPUT"
