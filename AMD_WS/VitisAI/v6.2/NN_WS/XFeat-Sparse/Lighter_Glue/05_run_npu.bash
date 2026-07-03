#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

CACHE_DIR="${CACHE_DIR:-my_cache_dir}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
REPORT="${1:-results/lighterglue_npu_report.json}"
LOG_DIR="${LOG_DIR:-results}"
mkdir -p "$LOG_DIR"
RUN_LOG="${RUN_LOG:-$LOG_DIR/npu_run_lighterglue_check.log}"
STRICT_ARGS=()
if [[ "${STRICT_NPU:-0}" == "1" ]]; then
  STRICT_ARGS+=(--strict_npu)
fi

{
echo "NPU run log: $RUN_LOG"
echo "NPU run started: $(date -Is)"
echo "NPU runtime env: XLNX_ENABLE_CACHE=${XLNX_ENABLE_CACHE:-<unset>} CACHE_DIR=$CACHE_DIR STRICT_NPU=${STRICT_NPU:-0} AI_ANALYZER=${AI_ANALYZER:-0}"

"$PYTHON_BIN" src/check_lighterglue_model.py \
  --model models/lighterglue_model.onnx \
  --vectors_dir ../original/test_vectors \
  --device npu \
  --config vitisai_config.json \
  --cache_dir "$CACHE_DIR" \
  --cache_key lighterglue_model_fp32_bf16 \
  --rtol 5e-2 \
  --atol 5e-2 \
  --report "$REPORT" \
  "${STRICT_ARGS[@]}"

echo "NPU report: $REPORT"
echo "NPU run finished: $(date -Is)"
} 2>&1 | tee "$RUN_LOG"
