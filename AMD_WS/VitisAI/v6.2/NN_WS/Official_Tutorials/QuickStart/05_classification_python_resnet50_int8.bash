#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="${RESULTS_DIR:-$SCRIPT_DIR/Results}"
WORK_DIR="$RESULTS_DIR/05_classification_python_resnet50_int8"
LOG_PATH="$RESULTS_DIR/05_classification_python_resnet50_int8.log"
OUTPUT_PREFIX="${OUTPUT_PREFIX:-$WORK_DIR/resnet50_int8_ofm}"
LABELS="${LABELS:-/etc/vai/models/resnet50_int8/data/imagenet-classes-1000.txt}"
TOP_K="${TOP_K:-5}"
mkdir -p "$WORK_DIR"

if [[ "$(id -u)" -ne 0 ]]; then
    exec sudo -E env RESULTS_DIR="$RESULTS_DIR" OUTPUT_PREFIX="$OUTPUT_PREFIX" LABELS="$LABELS" TOP_K="$TOP_K" bash "$0" "$@"
fi

{
    echo "[QuickStart] Step 4 Option B: Python image classification with Vitis AI EP"
    echo "Started: $(date -Is)"
    echo "OUTPUT_PREFIX: $OUTPUT_PREFIX"
    echo "LABELS: $LABELS"
    cd /etc/vai/python
    python3 run_ResNet50_vitisai.py \
        --output-prefix "$OUTPUT_PREFIX" \
        --postprocess \
        --postprocess-top-k "$TOP_K" \
        --labels "$LABELS"
    echo "Generated outputs:"
    ls -la "$WORK_DIR"
    echo "Finished: $(date -Is)"
} 2>&1 | tee "$LOG_PATH"

