#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

mkdir -p third_party original

if [[ ! -d third_party/RCAN ]]; then
  git clone --depth 1 https://github.com/yulunzhang/RCAN.git third_party/RCAN
fi

cat > original/official_commit.txt <<TXT
Repository: https://github.com/yulunzhang/RCAN
Fetched at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Commit: $(git -C third_party/RCAN rev-parse HEAD)
TXT

echo "Official RCAN source ready: third_party/RCAN"
