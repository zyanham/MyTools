#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="${RESULTS_DIR:-$SCRIPT_DIR/Results}"
WORK_DIR="$RESULTS_DIR/02_benchmark_vart_resnet50_int8"
LOG_PATH="$RESULTS_DIR/02_benchmark_vart_resnet50_int8.log"
APP_CONFIG="${APP_CONFIG:-/etc/vai/ml_vart/json_configs/ml_vart_config.json}"
RUNS="${RUNS:-1000}"
mkdir -p "$WORK_DIR"

if [[ "$(id -u)" -ne 0 ]]; then
    exec sudo -E env RESULTS_DIR="$RESULTS_DIR" APP_CONFIG="$APP_CONFIG" RUNS="$RUNS" bash "$0" "$@"
fi

{
    echo "[QuickStart] Step 2: Benchmark VART ResNet50 INT8 inference"
    echo "Started: $(date -Is)"
    echo "APP_CONFIG: $APP_CONFIG"
    echo "RUNS: $RUNS"
    cd "$WORK_DIR"
    ml_vart --app-config "$APP_CONFIG" --benchmark --runs "$RUNS"
    echo "Finished: $(date -Is)"
} 2>&1 | tee "$LOG_PATH"

