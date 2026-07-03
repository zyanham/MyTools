#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="${RESULTS_DIR:-$SCRIPT_DIR/Results}"
WORK_DIR="$RESULTS_DIR/03_python_onnxruntime_resnet50_int8"
LOG_PATH="$RESULTS_DIR/03_python_onnxruntime_resnet50_int8.log"
OUTPUT_PREFIX="${OUTPUT_PREFIX:-$WORK_DIR/resnet50_int8_ofm}"
mkdir -p "$WORK_DIR"

if [[ "$(id -u)" -ne 0 ]]; then
    exec sudo -E env RESULTS_DIR="$RESULTS_DIR" OUTPUT_PREFIX="$OUTPUT_PREFIX" bash "$0" "$@"
fi

{
    echo "[QuickStart] Step 3: Python ONNX Runtime with Vitis AI EP"
    echo "Started: $(date -Is)"
    echo "OUTPUT_PREFIX: $OUTPUT_PREFIX"
    cd /etc/vai/python
    python3 run_ResNet50_vitisai.py --output-prefix "$OUTPUT_PREFIX"
    echo "Generated outputs:"
    ls -la "$WORK_DIR"
    echo "Finished: $(date -Is)"
} 2>&1 | tee "$LOG_PATH"

