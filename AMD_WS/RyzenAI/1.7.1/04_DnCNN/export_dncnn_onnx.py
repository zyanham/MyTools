import argparse
from collections import OrderedDict
from pathlib import Path

import onnx
import torch
import torch.nn as nn


class DnCNNNoBN(nn.Module):
    def __init__(self, image_channels: int = 3, depth: int = 20, n_channels: int = 64):
        super().__init__()
        layers = []

        # head
        layers += [
            nn.Conv2d(image_channels, n_channels, kernel_size=3, stride=1, padding=1, bias=True),
            nn.ReLU(inplace=True),
        ]

        # body
        for _ in range(depth - 2):
            layers += [
                nn.Conv2d(n_channels, n_channels, kernel_size=3, stride=1, padding=1, bias=True),
                nn.ReLU(inplace=True),
            ]

        # tail
        layers += [
            nn.Conv2d(n_channels, image_channels, kernel_size=3, stride=1, padding=1, bias=True),
        ]

        self.model = nn.Sequential(*layers)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        noise = self.model(x)
        return x - noise


def unwrap_checkpoint(obj):
    if not isinstance(obj, dict):
        return obj
    for key in ("state_dict", "model_state_dict", "params", "model", "net"):
        if key in obj and isinstance(obj[key], dict):
            return unwrap_checkpoint(obj[key])
    return obj


def normalize_state_dict(sd):
    out = OrderedDict()
    for k, v in sd.items():
        nk = k
        for prefix in ("module.", "net.", "denoiser."):
            if nk.startswith(prefix):
                nk = nk[len(prefix):]
        out[nk] = v
    return out


def safe_torch_load(path: Path):
    try:
        return torch.load(path, map_location="cpu", weights_only=True)
    except TypeError:
        return torch.load(path, map_location="cpu")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--weights", type=str, required=True)
    parser.add_argument("--output", type=str, required=True)
    parser.add_argument("--height", type=int, default=360)
    parser.add_argument("--width", type=int, default=640)
    parser.add_argument("--opset", type=int, default=17)
    args = parser.parse_args()

    weights_path = Path(args.weights)
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    checkpoint = safe_torch_load(weights_path)
    state_dict = normalize_state_dict(unwrap_checkpoint(checkpoint))

    print("=== checkpoint keys preview ===")
    for i, (k, v) in enumerate(state_dict.items()):
        print(f"{i:02d}: {k:20s} {tuple(v.shape)}")
        if i >= 9:
            break

    model = DnCNNNoBN(image_channels=3, depth=20, n_channels=64)

    missing, unexpected = model.load_state_dict(state_dict, strict=False)
    print("Missing keys   :", missing)
    print("Unexpected keys:", unexpected)

    # ここは厳しめに確認
    if missing or unexpected:
        raise RuntimeError("Checkpoint and model definition still do not match.")

    model.eval()

    dummy = torch.randn(1, 3, args.height, args.width, dtype=torch.float32)

    with torch.no_grad():
        torch.onnx.export(
            model,
            dummy,
            str(output_path),
            export_params=True,
            opset_version=args.opset,
            do_constant_folding=True,
            input_names=["input"],
            output_names=["output"],
            dynamic_axes=None,
        )

    onnx_model = onnx.load(str(output_path))
    onnx.checker.check_model(onnx_model)
    print(f"[OK] Exported ONNX: {output_path}")


if __name__ == "__main__":
    main()