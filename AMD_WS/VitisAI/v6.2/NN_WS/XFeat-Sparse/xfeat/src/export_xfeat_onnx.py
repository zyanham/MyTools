#!/usr/bin/env python3

import argparse
import sys
from pathlib import Path

import numpy as np
import onnx
import torch


def add_repo(repo: Path) -> None:
    repo = repo.resolve()
    if not (repo / "modules" / "model.py").exists():
        raise FileNotFoundError(f"Official XFeat repository not found: {repo}")
    sys.path.insert(0, str(repo))


def main() -> None:
    parser = argparse.ArgumentParser(description="Export official XFeatModel forward pass to ONNX.")
    parser.add_argument("--repo", default="../original/third_party/accelerated_features")
    parser.add_argument("--weights", default="../original/third_party/accelerated_features/weights/xfeat.pt")
    parser.add_argument("--output", default="models/xfeat_model.onnx")
    parser.add_argument("--input_npy", default="../original/test_vectors/xfeat_image0_input.npy")
    parser.add_argument("--opset", type=int, default=17)
    args = parser.parse_args()

    add_repo(Path(args.repo))
    from modules.model import XFeatModel

    model = XFeatModel().eval()
    model.load_state_dict(torch.load(args.weights, map_location="cpu"))

    if Path(args.input_npy).exists():
        dummy = torch.from_numpy(np.load(args.input_npy)).float()
    else:
        dummy = torch.randn(1, 3, 480, 640, dtype=torch.float32)

    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)

    torch.onnx.export(
        model,
        dummy,
        str(output),
        input_names=["image"],
        output_names=["feats", "keypoints", "heatmap"],
        opset_version=args.opset,
        do_constant_folding=True,
        dynamic_axes=None,
        dynamo=False,
    )

    onnx_model = onnx.load(str(output))
    onnx.checker.check_model(onnx_model)
    print(f"exported: {output}")
    print(f"input image: {list(dummy.shape)}")


if __name__ == "__main__":
    main()
