#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$ROOT/vitisai_config.json" || ! -f "$ROOT/src/infer_file2file.py" || ! -f "$ROOT/src/export_yolo_pose_onnx.py" ]]; then
  echo "Refusing to clean unexpected directory without YOLO-Pose workspace markers: $ROOT" >&2
  exit 2
fi

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
fi

run() {
  if [[ "$DRY_RUN" == "1" ]]; then
    printf '[dry-run]'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

echo "Cleaning generated YOLO-Pose artifacts under: $ROOT"

run rm -rf \
  "$ROOT/my_cache_dir" \
  "$ROOT/compiled" \
  "$ROOT/datasets" \
  "$ROOT/output_host_cpu" \
  "$ROOT/output_host_cpu_single" \
  "$ROOT/output_vek385_npu" \
  "$ROOT/output_file2file" \
  "$ROOT/results" \
  "$ROOT/runs" \
  "$ROOT/test_images" \
  "$ROOT/venv" \
  "$ROOT/__pycache__" \
  "$ROOT/src/__pycache__" \
  "$ROOT/models/__pycache__" \
  "$ROOT/.pytest_cache"

run rm -f \
  "$ROOT/models/"*.onnx \
  "$ROOT/models/"*.pt \
  "$ROOT/models/"*.pth \
  "$ROOT/models/"*.pre_policy_* \
  "$ROOT/models/"*.engine \
  "$ROOT/models/"*.torchscript \
  "$ROOT/original-info-signature.txt" \
  "$ROOT/original-model-signature.txt"

if [[ "$DRY_RUN" == "0" ]]; then
  mkdir -p "$ROOT/calib_data" "$ROOT/val_data" "$ROOT/models" "$ROOT/original" "$ROOT/results"
  find "$ROOT/calib_data" -mindepth 1 ! -name .gitkeep -exec rm -rf {} +
  find "$ROOT/val_data" -mindepth 1 ! -name .gitkeep -exec rm -rf {} +
  touch "$ROOT/calib_data/.gitkeep" "$ROOT/val_data/.gitkeep" "$ROOT/models/.gitkeep" "$ROOT/original/.gitkeep" "$ROOT/results/.gitkeep"
fi

echo "Clean complete."
