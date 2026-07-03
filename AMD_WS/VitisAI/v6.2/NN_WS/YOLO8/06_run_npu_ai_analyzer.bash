#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

export AI_ANALYZER="${AI_ANALYZER:-1}"
export RUN_LOG="${RUN_LOG:-results/npu_run_yolov8${VARIANT:-s}_ai_analyzer.log}"

bash 05_run_npu.bash "$@"
