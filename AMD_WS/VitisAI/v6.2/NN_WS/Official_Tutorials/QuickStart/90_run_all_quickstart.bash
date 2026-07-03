#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="${RESULTS_DIR:-$SCRIPT_DIR/Results}"
LOG_PATH="$RESULTS_DIR/90_run_all_quickstart.log"
mkdir -p "$RESULTS_DIR"

{
    echo "[QuickStart] Run all quick-start guide steps"
    echo "Started: $(date -Is)"
    bash "$SCRIPT_DIR/00_check_board_env.bash"
    bash "$SCRIPT_DIR/01_verify_vart_resnet50_int8.bash"
    bash "$SCRIPT_DIR/02_benchmark_vart_resnet50_int8.bash"
    bash "$SCRIPT_DIR/03_python_onnxruntime_resnet50_int8.bash"
    bash "$SCRIPT_DIR/04_classification_cpp_vart_resnet50_int8.bash"
    bash "$SCRIPT_DIR/05_classification_python_resnet50_int8.bash"
    bash "$SCRIPT_DIR/06_object_detection_cpp_vart_yolox_m_int8.bash"
    echo "Finished: $(date -Is)"
} 2>&1 | tee "$LOG_PATH"

