#!/usr/bin/env python3

from typing import Optional, Tuple, Union

import torch
import torch.nn as nn
import torch.nn.functional as F


class ConvBNReLU(nn.Module):
    def __init__(
        self,
        in_channels: int,
        out_channels: int,
        kernel_size: Union[int, Tuple[int, int]] = 1,
        stride: int = 1,
        padding: Optional[int] = None,
        groups: int = 1,
        dilation: int = 1,
        inplace: bool = True,
        bias: bool = False,
    ) -> None:
        super().__init__()
        if padding is None:
            padding = kernel_size // 2 if isinstance(kernel_size, int) else [x // 2 for x in kernel_size]
        self.conv = nn.Conv2d(
            in_channels,
            out_channels,
            kernel_size,
            stride=stride,
            padding=padding,
            dilation=dilation,
            groups=groups,
            bias=bias,
        )
        self.norm = nn.BatchNorm2d(out_channels)
        self.relu = nn.ReLU(inplace=inplace)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        return self.relu(self.norm(self.conv(x)))


class DoubleConv(nn.Module):
    def __init__(
        self,
        in_channels: int,
        out_channels: int,
        mid_channels: Optional[int] = None,
        kernel_size: int = 3,
        stride: int = 1,
        padding: int = 1,
        dilation: int = 1,
        groups: int = 1,
        bias: bool = False,
    ) -> None:
        super().__init__()
        if not mid_channels:
            mid_channels = out_channels
        self.conv1 = ConvBNReLU(in_channels, mid_channels, kernel_size, stride, padding, groups, dilation, bias=bias)
        self.conv2 = ConvBNReLU(mid_channels, out_channels, kernel_size, stride, padding, groups, dilation, bias=bias)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        return self.conv2(self.conv1(x))


class Down(nn.Module):
    def __init__(self, in_channels: int, out_channels: int, scale_factor=2) -> None:
        super().__init__()
        self.pool = nn.MaxPool2d(kernel_size=scale_factor)
        self.conv = DoubleConv(in_channels, out_channels)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        return self.conv(self.pool(x))


class Up(nn.Module):
    def __init__(self, in_channels: int, out_channels: int, bilinear: bool = True) -> None:
        super().__init__()
        if bilinear:
            self.up = nn.Upsample(scale_factor=2, mode="bilinear", align_corners=True)
            self.conv = DoubleConv(in_channels, out_channels, mid_channels=out_channels // 2)
        else:
            self.up = nn.ConvTranspose2d(in_channels, in_channels // 2, kernel_size=2, stride=2)
            self.conv = DoubleConv(in_channels, out_channels)

    def forward(self, x1: torch.Tensor, x2: torch.Tensor) -> torch.Tensor:
        x1 = self.up(x1)
        diff_y = x2.size()[2] - x1.size()[2]
        diff_x = x2.size()[3] - x1.size()[3]
        x1 = F.pad(x1, [diff_x // 2, diff_x - diff_x // 2, diff_y // 2, diff_y - diff_y // 2])
        return self.conv(torch.cat([x2, x1], dim=1))


class UNet(nn.Module):
    def __init__(self, in_channels: int, num_classes: int, bilinear: bool = False) -> None:
        super().__init__()
        self.in_channels = in_channels
        self.num_classes = num_classes
        self.bilinear = bilinear
        self.input_conv = DoubleConv(in_channels, 64)
        factor = 2 if bilinear else 1
        self.down1 = Down(64, 128, scale_factor=2)
        self.down2 = Down(128, 256, scale_factor=2)
        self.down3 = Down(256, 512, scale_factor=2)
        self.down4 = Down(512, 1024 // factor, scale_factor=2)
        self.up1 = Up(1024, 512 // factor, bilinear=bilinear)
        self.up2 = Up(512, 256 // factor, bilinear=bilinear)
        self.up3 = Up(256, 128 // factor, bilinear=bilinear)
        self.up4 = Up(128, 64, bilinear=bilinear)
        self.output_conv = nn.Conv2d(64, num_classes, kernel_size=1)

    def forward(self, x):
        x0 = self.input_conv(x)
        x1 = self.down1(x0)
        x2 = self.down2(x1)
        x3 = self.down3(x2)
        x4 = self.down4(x3)
        x = self.up1(x4, x3)
        x = self.up2(x, x2)
        x = self.up3(x, x1)
        x = self.up4(x, x0)
        return self.output_conv(x)


def load_carvana_unet(weights_path: str, device: str = "cpu") -> UNet:
    model = UNet(in_channels=3, num_classes=2)
    state_dict = torch.load(weights_path, map_location=device)
    state_dict = {k: v.float() for k, v in state_dict.items()}
    model.load_state_dict(state_dict)
    model.to(device)
    model.eval()
    return model
