#!/usr/bin/env python3

import argparse
import json
import os
from pathlib import Path
from typing import Dict, List, Tuple

import cv2
import numpy as np
import onnxruntime as ort


KEYPOINT_NAMES = [
    "nose", "left_eye", "right_eye", "left_ear", "right_ear",
    "left_shoulder", "right_shoulder", "left_elbow", "right_elbow",
    "left_wrist", "right_wrist", "left_hip", "right_hip",
    "left_knee", "right_knee", "left_ankle", "right_ankle",
]

SKELETON = [
    (15, 13), (13, 11), (16, 14), (14, 12), (11, 12),
    (5, 11), (6, 12), (5, 6), (5, 7), (6, 8),
    (7, 9), (8, 10), (1, 2), (0, 1), (0, 2),
    (1, 3), (2, 4), (3, 5), (4, 6),
]


def list_images(input_path: Path) -> List[Path]:
    if input_path.is_file():
        return [input_path]
    suffixes = {".jpg", ".jpeg", ".png", ".bmp"}
    return sorted(p for p in input_path.rglob("*") if p.is_file() and p.suffix.lower() in suffixes)


def letterbox(image: np.ndarray, size: int) -> Tuple[np.ndarray, float, Tuple[int, int]]:
    height, width = image.shape[:2]
    scale = min(size / width, size / height)
    resized_w, resized_h = int(round(width * scale)), int(round(height * scale))
    resized = cv2.resize(image, (resized_w, resized_h), interpolation=cv2.INTER_LINEAR)

    pad_w, pad_h = size - resized_w, size - resized_h
    left, top = pad_w // 2, pad_h // 2
    right, bottom = pad_w - left, pad_h - top
    padded = cv2.copyMakeBorder(
        resized,
        top,
        bottom,
        left,
        right,
        cv2.BORDER_CONSTANT,
        value=(114, 114, 114),
    )
    return padded, scale, (left, top)


def preprocess(image: np.ndarray, size: int) -> Tuple[np.ndarray, float, Tuple[int, int]]:
    padded, scale, pad = letterbox(image, size)
    rgb = cv2.cvtColor(padded, cv2.COLOR_BGR2RGB)
    tensor = rgb.astype(np.float32) / 255.0
    tensor = np.transpose(tensor, (2, 0, 1))[None, :, :, :]
    return tensor, scale, pad


def sigmoid(x: np.ndarray) -> np.ndarray:
    return 1.0 / (1.0 + np.exp(-x))


def xywh_to_xyxy(boxes: np.ndarray) -> np.ndarray:
    xyxy = np.empty_like(boxes)
    xyxy[:, 0] = boxes[:, 0] - boxes[:, 2] / 2.0
    xyxy[:, 1] = boxes[:, 1] - boxes[:, 3] / 2.0
    xyxy[:, 2] = boxes[:, 0] + boxes[:, 2] / 2.0
    xyxy[:, 3] = boxes[:, 1] + boxes[:, 3] / 2.0
    return xyxy


def normalize_predictions(output: np.ndarray) -> np.ndarray:
    pred = np.squeeze(output)
    if pred.ndim != 2:
        raise ValueError(f"Unexpected YOLO-Pose output shape: {output.shape}")
    if pred.shape[0] < pred.shape[1]:
        pred = pred.T
    if pred.shape[1] < 56:
        raise ValueError(f"Expected at least 56 prediction values, got shape {pred.shape}")
    return pred


def postprocess(
    output: np.ndarray,
    original_shape: Tuple[int, int],
    scale: float,
    pad: Tuple[int, int],
    conf_threshold: float,
    nms_threshold: float,
    keypoint_threshold: float,
) -> List[Dict]:
    pred = normalize_predictions(output)
    boxes = xywh_to_xyxy(pred[:, :4].astype(np.float32))
    scores = pred[:, 4].astype(np.float32)

    keep = scores >= conf_threshold
    boxes, scores, pred = boxes[keep], scores[keep], pred[keep]
    if boxes.size == 0:
        return []

    left, top = pad
    boxes[:, [0, 2]] = (boxes[:, [0, 2]] - left) / scale
    boxes[:, [1, 3]] = (boxes[:, [1, 3]] - top) / scale

    image_h, image_w = original_shape
    boxes[:, [0, 2]] = np.clip(boxes[:, [0, 2]], 0, image_w - 1)
    boxes[:, [1, 3]] = np.clip(boxes[:, [1, 3]], 0, image_h - 1)

    keypoints = pred[:, 5:56].reshape(-1, 17, 3).astype(np.float32)
    keypoints[:, :, 0] = (keypoints[:, :, 0] - left) / scale
    keypoints[:, :, 1] = (keypoints[:, :, 1] - top) / scale
    keypoints[:, :, 0] = np.clip(keypoints[:, :, 0], 0, image_w - 1)
    keypoints[:, :, 1] = np.clip(keypoints[:, :, 1], 0, image_h - 1)

    if np.nanmax(keypoints[:, :, 2]) > 1.0 or np.nanmin(keypoints[:, :, 2]) < 0.0:
        keypoints[:, :, 2] = sigmoid(keypoints[:, :, 2])

    boxes_xywh = np.column_stack((
        boxes[:, 0],
        boxes[:, 1],
        boxes[:, 2] - boxes[:, 0],
        boxes[:, 3] - boxes[:, 1],
    ))
    indices = cv2.dnn.NMSBoxes(
        boxes_xywh.tolist(),
        scores.astype(float).tolist(),
        conf_threshold,
        nms_threshold,
    )
    if len(indices) == 0:
        return []

    poses = []
    for idx in np.array(indices).reshape(-1):
        named_kpts = []
        for kp_idx, name in enumerate(KEYPOINT_NAMES):
            x, y, conf = keypoints[idx, kp_idx]
            named_kpts.append({
                "index": kp_idx,
                "name": name,
                "x": float(x),
                "y": float(y),
                "confidence": float(conf),
                "visible": bool(conf >= keypoint_threshold),
            })

        x, y, w, h = boxes_xywh[idx]
        poses.append({
            "class_id": 0,
            "class_name": "person",
            "score": float(scores[idx]),
            "bbox_xywh": [float(x), float(y), float(w), float(h)],
            "keypoints": named_kpts,
        })
    return sorted(poses, key=lambda d: d["score"], reverse=True)


def draw_poses(image: np.ndarray, poses: List[Dict], keypoint_threshold: float) -> np.ndarray:
    canvas = image.copy()
    for pose in poses:
        x, y, w, h = [int(round(v)) for v in pose["bbox_xywh"]]
        cv2.rectangle(canvas, (x, y), (x + w, y + h), (0, 220, 80), 2)
        cv2.putText(
            canvas,
            f'person {pose["score"]:.2f}',
            (x, max(y - 8, 14)),
            cv2.FONT_HERSHEY_SIMPLEX,
            0.55,
            (0, 220, 80),
            2,
            cv2.LINE_AA,
        )

        kpts = pose["keypoints"]
        for a, b in SKELETON:
            if kpts[a]["confidence"] >= keypoint_threshold and kpts[b]["confidence"] >= keypoint_threshold:
                pa = (int(round(kpts[a]["x"])), int(round(kpts[a]["y"])))
                pb = (int(round(kpts[b]["x"])), int(round(kpts[b]["y"])))
                cv2.line(canvas, pa, pb, (255, 120, 30), 2, cv2.LINE_AA)
        for kp in kpts:
            if kp["confidence"] >= keypoint_threshold:
                point = (int(round(kp["x"])), int(round(kp["y"])))
                cv2.circle(canvas, point, 3, (30, 30, 255), -1, cv2.LINE_AA)
    return canvas


def create_session(args) -> ort.InferenceSession:
    if args.device == "cpu":
        return ort.InferenceSession(args.model, providers=["CPUExecutionProvider"])

    provider_options = {
        "config_file": os.path.abspath(args.config),
        "cache_dir": os.path.abspath(args.cache_dir),
        "cache_key": args.cache_key,
        "target": "VAIML",
    }
    return ort.InferenceSession(
        args.model,
        providers=["VitisAIExecutionProvider"],
        provider_options=[provider_options],
    )


def main() -> None:
    parser = argparse.ArgumentParser(description="YOLO-Pose file-to-file inference for host CPU or VEK385 NPU.")
    parser.add_argument("--model", default="models/yolo_pose.onnx")
    parser.add_argument("--input", required=True, help="Input image file or directory.")
    parser.add_argument("--output_dir", default="results/file2file")
    parser.add_argument("--device", choices=["cpu", "npu"], default="cpu")
    parser.add_argument("--config", default="vitisai_config.json")
    parser.add_argument("--cache_dir", default="my_cache_dir")
    parser.add_argument("--cache_key", default="yolo_pose_fp32_bf16")
    parser.add_argument("--img_size", type=int, default=640)
    parser.add_argument("--conf_threshold", type=float, default=0.25)
    parser.add_argument("--nms_threshold", type=float, default=0.7)
    parser.add_argument("--keypoint_threshold", type=float, default=0.25)
    args = parser.parse_args()

    input_path = Path(args.input)
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    images = list_images(input_path)
    if not images:
        raise FileNotFoundError(f"No input images found: {input_path}")

    session = create_session(args)
    input_name = session.get_inputs()[0].name
    all_results = []

    for image_path in images:
        image = cv2.imread(str(image_path), cv2.IMREAD_COLOR)
        if image is None:
            print(f"skip unreadable image: {image_path}")
            continue

        tensor, scale, pad = preprocess(image, args.img_size)
        output = session.run(None, {input_name: tensor})[0]
        poses = postprocess(
            output,
            image.shape[:2],
            scale,
            pad,
            args.conf_threshold,
            args.nms_threshold,
            args.keypoint_threshold,
        )

        annotated = draw_poses(image, poses, args.keypoint_threshold)
        out_image = output_dir / f"{image_path.stem}_pose{image_path.suffix}"
        cv2.imwrite(str(out_image), annotated)

        all_results.append({
            "input": str(image_path),
            "output": str(out_image),
            "poses": poses,
        })
        print(f"{image_path.name}: {len(poses)} pose(s) -> {out_image}")

    with open(output_dir / "poses.json", "w", encoding="utf-8") as f:
        json.dump(all_results, f, indent=2)
    print(f"wrote {output_dir / 'poses.json'}")


if __name__ == "__main__":
    main()
