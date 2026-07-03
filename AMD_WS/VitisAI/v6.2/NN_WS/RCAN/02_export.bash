#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

PYTHON_BIN="${PYTHON_BIN:-venv/bin/python}"
SCALE="${SCALE:-2}"
HEIGHT="${HEIGHT:-128}"
WIDTH="${WIDTH:-128}"
CACHE_SHAPE="x${SCALE}_${HEIGHT}x${WIDTH}"
WEIGHTS="${WEIGHTS:-models/RCAN_BIX${SCALE}.pt}"
OUTPUT="${OUTPUT:-models/rcan_bix${SCALE}_${CACHE_SHAPE}.onnx}"

if [[ ! -x "$PYTHON_BIN" ]]; then
  echo "Python not found: $PYTHON_BIN" >&2
  echo "Run: bash 01_setup.bash" >&2
  exit 1
fi

mkdir -p models original downloads

if [[ "${FETCH_OFFICIAL:-1}" == "1" ]]; then
  bash 01_fetch_official.bash
fi

if [[ ! -f "$WEIGHTS" && "${DOWNLOAD_WEIGHTS:-0}" == "1" ]]; then
  ZIP="downloads/models_ECCV2018RCAN.zip"
  URLS=(
    "https://www.dropbox.com/s/qm9vc0p0w9i4s0n/models_ECCV2018RCAN.zip?dl=1"
    "https://www.dropbox.com/s/mjbcqkd4nwhr6nu/models_ECCV2018RCAN.zip?dl=1"
  )
  for URL in "${URLS[@]}"; do
    echo "Downloading official RCAN weights from Dropbox: $URL"
    if curl -L "$URL" -o "$ZIP" && unzip -tq "$ZIP" >/dev/null 2>&1; then
      break
    fi
    rm -f "$ZIP"
  done
  if [[ ! -f "$ZIP" ]]; then
    echo "Failed to download a valid RCAN weights zip." >&2
    exit 1
  fi
  rm -rf downloads/models_ECCV2018RCAN
  unzip -o "$ZIP" -d downloads/models_ECCV2018RCAN
  FOUND="$(find downloads/models_ECCV2018RCAN -type f -name "RCAN_BIX${SCALE}.pt" | head -n 1 || true)"
  if [[ -n "$FOUND" ]]; then
    cp "$FOUND" "$WEIGHTS"
  fi
fi

if [[ ! -f "$WEIGHTS" && "${ALLOW_RANDOM_WEIGHTS:-0}" != "1" ]]; then
  cat >&2 <<TXT
Missing official RCAN weights: $WEIGHTS

Options:
  DOWNLOAD_WEIGHTS=1 bash 02_export.bash
  or place RCAN_BIX${SCALE}.pt at $WEIGHTS

For compile-path testing only, random weights are allowed with:
  ALLOW_RANDOM_WEIGHTS=1 bash 02_export.bash
TXT
  exit 1
fi

RANDOM_ARGS=()
if [[ "${ALLOW_RANDOM_WEIGHTS:-0}" == "1" && ! -f "$WEIGHTS" ]]; then
  RANDOM_ARGS+=(--allow_random_weights)
fi

"$PYTHON_BIN" src/export_rcan_onnx.py \
  --weights "$WEIGHTS" \
  --output "$OUTPUT" \
  --scale "$SCALE" \
  --height "$HEIGHT" \
  --width "$WIDTH" \
  --opset "${OPSET:-17}" \
  "${RANDOM_ARGS[@]}"

test -f "$OUTPUT"
echo "ONNX ready: $OUTPUT"
