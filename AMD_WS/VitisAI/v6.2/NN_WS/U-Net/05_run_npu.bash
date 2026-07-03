#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

INPUT="${1:-../Dataset/Web}"
OUTPUT="${2:-results/npu_carvana_unet}"
CACHE_DIR="${CACHE_DIR:-my_cache_dir}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
LOG_DIR="${LOG_DIR:-results}"
mkdir -p "$LOG_DIR"
RUN_LOG="${RUN_LOG:-$LOG_DIR/npu_run_carvana_unet.log}"
STRICT_ARGS=()
if [[ "${STRICT_NPU:-0}" == "1" ]]; then
  STRICT_ARGS+=(--strict_npu)
fi

{
echo "NPU run log: $RUN_LOG"
echo "NPU run started: $(date -Is)"
echo "NPU runtime env: XLNX_ENABLE_CACHE=${XLNX_ENABLE_CACHE:-<unset>} CACHE_DIR=$CACHE_DIR STRICT_NPU=${STRICT_NPU:-0} AI_ANALYZER=${AI_ANALYZER:-0}"

"$PYTHON_BIN" src/infer_file2file.py \
  --device npu \
  --model models/carvana_unet.onnx \
  --input "$INPUT" \
  --output_dir "$OUTPUT" \
  --config vitisai_config.json \
  --cache_dir "$CACHE_DIR" \
  --cache_key carvana_unet_fp32_bf16 \
  "${STRICT_ARGS[@]}"

echo "NPU output: $OUTPUT"
echo "NPU run finished: $(date -Is)"
} 2>&1 | tee "$RUN_LOG"
