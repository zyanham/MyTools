#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="${RESULTS_DIR:-$SCRIPT_DIR/Results}"
LOG_PATH="$RESULTS_DIR/00_check_board_env.log"
mkdir -p "$RESULTS_DIR"

{
    echo "[QuickStart] Step 1: board environment check"
    echo "Started: $(date -Is)"
    echo "User: $(id)"
    echo "Host: $(hostname)"
    echo "PWD: $PWD"
    echo
    echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}"
    echo
    echo "Kernel modules:"
    lsmod | grep -E 'amdxdna|xilinx_aie|zocl' || true
    echo
    echo "Vitis AI files:"
    ls -la /etc/vai || true
    echo
    echo "Models:"
    find /etc/vai/models -maxdepth 2 -type f 2>/dev/null | sort || true
    echo
    echo "Applications:"
    command -v ml_vart || true
    command -v x_plus_ml_vart || true
    command -v python3 || true
    echo "Finished: $(date -Is)"
} 2>&1 | tee "$LOG_PATH"

