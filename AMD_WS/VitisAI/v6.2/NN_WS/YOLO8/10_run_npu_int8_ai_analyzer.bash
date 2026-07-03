#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

export AI_ANALYZER="${AI_ANALYZER:-1}"
export RUN_LOG="${RUN_LOG:-results/npu_run_yolov8${VARIANT:-s}_int8_ai_analyzer.log}"

bash 09_run_npu_int8.bash "$@"
