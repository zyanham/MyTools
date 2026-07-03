#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOY_DIR="$SCRIPT_DIR/Deploy"
ALLOW_MISSING_CACHE="${ALLOW_MISSING_CACHE:-0}"

fail() {
  echo "[BUILD-DEPLOY][FAIL] $*" >&2
  exit 1
}

info() {
  echo "[BUILD-DEPLOY][INFO] $*"
}

warn() {
  echo "[BUILD-DEPLOY][WARN] $*" >&2
}

require_dir() {
  local path="$1"
  [[ -d "$path" ]] || fail "Required directory not found: $path"
}

copy_dir_clean() {
  local src="$1"
  local dst="$2"
  require_dir "$src"
  mkdir -p "$(dirname "$dst")"
  cp -a "$src" "$dst"
  find "$dst" -type d -name "__pycache__" -prune -exec rm -rf {} +
  find "$dst" -type f \( -name "*.pyc" -o -name "*.pyo" \) -delete
}

copy_file_if_exists() {
  local src="$1"
  local dst_dir="$2"
  if [[ -f "$src" ]]; then
    mkdir -p "$dst_dir"
    cp -a "$src" "$dst_dir/"
  fi
}

copy_dir_if_exists() {
  local src="$1"
  local dst="$2"
  if [[ -d "$src" ]]; then
    copy_dir_clean "$src" "$dst"
  fi
}

copy_model_files() {
  local src_models="$1"
  local dst_models="$2"
  shift 2
  require_dir "$src_models"
  mkdir -p "$dst_models"

  local copied=0
  local pattern
  shopt -s nullglob
  for pattern in "$@"; do
    local matches=("$src_models"/$pattern)
    local file
    for file in "${matches[@]}"; do
      if [[ -f "$file" ]]; then
        cp -a "$file" "$dst_models/"
        copied=$((copied + 1))
      fi
    done
  done
  shopt -u nullglob

  [[ "$copied" -gt 0 ]] || fail "No model files copied from $src_models"
}

copy_cache_dir() {
  local src_model_dir="$1"
  local dst_model_dir="$2"
  local src_cache="$src_model_dir/my_cache_dir"
  local dst_cache="$dst_model_dir/my_cache_dir"

  if [[ ! -d "$src_cache" ]]; then
    if [[ "$ALLOW_MISSING_CACHE" == "1" ]]; then
      warn "Compiled cache not found, skipping: $src_cache"
      return
    fi
    fail "Compiled cache not found: $src_cache. Run the model compile step first, or set ALLOW_MISSING_CACHE=1."
  fi

  copy_dir_clean "$src_cache" "$dst_cache"
}

copy_runtime_bash() {
  local src_model_dir="$1"
  local dst_model_dir="$2"
  local scripts=(
    "03_compile.bash"
    "05_run_npu.bash"
    "06_run_npu_ai_analyzer.bash"
    "07_quark_int8.bash"
    "08_compile_int8.bash"
    "09_run_npu_int8.bash"
    "10_run_npu_int8_ai_analyzer.bash"
    "07_search_npu.bash"
    "09_run_npu_ai_analyzer.bash"
    "10_search_npu_ai_analyzer.bash"
  )
  local script
  for script in "${scripts[@]}"; do
    copy_file_if_exists "$src_model_dir/$script" "$dst_model_dir"
  done
}

copy_common_runtime() {
  local src_model_dir="$1"
  local dst_model_dir="$2"

  copy_runtime_bash "$src_model_dir" "$dst_model_dir"
  copy_file_if_exists "$src_model_dir/vitisai_config.json" "$dst_model_dir"
  copy_dir_clean "$src_model_dir/src" "$dst_model_dir/src"
  copy_dir_if_exists "$src_model_dir/calib_data" "$dst_model_dir/calib_data"
  copy_cache_dir "$src_model_dir" "$dst_model_dir"
  mkdir -p "$dst_model_dir/results"
}

copy_standard_model() {
  local model_name="$1"
  shift
  local src_model_dir="$SCRIPT_DIR/$model_name"
  local dst_model_dir="$DEPLOY_DIR/$model_name"

  info "Packaging $model_name"
  require_dir "$src_model_dir"
  mkdir -p "$dst_model_dir"
  copy_common_runtime "$src_model_dir" "$dst_model_dir"
  copy_model_files "$src_model_dir/models" "$dst_model_dir/models" "$@"
}

copy_xfeat_sparse() {
  local src_root="$SCRIPT_DIR/XFeat-Sparse"
  local dst_root="$DEPLOY_DIR/XFeat-Sparse"

  info "Packaging XFeat-Sparse shared test vectors"
  require_dir "$src_root"
  mkdir -p "$dst_root/original"
  copy_dir_clean "$src_root/original/test_vectors" "$dst_root/original/test_vectors"

  info "Packaging XFeat-Sparse/xfeat"
  mkdir -p "$dst_root/xfeat"
  copy_common_runtime "$src_root/xfeat" "$dst_root/xfeat"
  copy_model_files "$src_root/xfeat/models" "$dst_root/xfeat/models" "xfeat_model.onnx" "xfeat_model.onnx.data"

  info "Packaging XFeat-Sparse/Lighter_Glue"
  mkdir -p "$dst_root/Lighter_Glue"
  copy_common_runtime "$src_root/Lighter_Glue" "$dst_root/Lighter_Glue"
  copy_model_files "$src_root/Lighter_Glue/models" "$dst_root/Lighter_Glue/models" "lighterglue_model.onnx" "lighterglue_model.onnx.data"
}

copy_named_cache_dir() {
  local src_model_dir="$1"
  local dst_model_dir="$2"
  local cache_name="$3"
  local src_cache="$src_model_dir/$cache_name"
  local dst_cache="$dst_model_dir/$cache_name"

  if [[ ! -d "$src_cache" ]]; then
    if [[ "$ALLOW_MISSING_CACHE" == "1" ]]; then
      warn "Compiled cache not found, skipping: $src_cache"
      return
    fi
    fail "Compiled cache not found: $src_cache. Run the official tutorial compile step first, or set ALLOW_MISSING_CACHE=1."
  fi

  copy_dir_clean "$src_cache" "$dst_cache"
}

copy_official_tutorial() {
  local model_name="$1"
  shift
  local src_model_dir="$SCRIPT_DIR/Official_Tutorials/$model_name"
  local dst_model_dir="$DEPLOY_DIR/$model_name"

  info "Packaging Official Tutorial $model_name"
  require_dir "$src_model_dir"
  mkdir -p "$dst_model_dir"

  local script
  for script in "$src_model_dir"/*.bash; do
    [[ -f "$script" ]] || continue
    cp -a "$script" "$dst_model_dir/"
  done

  copy_file_if_exists "$src_model_dir/README.md" "$dst_model_dir"
  copy_file_if_exists "$src_model_dir/requirements.txt" "$dst_model_dir"
  copy_file_if_exists "$src_model_dir/coco.names" "$dst_model_dir"
  copy_file_if_exists "$src_model_dir/vitisai_config.json" "$dst_model_dir"
  copy_dir_clean "$src_model_dir/src" "$dst_model_dir/src"
  copy_dir_if_exists "$src_model_dir/calib_data" "$dst_model_dir/calib_data"
  copy_dir_if_exists "$src_model_dir/val_data" "$dst_model_dir/val_data"
  copy_dir_if_exists "$src_model_dir/images" "$dst_model_dir/images"
  copy_model_files "$src_model_dir/models" "$dst_model_dir/models" "$@"
  mkdir -p "$dst_model_dir/results"
}

copy_official_tutorial_with_cache() {
  local model_name="$1"
  shift
  local cache_names=()
  while [[ "$#" -gt 0 && "$1" != "--" ]]; do
    cache_names+=("$1")
    shift
  done
  [[ "$#" -gt 0 ]] || fail "Internal error: missing -- separator for Official Tutorial $model_name"
  shift

  copy_official_tutorial "$model_name" "$@"

  local cache_name
  for cache_name in "${cache_names[@]}"; do
    copy_named_cache_dir "$SCRIPT_DIR/Official_Tutorials/$model_name" "$DEPLOY_DIR/$model_name" "$cache_name"
  done
}

case "$(basename "$SCRIPT_DIR")" in
  NN_WS) ;;
  *) fail "This script must live under NN_WS. Resolved script directory: $SCRIPT_DIR" ;;
esac

case "$DEPLOY_DIR" in
  "$SCRIPT_DIR"/Deploy) ;;
  *) fail "Refusing to delete unexpected Deploy path: $DEPLOY_DIR" ;;
esac

info "Recreating Deploy directory: $DEPLOY_DIR"
rm -rf -- "$DEPLOY_DIR"
mkdir -p "$DEPLOY_DIR"

copy_standard_model "AuraFace" "auraface.onnx" "auraface.onnx.data"
copy_standard_model "RCAN" "rcan_bix*_x*.onnx" "rcan_bix*_x*.onnx.data"
copy_standard_model "U-Net" "carvana_unet.onnx" "carvana_unet.onnx.data"
copy_standard_model "YOLO8" "yolov8s.onnx" "yolov8s.onnx.data" "yolov8m.onnx" "yolov8m.onnx.data" "yolov8s_vint8.onnx" "yolov8s_vint8.onnx.data" "yolov8m_vint8.onnx" "yolov8m_vint8.onnx.data"
copy_standard_model "YOLO-Pose" "yolo_pose.onnx" "yolo_pose.onnx.data" "yolo_pose_vint8.onnx" "yolo_pose_vint8.onnx.data"
copy_xfeat_sparse
copy_official_tutorial_with_cache "Resnet18_BF16" "my_cache_dir" -- "resnet18.a1_in1k.onnx" "resnet18.a1_in1k.onnx.data"
copy_official_tutorial_with_cache "Resnet50Cpp" "vek385_cache_dir" -- "resnet50-v1-12.onnx" "resnet50-v1-12.onnx.data"
copy_official_tutorial_with_cache "Resnet50_Quark" "resnet50-v1-12_quantized" -- "resnet50-v1-12.onnx" "resnet50-v1-12.onnx.data" "resnet50-v1-12_quantized.onnx" "resnet50-v1-12_quantized.onnx.data"
copy_official_tutorial_with_cache "yolov8m" "my_cache_dir" -- "yolov8m.onnx" "yolov8m.onnx.data" "yolov8m.pt" "yolov8m_VINT8_skipNodes.onnx" "yolov8m_VINT8_skipNodes.onnx.data"
copy_dir_if_exists "$SCRIPT_DIR/Official_Tutorials/QuickStart" "$DEPLOY_DIR/QuickStart"

copy_file_if_exists "$SCRIPT_DIR/NPU_RUNTIME_LOGGING.md" "$DEPLOY_DIR"

{
  echo "Deploy package generated: $(date -Is)"
  echo "Source root: $SCRIPT_DIR"
  echo "Deploy root: $DEPLOY_DIR"
  echo
  find "$DEPLOY_DIR" -maxdepth 3 -type f | sort
} > "$DEPLOY_DIR/DEPLOY_MANIFEST.txt"

info "Deploy package ready: $DEPLOY_DIR"
info "Manifest: $DEPLOY_DIR/DEPLOY_MANIFEST.txt"
