#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
export PYTHONUTF8="${PYTHONUTF8:-1}"
export PYTHONIOENCODING="${PYTHONIOENCODING:-utf-8}"
export YOLO_CONFIG_DIR="${YOLO_CONFIG_DIR:-$PWD/.ultralytics}"
mkdir -p "$YOLO_CONFIG_DIR" 2>/dev/null || true

ensure_official_venv() {
    if [[ "${OFFICIAL_USE_VENV:-1}" != "1" ]]; then
        PYTHON_BIN="${PYTHON_BIN:-python3}"
        return 0
    fi

    local venv_dir="${VENV_DIR:-venv}"
    local bootstrap_python="${PYTHON_BOOTSTRAP:-python3}"
    local venv_abs
    venv_abs="$(cd "$(dirname "$venv_dir")" && pwd)/$(basename "$venv_dir")"
    local venv_python="$venv_abs/bin/python"

    if [[ -d "$venv_abs" && ( ! -x "$venv_python" || ! -f "$venv_abs/bin/activate" ) ]]; then
        echo "Removing incomplete official tutorial venv: $venv_dir" >&2
        rm -rf "$venv_abs"
    fi

    if [[ ! -x "$venv_python" ]]; then
        "$bootstrap_python" -m venv --system-site-packages "$venv_abs"
    fi

    VIRTUAL_ENV="$venv_abs"
    PATH="$VIRTUAL_ENV/bin:$PATH"
    PYTHON_BIN="$venv_python"
    export VIRTUAL_ENV PATH
    export PYTHON_BIN
}

log_python_context() {
    "$PYTHON_BIN" - <<'PY'
import os
import sys

print("python_executable:", sys.executable)
print("python_prefix:", sys.prefix)
print("python_base_prefix:", sys.base_prefix)
print("venv_active:", sys.prefix != sys.base_prefix)
print("VIRTUAL_ENV:", os.environ.get("VIRTUAL_ENV", "<unset>"))
PY
}

run_logged() {
    local log_path="$1"
    shift

    mkdir -p "$(dirname "$log_path")"
    local start_s
    start_s="$(date +%s)"

    set +e
    {
        echo "Log file: $log_path"
        echo "Started: $(date -Is)"
        echo "Working directory: $PWD"
        echo "Command: $*"
        "$@"
        local command_status=$?
        echo "Finished: $(date -Is)"
        exit "$command_status"
    } 2>&1 | tee "$log_path"
    local status="${PIPESTATUS[0]}"
    set -e

    local end_s
    end_s="$(date +%s)"
    echo "[PERF] command_total_s=$((end_s - start_s)) status=$status" | tee -a "$log_path"
    return "$status"
}

ensure_model_file() {
    local model_path="$1"
    local hint="$2"

    if [[ ! -f "$model_path" ]]; then
        echo "Missing model file: $model_path" >&2
        echo "$hint" >&2
        return 1
    fi
}

download_file() {
    local url="$1"
    local output_path="$2"

    mkdir -p "$(dirname "$output_path")"
    if command -v wget >/dev/null 2>&1; then
        wget -O "$output_path" "$url"
    elif command -v curl >/dev/null 2>&1; then
        curl -L --fail -o "$output_path" "$url"
    else
        echo "Neither wget nor curl is available." >&2
        return 1
    fi
}

LOG_DIR="${LOG_DIR:-results}"
ensure_official_venv

run_logged "$LOG_DIR/export.log" "$PYTHON_BIN" src/export_to_onnx.py
