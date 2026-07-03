#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

VARIANT="${VARIANT:-${1:-s}}"
CALIB_DIR="${CALIB_DIR:-calib_data}"
CALIB_LIMIT="${CALIB_LIMIT:-0}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
LOG_DIR="${LOG_DIR:-results}"
mkdir -p "$LOG_DIR"
QUARK_LOG="${QUARK_LOG:-$LOG_DIR/quark_int8_yolov8${VARIANT}.log}"
EXCLUDE_SUBGRAPHS="${EXCLUDE_SUBGRAPHS:-[/model.22/Concat_3]:[/model.22/Concat_5]}"

case "$VARIANT" in
  s|m) ;;
  *)
    echo "usage: VARIANT=s|m bash 07_quark_int8.bash, or bash 07_quark_int8.bash [s|m]" >&2
    exit 2
    ;;
esac

MODEL_PATH="models/yolov8${VARIANT}.onnx"
OUTPUT_MODEL="models/yolov8${VARIANT}_vint8.onnx"

{
  echo "Quark INT8 log: $QUARK_LOG"
  echo "Quark started: $(date -Is)"
  echo "Quark env: VARIANT=$VARIANT CALIB_DIR=$CALIB_DIR CALIB_LIMIT=$CALIB_LIMIT PYTHON_BIN=$PYTHON_BIN"

  if [[ ! -f "$MODEL_PATH" ]]; then
    echo "Missing model: $MODEL_PATH. Run bash 02_export.bash $VARIANT first." >&2
    exit 1
  fi
  if [[ ! -d "$CALIB_DIR" ]]; then
    echo "Missing calibration directory: $CALIB_DIR. Set CALIB_DIR to an image directory." >&2
    exit 1
  fi

  "$PYTHON_BIN" src/quantize_yolo_int8.py \
    --model "$MODEL_PATH" \
    --output "$OUTPUT_MODEL" \
    --calib_dir "$CALIB_DIR" \
    --calib_limit "$CALIB_LIMIT" \
    --exclude_subgraphs "$EXCLUDE_SUBGRAPHS"

  echo "Quark output: $OUTPUT_MODEL"
  echo "Quark finished: $(date -Is)"
} 2>&1 | tee "$QUARK_LOG"
