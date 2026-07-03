#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="${RESULTS_DIR:-$SCRIPT_DIR/Results}"
WORK_DIR="$RESULTS_DIR/04_classification_cpp_vart_resnet50_int8"
LOG_PATH="$RESULTS_DIR/04_classification_cpp_vart_resnet50_int8.log"
APP_CONFIG="${APP_CONFIG:-/etc/vai/x_plus_ml_vart/json_configs/x_plus_ml_vart_1model.json}"
INPUT_FILE="${INPUT_FILE:-/etc/vai/models/resnet50_int8/data/classification.jpg}"
LOG_LEVEL="${LOG_LEVEL:-3}"
mkdir -p "$WORK_DIR"

if [[ "$(id -u)" -ne 0 ]]; then
    exec sudo -E env RESULTS_DIR="$RESULTS_DIR" APP_CONFIG="$APP_CONFIG" INPUT_FILE="$INPUT_FILE" LOG_LEVEL="$LOG_LEVEL" bash "$0" "$@"
fi

{
    echo "[QuickStart] Step 4 Option A: C++ image classification with VART"
    echo "Started: $(date -Is)"
    echo "APP_CONFIG: $APP_CONFIG"
    echo "INPUT_FILE: $INPUT_FILE"
    cd "$WORK_DIR"
    x_plus_ml_vart --app-config "$APP_CONFIG" --input-file "$INPUT_FILE" --log-level "$LOG_LEVEL"
    echo "Finished: $(date -Is)"
} 2>&1 | tee "$LOG_PATH"

