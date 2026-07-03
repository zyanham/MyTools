#!/usr/bin/env python3

import argparse
import sys
from pathlib import Path

import numpy as np
import onnx
import torch
import torch.nn as nn
import torch.nn.functional as F


def add_repo(repo: Path) -> None:
    repo = repo.resolve()
    if not (repo / "modules" / "lighterglue.py").exists():
        raise FileNotFoundError(f"Official XFeat repository not found: {repo}")
    sys.path.insert(0, str(repo))


class LighterGlueOnnxWrapper(nn.Module):
    def __init__(self, lighterglue: nn.Module, min_conf: float):
        super().__init__()
        self.net = lighterglue.net
        self.min_conf = min_conf
        self.net.conf.width_confidence = -1
        self.net.conf.depth_confidence = -1
        self.net.conf.filter_threshold = min_conf
        self.net.conf.flash = False

    @staticmethod
    def normalize_keypoints(kpts, size):
        shift = size.float() / 2.0
        scale = torch.max(size.float(), dim=1).values / 2.0
        return (kpts - shift[:, None, :]) / scale[:, None, None]

    @staticmethod
    def rotate_half(x):
        b, h, n, d = x.shape
        x = x.reshape(b, h, n, d // 2, 2)
        x1 = x[..., 0]
        x2 = x[..., 1]
        return torch.stack((-x2, x1), dim=4).reshape(b, h, n, d)

    def apply_rotary(self, encoding, x):
        return (x * encoding[0]) + (self.rotate_half(x) * encoding[1])

    @staticmethod
    def softmax4_last(x):
        shifted = x - torch.max(x, dim=3, keepdim=True).values
        exp = torch.exp(shifted)
        return exp / torch.sum(exp, dim=3, keepdim=True)

    @staticmethod
    def log_softmax3_last(x):
        shifted = x - torch.max(x, dim=2, keepdim=True).values
        return shifted - torch.log(torch.sum(torch.exp(shifted), dim=2, keepdim=True))

    @staticmethod
    def attention(q, k, v):
        scale = q.shape[-1] ** -0.5
        sim = torch.matmul(q, k.permute(0, 1, 3, 2)) * scale
        attn = LighterGlueOnnxWrapper.softmax4_last(sim)
        return torch.matmul(attn, v)

    def self_block(self, block, x, encoding):
        b, n, _ = x.shape
        qkv = block.Wqkv(x)
        qkv = qkv.reshape(b, n, block.num_heads, block.head_dim, 3).permute(0, 2, 1, 3, 4)
        q = qkv[..., 0]
        k = qkv[..., 1]
        v = qkv[..., 2]
        q = self.apply_rotary(encoding, q)
        k = self.apply_rotary(encoding, k)
        context = self.attention(q, k, v)
        message = block.out_proj(context.permute(0, 2, 1, 3).reshape(b, n, block.embed_dim))
        return x + block.ffn(torch.cat([x, message], dim=2))

    def cross_block(self, block, x0, x1):
        b, m, _ = x0.shape
        _, n, _ = x1.shape
        heads = block.heads
        dim_head = block.to_qk.out_features // heads

        qk0 = block.to_qk(x0).reshape(b, m, heads, dim_head).permute(0, 2, 1, 3)
        qk1 = block.to_qk(x1).reshape(b, n, heads, dim_head).permute(0, 2, 1, 3)
        v0 = block.to_v(x0).reshape(b, m, heads, dim_head).permute(0, 2, 1, 3)
        v1 = block.to_v(x1).reshape(b, n, heads, dim_head).permute(0, 2, 1, 3)

        qk0 = qk0 * (block.scale ** 0.5)
        qk1 = qk1 * (block.scale ** 0.5)
        sim = torch.matmul(qk0, qk1.permute(0, 1, 3, 2))
        attn01 = self.softmax4_last(sim)
        attn10 = self.softmax4_last(sim.permute(0, 1, 3, 2))
        m0 = torch.matmul(attn01, v1)
        m1 = torch.matmul(attn10, v0)

        m0 = m0.permute(0, 2, 1, 3).reshape(b, m, heads * dim_head)
        m1 = m1.permute(0, 2, 1, 3).reshape(b, n, heads * dim_head)
        m0 = block.to_out(m0)
        m1 = block.to_out(m1)
        x0 = x0 + block.ffn(torch.cat([x0, m0], dim=2))
        x1 = x1 + block.ffn(torch.cat([x1, m1], dim=2))
        return x0, x1

    def assignment(self, assign, desc0, desc1):
        mdesc0 = assign.final_proj(desc0)
        mdesc1 = assign.final_proj(desc1)
        d = mdesc0.shape[-1]
        mdesc0 = mdesc0 / (d ** 0.25)
        mdesc1 = mdesc1 / (d ** 0.25)
        sim = torch.matmul(mdesc0, mdesc1.permute(0, 2, 1))
        z0 = assign.matchability(desc0)
        z1 = assign.matchability(desc1)

        certainties = F.logsigmoid(z0) + F.logsigmoid(z1).permute(0, 2, 1)
        scores0 = self.log_softmax3_last(sim)
        scores1 = self.log_softmax3_last(sim.permute(0, 2, 1)).permute(0, 2, 1)
        main = scores0 + scores1 + certainties
        dust0 = F.logsigmoid(-z0)
        top = torch.cat([main, dust0], dim=2)
        dust1 = F.logsigmoid(-z1.reshape(z1.shape[0], z1.shape[1]))
        corner = torch.zeros((dust1.shape[0], 1), dtype=dust1.dtype, device=dust1.device)
        bottom = torch.cat([dust1, corner], dim=1).unsqueeze(1)
        return torch.cat([top, bottom], dim=1)

    def forward(self, keypoints0, keypoints1, descriptors0, descriptors1, image_size0, image_size1):
        kpts0 = self.normalize_keypoints(keypoints0, image_size0)
        kpts1 = self.normalize_keypoints(keypoints1, image_size1)
        desc0 = descriptors0.contiguous()
        desc1 = descriptors1.contiguous()

        desc0 = self.net.input_proj(desc0)
        desc1 = self.net.input_proj(desc1)
        encoding0 = self.net.posenc(kpts0)
        encoding1 = self.net.posenc(kpts1)

        last_idx = 0
        for i in range(self.net.conf.n_layers):
            layer = self.net.transformers[i]
            desc0 = self.self_block(layer.self_attn, desc0, encoding0)
            desc1 = self.self_block(layer.self_attn, desc1, encoding1)
            desc0, desc1 = self.cross_block(layer.cross_attn, desc0, desc1)
            last_idx = i

        return self.assignment(self.net.log_assignment[last_idx], desc0, desc1)


def load_tensor(vectors_dir: Path, name: str) -> torch.Tensor:
    return torch.from_numpy(np.load(vectors_dir / name)).float()


def main() -> None:
    parser = argparse.ArgumentParser(description="Export official LighterGlue matcher to ONNX with fixed-size inputs.")
    parser.add_argument("--repo", default="../original/third_party/accelerated_features")
    parser.add_argument("--weights", default="../original/third_party/accelerated_features/weights/xfeat-lighterglue.pt")
    parser.add_argument("--vectors_dir", default="../original/test_vectors")
    parser.add_argument("--output", default="models/lighterglue_model.onnx")
    parser.add_argument("--opset", type=int, default=17)
    parser.add_argument("--min_conf", type=float, default=0.1)
    parser.add_argument("--dynamo", action="store_true", help="Use the PyTorch dynamo ONNX exporter.")
    args = parser.parse_args()

    add_repo(Path(args.repo))
    from modules.lighterglue import LighterGlue

    vectors_dir = Path(args.vectors_dir)
    inputs = (
        load_tensor(vectors_dir, "lighterglue_keypoints0.npy"),
        load_tensor(vectors_dir, "lighterglue_keypoints1.npy"),
        load_tensor(vectors_dir, "lighterglue_descriptors0.npy"),
        load_tensor(vectors_dir, "lighterglue_descriptors1.npy"),
        load_tensor(vectors_dir, "lighterglue_image_size0.npy"),
        load_tensor(vectors_dir, "lighterglue_image_size1.npy"),
    )

    lighterglue = LighterGlue(weights=args.weights).eval()
    wrapper = LighterGlueOnnxWrapper(lighterglue, args.min_conf).eval()

    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)

    torch.onnx.export(
        wrapper,
        inputs,
        str(output),
        input_names=[
            "keypoints0",
            "keypoints1",
            "descriptors0",
            "descriptors1",
            "image_size0",
            "image_size1",
        ],
        output_names=["log_assignment"],
        opset_version=args.opset,
        do_constant_folding=True,
        dynamic_axes=None,
        dynamo=args.dynamo,
    )

    onnx_model = onnx.load(str(output))
    onnx.checker.check_model(onnx_model)
    print(f"exported: {output}")
    print(f"fixed keypoints0 shape: {list(inputs[0].shape)}")


if __name__ == "__main__":
    main()
