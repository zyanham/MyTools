#!/usr/bin/env python3

import argparse
import os
import shutil
import urllib.request
from pathlib import Path


def download(url: str, output: Path) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    if output.exists() and output.stat().st_size > 0:
        print(f"exists: {output}")
        return

    tmp = output.with_suffix(output.suffix + ".tmp")
    print(f"downloading: {url}")
    with urllib.request.urlopen(url) as response, open(tmp, "wb") as f:
        shutil.copyfileobj(response, f)
    os.replace(tmp, output)
    print(f"downloaded: {output} ({output.stat().st_size} bytes)")


def main() -> None:
    parser = argparse.ArgumentParser(description="Download AuraFace-v1 recognition ONNX.")
    parser.add_argument("--output_dir", default="models")
    parser.add_argument("--source", default="https://huggingface.co/fal/AuraFace-v1/resolve/main/glintr100.onnx?download=1")
    args = parser.parse_args()

    output_dir = Path(args.output_dir)
    glintr100 = output_dir / "glintr100.onnx"
    auraface = output_dir / "auraface.onnx"

    download(args.source, glintr100)
    if auraface.exists() and auraface.stat().st_size == glintr100.stat().st_size:
        print(f"exists: {auraface}")
        return
    shutil.copyfile(glintr100, auraface)
    print(f"ready: {auraface}")


if __name__ == "__main__":
    main()
