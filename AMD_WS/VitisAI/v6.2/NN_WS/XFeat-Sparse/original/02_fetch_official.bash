#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

mkdir -p third_party
if [[ -d third_party/accelerated_features ]]; then
  echo "Official repository already present."
elif command -v git >/dev/null 2>&1; then
  git clone --depth 1 https://github.com/verlab/accelerated_features.git third_party/accelerated_features
else
  venv/bin/python - <<'PY'
import shutil
import urllib.request
import zipfile
from pathlib import Path

url = "https://github.com/verlab/accelerated_features/archive/refs/heads/main.zip"
root = Path("third_party")
zip_path = root / "accelerated_features-main.zip"
extract_dir = root / "accelerated_features-main"
target_dir = root / "accelerated_features"

print(f"Downloading {url}")
urllib.request.urlretrieve(url, zip_path)
with zipfile.ZipFile(zip_path) as zf:
    zf.extractall(root)
if target_dir.exists():
    shutil.rmtree(target_dir)
extract_dir.rename(target_dir)
zip_path.unlink()
PY
fi

test -f third_party/accelerated_features/weights/xfeat.pt
test -f third_party/accelerated_features/weights/xfeat-lighterglue.pt

echo "Official XFeat repository ready: third_party/accelerated_features"
