#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="${RESULTS_DIR:-$SCRIPT_DIR/Results}"
WORK_DIR="$RESULTS_DIR/06_object_detection_cpp_vart_yolox_m_int8"
LOG_PATH="$RESULTS_DIR/06_object_detection_cpp_vart_yolox_m_int8.log"
APP_CONFIG="${APP_CONFIG:-/etc/vai/x_plus_ml_vart/json_configs/x_plus_ml_vart_od.json}"
INPUT_FILE="${INPUT_FILE:-/etc/vai/models/yolox_m_int8/data/detections.jpg}"
LOG_LEVEL="${LOG_LEVEL:-3}"
mkdir -p "$WORK_DIR"

if [[ "$(id -u)" -ne 0 ]]; then
    exec sudo -E env RESULTS_DIR="$RESULTS_DIR" APP_CONFIG="$APP_CONFIG" INPUT_FILE="$INPUT_FILE" LOG_LEVEL="$LOG_LEVEL" bash "$0" "$@"
fi

{
    echo "[QuickStart] Step 5: Object detection with YOLOX-M INT8 and VART"
    echo "Started: $(date -Is)"
    echo "APP_CONFIG: $APP_CONFIG"
    echo "INPUT_FILE: $INPUT_FILE"
    cd "$WORK_DIR"
    x_plus_ml_vart --app-config "$APP_CONFIG" --input-file "$INPUT_FILE" --log-level "$LOG_LEVEL"
    echo "Finished: $(date -Is)"
} 2>&1 | tee "$LOG_PATH"

