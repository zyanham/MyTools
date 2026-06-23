#!/usr/bin/env python3

import argparse
from pathlib import Path

import onnx
import torch

from carvana_unet import load_carvana_unet


def main() -> None:
    parser = argparse.ArgumentParser(description="Export yakhyo/unet-pytorch Carvana U-Net to ONNX.")
    parser.add_argument("--weights", default="third_party/unet-pytorch/weights/last.pt")
    parser.add_argument("--output", default="models/carvana_unet.onnx")
    parser.add_argument("--height", type=int, default=640)
    parser.add_argument("--width", type=int, default=959)
    parser.add_argument("--opset", type=int, default=17)
    args = parser.parse_args()

    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)

    model = load_carvana_unet(args.weights, device="cpu")
    dummy = torch.randn(1, 3, args.height, args.width, dtype=torch.float32)

    torch.onnx.export(
        model,
        dummy,
        str(output),
        input_names=["image"],
        output_names=["logits"],
        opset_version=args.opset,
        do_constant_folding=True,
        dynamic_axes=None,
        dynamo=False,
    )

    onnx_model = onnx.load(str(output))
    onnx.checker.check_model(onnx_model)
    print(f"exported: {output}")
    print(f"weights: {args.weights}")
    print(f"input: image [1, 3, {args.height}, {args.width}]")
    print(f"output: logits [1, 2, {args.height}, {args.width}]")


if __name__ == "__main__":
    main()
