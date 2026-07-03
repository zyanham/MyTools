#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

PYTHON_BIN="${PYTHON_BIN:-venv/bin/python}"
IMAGE0="${1:-test_images/xfeat_pair_0.png}"
IMAGE1="${2:-test_images/xfeat_pair_1.png}"
OUTPUT_DIR="${3:-results/original_host}"
VECTORS_DIR="${4:-test_vectors}"

bash 02_fetch_official.bash
"$PYTHON_BIN" src/make_test_images.py --output_dir test_images

"$PYTHON_BIN" src/capture_original_pipeline.py \
  --repo third_party/accelerated_features \
  --image0 "$IMAGE0" \
  --image1 "$IMAGE1" \
  --output_dir "$OUTPUT_DIR" \
  --vectors_dir "$VECTORS_DIR" \
  --top_k 128 \
  --min_conf 0.1

echo "Original host pipeline output: $OUTPUT_DIR"
echo "Model test vectors: $VECTORS_DIR"
