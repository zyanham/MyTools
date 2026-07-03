#!/usr/bin/env bash
set -euo pipefail

export AI_ANALYZER=1
export RUN_LOG="${RUN_LOG:-results/npu_run_resnet50_quark_ai_analyzer.log}"

cd "$(dirname "$0")"
bash 05_run_npu.bash
