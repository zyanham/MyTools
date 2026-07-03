#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

PYTHON_BIN="${PYTHON_BIN:-python3}"
SCALE="${SCALE:-2}"
HEIGHT="${HEIGHT:-128}"
WIDTH="${WIDTH:-128}"
INPUT="${1:-../Dataset/SR_IMG}"
OUTPUT="${2:-results/npu_rcan_bix${SCALE}}"
CACHE_DIR="${CACHE_DIR:-my_cache_dir}"
MODEL="${MODEL:-models/rcan_bix${SCALE}_x${SCALE}_${HEIGHT}x${WIDTH}.onnx}"
CACHE_KEY="${CACHE_KEY:-rcan_bix${SCALE}_x${SCALE}_${HEIGHT}x${WIDTH}_fp32_bf16}"
LOG_DIR="${LOG_DIR:-results}"
mkdir -p "$LOG_DIR"
RUN_LOG="${RUN_LOG:-$LOG_DIR/npu_run_rcan_bix${SCALE}_${HEIGHT}x${WIDTH}.log}"
STRICT_ARGS=()
if [[ "${STRICT_NPU:-0}" == "1" ]]; then
  STRICT_ARGS+=(--strict_npu)
fi

{
echo "NPU run log: $RUN_LOG"
echo "NPU run started: $(date -Is)"
echo "NPU runtime env: XLNX_ENABLE_CACHE=${XLNX_ENABLE_CACHE:-<unset>} CACHE_DIR=$CACHE_DIR CACHE_KEY=$CACHE_KEY STRICT_NPU=${STRICT_NPU:-0} AI_ANALYZER=${AI_ANALYZER:-0}"

"$PYTHON_BIN" src/infer_file2file.py \
  --device npu \
  --model "$MODEL" \
  --input "$INPUT" \
  --output_dir "$OUTPUT" \
  --config vitisai_config.json \
  --cache_dir "$CACHE_DIR" \
  --cache_key "$CACHE_KEY" \
  --scale "$SCALE" \
  --height "$HEIGHT" \
  --width "$WIDTH" \
  "${STRICT_ARGS[@]}"

echo "NPU output: $OUTPUT"
echo "NPU run finished: $(date -Is)"
} 2>&1 | tee "$RUN_LOG"
