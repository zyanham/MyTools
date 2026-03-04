import argparse
import torch
import torch.nn as nn


def pixel_unshuffle(x: torch.Tensor, r: int) -> torch.Tensor:
    n, c, h, w = x.shape
    assert h % r == 0 and w % r == 0
    oh, ow = h // r, w // r
    x = x.contiguous().view(n, c, oh, r, ow, r)
    x = x.permute(0, 1, 3, 5, 2, 4).contiguous()
    return x.view(n, c * (r * r), oh, ow)


def pixel_shuffle(x: torch.Tensor, r: int) -> torch.Tensor:
    n, cr2, oh, ow = x.shape
    assert cr2 % (r * r) == 0
    c = cr2 // (r * r)
    x = x.contiguous().view(n, c, r, r, oh, ow)
    x = x.permute(0, 1, 4, 2, 5, 3).contiguous()
    return x.view(n, c, oh * r, ow * r)


class FFDNetColorKAIR(nn.Module):
    """
    KAIR配布 ffdnet_color.pth のキー形式(model.0, model.2, ...)に合わせた実装。
    入力:  input (N,3,H,W) float32 [0,1]
          sigma (N,1,1,1) float32 (例: 15/255)
    出力:  output (N,3,H,W) float32 [0,1] 近傍
    """
    def __init__(self, nc=96, nb=12, sf=2):
        super().__init__()
        self.sf = sf
        in_nc = 3
        out_nc = 3
        bias = True

        layers = []
        # head
        layers.append(nn.Conv2d(in_nc * sf * sf + 1, nc, 3, 1, 1, bias=bias))
        layers.append(nn.ReLU(inplace=True))
        # body: (nb-2) conv+relu
        for _ in range(nb - 2):
            layers.append(nn.Conv2d(nc, nc, 3, 1, 1, bias=bias))
            layers.append(nn.ReLU(inplace=True))
        # tail
        layers.append(nn.Conv2d(nc, out_nc * sf * sf, 3, 1, 1, bias=bias))

        self.model = nn.Sequential(*layers)

    def forward(self, x: torch.Tensor, sigma: torch.Tensor) -> torch.Tensor:
        n, c, h, w = x.shape
        assert c == 3
        assert h % self.sf == 0 and w % self.sf == 0, "H/W must be divisible by 2"

        x_down = pixel_unshuffle(x, self.sf)  # (N,12,H/2,W/2)

        # sigma: (N,1,1,1) -> (N,1,H/2,W/2)
        m = sigma.repeat(1, 1, x_down.shape[-2], x_down.shape[-1])

        x_cat = torch.cat([x_down, m], dim=1)  # (N,13,H/2,W/2)
        y = self.model(x_cat)                  # (N,12,H/2,W/2)
        out = pixel_shuffle(y, self.sf)        # (N,3,H,W)
        return out


def load_state_dict_compat(path: str):
    # torch.load の互換（古いtorchは weights_only 引数が無い）
    try:
        sd = torch.load(path, map_location="cpu", weights_only=True)
    except TypeError:
        sd = torch.load(path, map_location="cpu")

    # checkpoint辞書の場合に備える
    if isinstance(sd, dict) and "state_dict" in sd and isinstance(sd["state_dict"], dict):
        sd = sd["state_dict"]

    # DataParallelの "module." を剥ぐ
    if isinstance(sd, dict):
        keys = list(sd.keys())
        if keys and keys[0].startswith("module."):
            sd = {k.replace("module.", "", 1): v for k, v in sd.items()}
    return sd


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--weights", default="model_zoo/ffdnet_color.pth")
    ap.add_argument("--h", type=int, default=544)
    ap.add_argument("--w", type=int, default=960)
    ap.add_argument("--out", default="ffdnet_color_544x960_op17.onnx")
    ap.add_argument("--opset", type=int, default=17)
    args = ap.parse_args()

    assert args.h % 2 == 0 and args.w % 2 == 0, "FFDNet requires even H/W"

    model = FFDNetColorKAIR(nc=96, nb=12, sf=2)
    sd = load_state_dict_compat(args.weights)

    # ここで model.* のキーを期待
    model.load_state_dict(sd, strict=True)
    model.eval()

    x = torch.zeros(1, 3, args.h, args.w, dtype=torch.float32)
    sigma = torch.full((1, 1, 1, 1), 15.0 / 255.0, dtype=torch.float32)

    torch.onnx.export(
        model,
        (x, sigma),
        args.out,
        input_names=["input", "sigma"],
        output_names=["output"],
        opset_version=args.opset,
        do_constant_folding=True,
    )

    print("[OK] wrote:", args.out)


if __name__ == "__main__":
    main()