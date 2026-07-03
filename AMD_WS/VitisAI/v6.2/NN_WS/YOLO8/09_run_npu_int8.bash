#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

VARIANT="${VARIANT:-s}"
INPUT="${1:-../Dataset/Pixabay}"
OUTPUT="${2:-results/npu_yolov8${VARIANT}_int8}"
CACHE_DIR="${CACHE_DIR:-my_cache_dir}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
LOG_DIR="${LOG_DIR:-results}"
mkdir -p "$LOG_DIR"
RUN_LOG="${RUN_LOG:-$LOG_DIR/npu_run_yolov8${VARIANT}_int8.log}"
MODEL_PATH="${MODEL_PATH:-models/yolov8${VARIANT}_vint8.onnx}"
CACHE_KEY="${CACHE_KEY:-yolov8${VARIANT}_vint8}"
STRICT_ARGS=()
if [[ "${STRICT_NPU:-0}" == "1" ]]; then
  STRICT_ARGS+=(--strict_npu)
fi

{
echo "NPU INT8 run log: $RUN_LOG"
echo "NPU INT8 run started: $(date -Is)"
echo "NPU INT8 runtime env: XLNX_ENABLE_CACHE=${XLNX_ENABLE_CACHE:-<unset>} CACHE_DIR=$CACHE_DIR CACHE_KEY=$CACHE_KEY STRICT_NPU=${STRICT_NPU:-0} AI_ANALYZER=${AI_ANALYZER:-0}"

if [[ ! -f "$MODEL_PATH" ]]; then
  echo "Missing INT8 model: $MODEL_PATH. Run bash 07_quark_int8.bash $VARIANT first." >&2
  exit 1
fi

"$PYTHON_BIN" src/infer_file2file.py \
  --device npu \
  --model "$MODEL_PATH" \
  --input "$INPUT" \
  --output_dir "$OUTPUT" \
  --config vitisai_config.json \
  --cache_dir "$CACHE_DIR" \
  --cache_key "$CACHE_KEY" \
  --conf_threshold "${CONF_THRESHOLD:-0.25}" \
  "${STRICT_ARGS[@]}"

echo "NPU INT8 output: $OUTPUT"
echo "NPU INT8 run finished: $(date -Is)"
} 2>&1 | tee "$RUN_LOG"
