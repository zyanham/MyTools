#!/usr/bin/env python3

import argparse
from pathlib import Path

import torch

from rcan_model import RCAN, RCANConfig, load_rcan_weights


def main() -> None:
    parser = argparse.ArgumentParser(description="Export official RCAN BI model to fixed-shape ONNX.")
    parser.add_argument("--weights", default="models/RCAN_BIX2.pt")
    parser.add_argument("--output", default="models/rcan_bix2_x2_128x128.onnx")
    parser.add_argument("--scale", type=int, default=2)
    parser.add_argument("--height", type=int, default=128)
    parser.add_argument("--width", type=int, default=128)
    parser.add_argument("--n_resgroups", type=int, default=10)
    parser.add_argument("--n_resblocks", type=int, default=20)
    parser.add_argument("--n_feats", type=int, default=64)
    parser.add_argument("--reduction", type=int, default=16)
    parser.add_argument("--opset", type=int, default=17)
    parser.add_argument("--allow_random_weights", action="store_true")
    args = parser.parse_args()

    config = RCANConfig(
        scale=args.scale,
        n_resgroups=args.n_resgroups,
        n_resblocks=args.n_resblocks,
        n_feats=args.n_feats,
        reduction=args.reduction,
    )
    model = RCAN(config).eval()
    weights = Path(args.weights)
    if weights.is_file():
        load_rcan_weights(model, str(weights), strict=True)
        print(f"loaded weights: {weights}")
    elif args.allow_random_weights:
        print("warning: exporting with random RCAN weights for pipeline validation only.")
    else:
        raise FileNotFoundError(
            f"RCAN weights not found: {weights}. Run 02_export.bash with DOWNLOAD_WEIGHTS=1 or place official RCAN_BIX{args.scale}.pt there."
        )

    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    dummy = torch.zeros(1, 3, args.height, args.width, dtype=torch.float32)

    with torch.no_grad():
        torch.onnx.export(
            model,
            dummy,
            str(output),
            input_names=["lr"],
            output_names=["sr"],
            opset_version=args.opset,
            do_constant_folding=True,
        )
    print(f"exported: {output}")
    print(f"input:  lr [1, 3, {args.height}, {args.width}] FP32 RGB 0..255")
    print(f"output: sr [1, 3, {args.height * args.scale}, {args.width * args.scale}] FP32 RGB 0..255")


if __name__ == "__main__":
    main()
