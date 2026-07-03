#!/usr/bin/env python3

import argparse
from pathlib import Path

import cv2
import numpy as np


def draw_base() -> np.ndarray:
    image = np.full((480, 640, 3), (238, 240, 242), dtype=np.uint8)
    rng = np.random.default_rng(20260620)

    for idx in range(90):
        x = int(rng.integers(40, 600))
        y = int(rng.integers(40, 430))
        radius = int(rng.integers(4, 16))
        color = tuple(int(v) for v in rng.integers(20, 230, size=3))
        cv2.circle(image, (x, y), radius, color, -1, cv2.LINE_AA)

    for idx in range(24):
        x0 = int(rng.integers(20, 560))
        y0 = int(rng.integers(20, 400))
        x1 = x0 + int(rng.integers(30, 90))
        y1 = y0 + int(rng.integers(20, 70))
        color = tuple(int(v) for v in rng.integers(30, 220, size=3))
        cv2.rectangle(image, (x0, y0), (x1, y1), color, 2)

    cv2.putText(image, "XFeat Sparse smoke", (45, 455), cv2.FONT_HERSHEY_SIMPLEX, 1.0, (20, 20, 20), 2, cv2.LINE_AA)
    return image


def main() -> None:
    parser = argparse.ArgumentParser(description="Create a deterministic image pair for XFeat Sparse smoke tests.")
    parser.add_argument("--output_dir", default="test_images")
    args = parser.parse_args()

    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    image0 = draw_base()
    matrix = cv2.getRotationMatrix2D((320, 240), 3.0, 0.98)
    matrix[:, 2] += np.array([18.0, -11.0])
    image1 = cv2.warpAffine(image0, matrix, (640, 480), flags=cv2.INTER_LINEAR, borderValue=(238, 240, 242))

    cv2.imwrite(str(output_dir / "xfeat_pair_0.png"), image0)
    cv2.imwrite(str(output_dir / "xfeat_pair_1.png"), image1)
    print(f"created image pair in {output_dir}")


if __name__ == "__main__":
    main()
