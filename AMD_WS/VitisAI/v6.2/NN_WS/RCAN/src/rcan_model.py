#!/usr/bin/env python3

import math
from dataclasses import dataclass
from typing import Dict

import torch
import torch.nn as nn


@dataclass
class RCANConfig:
    scale: int = 2
    n_resgroups: int = 10
    n_resblocks: int = 20
    n_feats: int = 64
    reduction: int = 16
    n_colors: int = 3
    rgb_range: int = 255
    data_train: str = "DIV2K"
    res_scale: float = 1.0


def default_conv(in_channels: int, out_channels: int, kernel_size: int, bias: bool = True) -> nn.Conv2d:
    return nn.Conv2d(in_channels, out_channels, kernel_size, padding=kernel_size // 2, bias=bias)


class MeanShift(nn.Conv2d):
    def __init__(self, rgb_range: int, rgb_mean, rgb_std, sign: int = -1):
        super().__init__(3, 3, kernel_size=1)
        std = torch.tensor(rgb_std)
        self.weight.data = torch.eye(3).view(3, 3, 1, 1)
        self.weight.data.div_(std.view(3, 1, 1, 1))
        self.bias.data = sign * rgb_range * torch.tensor(rgb_mean)
        self.bias.data.div_(std)
        for parameter in self.parameters():
            parameter.requires_grad = False


class Upsampler(nn.Sequential):
    def __init__(self, scale: int, n_feats: int):
        modules = []
        if (scale & (scale - 1)) == 0:
            for _ in range(int(math.log(scale, 2))):
                modules.append(default_conv(n_feats, 4 * n_feats, 3))
                modules.append(nn.PixelShuffle(2))
        elif scale == 3:
            modules.append(default_conv(n_feats, 9 * n_feats, 3))
            modules.append(nn.PixelShuffle(3))
        else:
            raise NotImplementedError(f"Unsupported RCAN scale: {scale}")
        super().__init__(*modules)


class CALayer(nn.Module):
    def __init__(self, channel: int, reduction: int = 16):
        super().__init__()
        self.avg_pool = nn.AdaptiveAvgPool2d(1)
        self.conv_du = nn.Sequential(
            nn.Conv2d(channel, channel // reduction, 1, padding=0, bias=True),
            nn.ReLU(inplace=True),
            nn.Conv2d(channel // reduction, channel, 1, padding=0, bias=True),
            nn.Sigmoid(),
        )

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        y = self.avg_pool(x)
        y = self.conv_du(y)
        return x * y


class RCAB(nn.Module):
    def __init__(self, n_feats: int, reduction: int):
        super().__init__()
        self.body = nn.Sequential(
            default_conv(n_feats, n_feats, 3),
            nn.ReLU(inplace=True),
            default_conv(n_feats, n_feats, 3),
            CALayer(n_feats, reduction),
        )

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        return self.body(x) + x


class ResidualGroup(nn.Module):
    def __init__(self, n_feats: int, reduction: int, n_resblocks: int):
        super().__init__()
        blocks = [RCAB(n_feats, reduction) for _ in range(n_resblocks)]
        blocks.append(default_conv(n_feats, n_feats, 3))
        self.body = nn.Sequential(*blocks)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        return self.body(x) + x


class RCAN(nn.Module):
    def __init__(self, config: RCANConfig):
        super().__init__()
        if config.data_train == "DIVFlickr2K":
            rgb_mean = (0.4690, 0.4490, 0.4036)
        else:
            rgb_mean = (0.4488, 0.4371, 0.4040)
        rgb_std = (1.0, 1.0, 1.0)

        self.sub_mean = MeanShift(config.rgb_range, rgb_mean, rgb_std)
        self.add_mean = MeanShift(config.rgb_range, rgb_mean, rgb_std, 1)
        self.head = nn.Sequential(default_conv(config.n_colors, config.n_feats, 3))
        body = [
            ResidualGroup(config.n_feats, config.reduction, config.n_resblocks)
            for _ in range(config.n_resgroups)
        ]
        body.append(default_conv(config.n_feats, config.n_feats, 3))
        self.body = nn.Sequential(*body)
        self.tail = nn.Sequential(
            Upsampler(config.scale, config.n_feats),
            default_conv(config.n_feats, config.n_colors, 3),
        )

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        x = self.sub_mean(x)
        x = self.head(x)
        res = self.body(x) + x
        x = self.tail(res)
        return self.add_mean(x)


def normalize_state_dict(raw) -> Dict[str, torch.Tensor]:
    if isinstance(raw, dict):
        for key in ("state_dict", "model", "net", "params"):
            if key in raw and isinstance(raw[key], dict):
                raw = raw[key]
                break
    if not isinstance(raw, dict):
        raise TypeError("Checkpoint is not a PyTorch state_dict-like object.")

    result = {}
    for key, value in raw.items():
        if not torch.is_tensor(value):
            continue
        clean_key = key
        for prefix in ("module.", "model."):
            if clean_key.startswith(prefix):
                clean_key = clean_key[len(prefix):]
        result[clean_key] = value
    return result


def load_rcan_weights(model: RCAN, weights_path: str, strict: bool = True) -> None:
    raw = torch.load(weights_path, map_location="cpu")
    state_dict = normalize_state_dict(raw)
    missing, unexpected = model.load_state_dict(state_dict, strict=False)
    if strict and (missing or unexpected):
        raise RuntimeError(f"RCAN weight mismatch. missing={missing}, unexpected={unexpected}")
    if missing:
        print(f"warning: missing keys: {len(missing)}")
    if unexpected:
        print(f"warning: unexpected keys: {len(unexpected)}")
