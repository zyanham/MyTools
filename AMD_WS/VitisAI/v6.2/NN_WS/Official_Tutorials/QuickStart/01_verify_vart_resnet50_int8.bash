#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="${RESULTS_DIR:-$SCRIPT_DIR/Results}"
WORK_DIR="$RESULTS_DIR/01_verify_vart_resnet50_int8"
LOG_PATH="$RESULTS_DIR/01_verify_vart_resnet50_int8.log"
APP_CONFIG="${APP_CONFIG:-/etc/vai/ml_vart/json_configs/ml_vart_config.json}"
REFERENCE_OUTPUT="${REFERENCE_OUTPUT:-/etc/vai/models/resnet50_int8/data/ofm_output_int8_1x1000.bin}"
ACTUAL_OUTPUT="${ACTUAL_OUTPUT:-output/infer_out0-int8_1x1000_output.bin}"
mkdir -p "$WORK_DIR"

if [[ "$(id -u)" -ne 0 ]]; then
    exec sudo -E env RESULTS_DIR="$RESULTS_DIR" APP_CONFIG="$APP_CONFIG" REFERENCE_OUTPUT="$REFERENCE_OUTPUT" ACTUAL_OUTPUT="$ACTUAL_OUTPUT" bash "$0" "$@"
fi

{
    echo "[QuickStart] Step 2: Verify VART ResNet50 INT8 inference"
    echo "Started: $(date -Is)"
    echo "APP_CONFIG: $APP_CONFIG"
    echo "REFERENCE_OUTPUT: $REFERENCE_OUTPUT"
    cd "$WORK_DIR"
    rm -rf output
    ml_vart --app-config "$APP_CONFIG"
    echo
    echo "Diff actual output against reference:"
    diff "$ACTUAL_OUTPUT" "$REFERENCE_OUTPUT"
    echo "Output matches reference."
    echo "Finished: $(date -Is)"
} 2>&1 | tee "$LOG_PATH"

