#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

QUERY="${1:-../Dataset/HumanFaces/matz01.jpg}"
GALLERY="${2:-../Dataset/HumanFaces}"
OUTPUT="${3:-results/search_npu_matz01}"
CACHE_DIR="${CACHE_DIR:-my_cache_dir}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
LOG_DIR="${LOG_DIR:-results}"
mkdir -p "$LOG_DIR"
RUN_LOG="${RUN_LOG:-$LOG_DIR/npu_run_auraface_search.log}"
STRICT_ARGS=()
if [[ "${STRICT_NPU:-0}" == "1" ]]; then
  STRICT_ARGS+=(--strict_npu)
fi

{
echo "NPU run log: $RUN_LOG"
echo "NPU run started: $(date -Is)"
echo "NPU runtime env: XLNX_ENABLE_CACHE=${XLNX_ENABLE_CACHE:-<unset>} CACHE_DIR=$CACHE_DIR STRICT_NPU=${STRICT_NPU:-0} AI_ANALYZER=${AI_ANALYZER:-0}"

"$PYTHON_BIN" src/search_identity.py \
  --device npu \
  --model models/auraface.onnx \
  --query "$QUERY" \
  --gallery "$GALLERY" \
  --output_dir "$OUTPUT" \
  --config vitisai_config.json \
  --cache_dir "$CACHE_DIR" \
  --cache_key auraface_fp32_bf16 \
  --threshold "${THRESHOLD:-0.30}" \
  --top_k "${TOP_K:-20}" \
  "${STRICT_ARGS[@]}"

echo "NPU search output: $OUTPUT"
echo "NPU run finished: $(date -Is)"
} 2>&1 | tee "$RUN_LOG"
