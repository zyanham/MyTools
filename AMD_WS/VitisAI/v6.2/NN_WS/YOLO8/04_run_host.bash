#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

VARIANT="${VARIANT:-s}"
INPUT="${1:-../Dataset/Pixabay}"
OUTPUT="${2:-results/host_yolov8${VARIANT}}"
PYTHON_BIN="${PYTHON_BIN:-venv/bin/python}"

if [[ ! -x "$PYTHON_BIN" ]]; then
  echo "Python not found: $PYTHON_BIN" >&2
  echo "Run: bash 01_setup.bash" >&2
  exit 1
fi

"$PYTHON_BIN" src/infer_file2file.py \
  --device cpu \
  --model "models/yolov8${VARIANT}.onnx" \
  --input "$INPUT" \
  --output_dir "$OUTPUT" \
  --conf_threshold "${CONF_THRESHOLD:-0.25}"

echo "Host CPU output: $OUTPUT"
