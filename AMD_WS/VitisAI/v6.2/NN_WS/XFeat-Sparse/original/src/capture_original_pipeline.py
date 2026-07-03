#!/usr/bin/env python3

import argparse
import json
import sys
from pathlib import Path
from typing import Dict, Tuple

import cv2
import numpy as np
import torch


def add_repo(repo: Path) -> None:
    repo = repo.resolve()
    if not (repo / "modules" / "xfeat.py").exists():
        raise FileNotFoundError(f"Official XFeat repository not found: {repo}")
    sys.path.insert(0, str(repo))


def read_rgb_tensor(path: Path) -> Tuple[np.ndarray, torch.Tensor]:
    bgr = cv2.imread(str(path), cv2.IMREAD_COLOR)
    if bgr is None:
        raise FileNotFoundError(f"Unable to read image: {path}")
    rgb = cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB)
    tensor = torch.from_numpy(rgb).permute(2, 0, 1)[None].float() / 255.0
    return bgr, tensor


def save_np(path: Path, tensor) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if isinstance(tensor, torch.Tensor):
        array = tensor.detach().cpu().numpy()
    else:
        array = np.asarray(tensor)
    np.save(path, array)


def pad_features(feature: Dict[str, torch.Tensor], top_k: int, image_size: Tuple[int, int]) -> Dict[str, torch.Tensor]:
    keypoints = feature["keypoints"][:top_k]
    descriptors = feature["descriptors"][:top_k]
    scores = feature["scores"][:top_k]
    count = keypoints.shape[0]
    if count < top_k:
        keypoints = torch.cat([keypoints, torch.zeros(top_k - count, 2, device=keypoints.device)], dim=0)
        descriptors = torch.cat([descriptors, torch.zeros(top_k - count, descriptors.shape[-1], device=descriptors.device)], dim=0)
        scores = torch.cat([scores, torch.zeros(top_k - count, device=scores.device)], dim=0)
    return {
        "keypoints": keypoints,
        "descriptors": descriptors,
        "scores": scores,
        "image_size": torch.tensor(image_size, device=keypoints.device, dtype=torch.float32),
        "valid_count": torch.tensor([min(count, top_k)], dtype=torch.int64),
    }


def draw_matches(image0: np.ndarray, image1: np.ndarray, kpts0: np.ndarray, kpts1: np.ndarray, matches: np.ndarray, out_path: Path) -> None:
    h0, w0 = image0.shape[:2]
    h1, w1 = image1.shape[:2]
    canvas = np.full((max(h0, h1), w0 + w1, 3), 245, dtype=np.uint8)
    canvas[:h0, :w0] = image0
    canvas[:h1, w0:w0 + w1] = image1

    rng = np.random.default_rng(20260620)
    for idx0, idx1 in matches[:200]:
        p0 = tuple(np.round(kpts0[idx0]).astype(int))
        p1 = tuple(np.round(kpts1[idx1]).astype(int) + np.array([w0, 0]))
        color = tuple(int(v) for v in rng.integers(40, 240, size=3))
        cv2.circle(canvas, p0, 3, color, -1, cv2.LINE_AA)
        cv2.circle(canvas, p1, 3, color, -1, cv2.LINE_AA)
        cv2.line(canvas, p0, p1, color, 1, cv2.LINE_AA)

    out_path.parent.mkdir(parents=True, exist_ok=True)
    cv2.imwrite(str(out_path), canvas)


def main() -> None:
    parser = argparse.ArgumentParser(description="Run official XFeat+LighterGlue on two images and capture npy vectors.")
    parser.add_argument("--repo", default="third_party/accelerated_features")
    parser.add_argument("--image0", required=True)
    parser.add_argument("--image1", required=True)
    parser.add_argument("--output_dir", default="output_original_host")
    parser.add_argument("--vectors_dir", default="test_vectors")
    parser.add_argument("--top_k", type=int, default=128)
    parser.add_argument("--min_conf", type=float, default=0.1)
    args = parser.parse_args()

    torch.set_grad_enabled(False)
    add_repo(Path(args.repo))
    from modules.xfeat import XFeat
    from modules.lighterglue import LighterGlue

    output_dir = Path(args.output_dir)
    vectors_dir = Path(args.vectors_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    vectors_dir.mkdir(parents=True, exist_ok=True)

    image0_bgr, tensor0 = read_rgb_tensor(Path(args.image0))
    image1_bgr, tensor1 = read_rgb_tensor(Path(args.image1))
    image_size = (image0_bgr.shape[1], image0_bgr.shape[0])

    xfeat = XFeat(weights=str(Path(args.repo) / "weights" / "xfeat.pt"), top_k=args.top_k).eval()
    lighterglue = LighterGlue(weights=str(Path(args.repo) / "weights" / "xfeat-lighterglue.pt")).eval()
    lighterglue.net.conf.width_confidence = -1
    lighterglue.net.conf.depth_confidence = -1
    lighterglue.net.conf.flash = False

    xfeat_inputs = []
    for idx, tensor in enumerate([tensor0, tensor1]):
        preprocessed, rh, rw = xfeat.preprocess_tensor(tensor)
        feats, keypoints, heatmap = xfeat.net(preprocessed)
        xfeat_inputs.append(preprocessed)
        save_np(vectors_dir / f"xfeat_image{idx}_input.npy", preprocessed)
        save_np(vectors_dir / f"xfeat_image{idx}_feats.npy", feats)
        save_np(vectors_dir / f"xfeat_image{idx}_keypoints.npy", keypoints)
        save_np(vectors_dir / f"xfeat_image{idx}_heatmap.npy", heatmap)

    sparse0 = xfeat.detectAndCompute(tensor0, top_k=args.top_k)[0]
    sparse1 = xfeat.detectAndCompute(tensor1, top_k=args.top_k)[0]
    fixed0 = pad_features(sparse0, args.top_k, image_size)
    fixed1 = pad_features(sparse1, args.top_k, image_size)

    save_np(vectors_dir / "lighterglue_keypoints0.npy", fixed0["keypoints"][None])
    save_np(vectors_dir / "lighterglue_keypoints1.npy", fixed1["keypoints"][None])
    save_np(vectors_dir / "lighterglue_descriptors0.npy", fixed0["descriptors"][None])
    save_np(vectors_dir / "lighterglue_descriptors1.npy", fixed1["descriptors"][None])
    save_np(vectors_dir / "lighterglue_image_size0.npy", fixed0["image_size"][None])
    save_np(vectors_dir / "lighterglue_image_size1.npy", fixed1["image_size"][None])
    save_np(vectors_dir / "lighterglue_scores0_input.npy", fixed0["scores"][None])
    save_np(vectors_dir / "lighterglue_scores1_input.npy", fixed1["scores"][None])
    save_np(vectors_dir / "lighterglue_valid_count0.npy", fixed0["valid_count"])
    save_np(vectors_dir / "lighterglue_valid_count1.npy", fixed1["valid_count"])

    data = {
        "keypoints0": fixed0["keypoints"][None],
        "keypoints1": fixed1["keypoints"][None],
        "descriptors0": fixed0["descriptors"][None],
        "descriptors1": fixed1["descriptors"][None],
        "image_size0": fixed0["image_size"][None],
        "image_size1": fixed1["image_size"][None],
    }
    out = lighterglue(data, min_conf=args.min_conf)
    for name in ["log_assignment", "matches0", "matches1", "matching_scores0", "matching_scores1", "prune0", "prune1"]:
        save_np(vectors_dir / f"lighterglue_{name}.npy", out[name])

    matches = out["matches"][0].detach().cpu().numpy()
    kpts0 = fixed0["keypoints"].detach().cpu().numpy()
    kpts1 = fixed1["keypoints"].detach().cpu().numpy()
    draw_matches(image0_bgr, image1_bgr, kpts0, kpts1, matches, output_dir / "matches_lighterglue.png")

    summary = {
        "image0": args.image0,
        "image1": args.image1,
        "top_k": args.top_k,
        "xfeat_input_shape": list(xfeat_inputs[0].shape),
        "sparse0_detected": int(sparse0["keypoints"].shape[0]),
        "sparse1_detected": int(sparse1["keypoints"].shape[0]),
        "lighterglue_matches": int(matches.shape[0]),
        "vectors_dir": str(vectors_dir),
    }
    with open(output_dir / "summary.json", "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2)
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
