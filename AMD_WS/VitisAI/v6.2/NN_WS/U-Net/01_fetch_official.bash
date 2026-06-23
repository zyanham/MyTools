#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

mkdir -p third_party
if [[ -d third_party/unet-pytorch ]]; then
  echo "Official repository already present."
elif command -v git >/dev/null 2>&1; then
  git clone --depth 1 https://github.com/yakhyo/unet-pytorch.git third_party/unet-pytorch
else
  python3 - <<'PY'
import shutil
import urllib.request
import zipfile
from pathlib import Path

url = "https://github.com/yakhyo/unet-pytorch/archive/refs/heads/main.zip"
root = Path("third_party")
zip_path = root / "unet-pytorch-main.zip"
extract_dir = root / "unet-pytorch-main"
target_dir = root / "unet-pytorch"

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

test -f third_party/unet-pytorch/weights/last.pt
test -f third_party/unet-pytorch/assets/image.jpg
echo "Official yakhyo/unet-pytorch repository ready: third_party/unet-pytorch"
