#!/usr/bin/env python3

import argparse
import json
import os
from pathlib import Path
from typing import Dict, List, Tuple

import cv2
import numpy as np
import onnxruntime as ort


COCO_CLASSES = [
    "person", "bicycle", "car", "motorcycle", "airplane", "bus", "train", "truck",
    "boat", "traffic light", "fire hydrant", "stop sign", "parking meter", "bench",
    "bird", "cat", "dog", "horse", "sheep", "cow", "elephant", "bear", "zebra", "giraffe",
    "backpack", "umbrella", "handbag", "tie", "suitcase", "frisbee", "skis", "snowboard",
    "sports ball", "kite", "baseball bat", "baseball glove", "skateboard", "surfboard",
    "tennis racket", "bottle", "wine glass", "cup", "fork", "knife", "spoon", "bowl",
    "banana", "apple", "sandwich", "orange", "broccoli", "carrot", "hot dog", "pizza",
    "donut", "cake", "chair", "couch", "potted plant", "bed", "dining table", "toilet",
    "TV", "laptop", "mouse", "remote", "keyboard", "cell phone", "microwave", "oven",
    "toaster", "sink", "refrigerator", "book", "clock", "vase", "scissors", "teddy bear",
    "hair drier", "toothbrush",
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


def xywh_to_xyxy(boxes: np.ndarray) -> np.ndarray:
    xyxy = np.empty_like(boxes)
    xyxy[:, 0] = boxes[:, 0] - boxes[:, 2] / 2.0
    xyxy[:, 1] = boxes[:, 1] - boxes[:, 3] / 2.0
    xyxy[:, 2] = boxes[:, 0] + boxes[:, 2] / 2.0
    xyxy[:, 3] = boxes[:, 1] + boxes[:, 3] / 2.0
    return xyxy


def postprocess(
    output: np.ndarray,
    original_shape: Tuple[int, int],
    scale: float,
    pad: Tuple[int, int],
    conf_threshold: float,
    nms_threshold: float,
) -> List[Dict]:
    pred = np.squeeze(output)
    if pred.ndim != 2:
        raise ValueError(f"Unexpected YOLO output shape: {output.shape}")
    if pred.shape[0] < pred.shape[1]:
        pred = pred.T

    boxes = xywh_to_xyxy(pred[:, :4])
    scores_all = pred[:, 4:]
    class_ids = np.argmax(scores_all, axis=1)
    scores = scores_all[np.arange(scores_all.shape[0]), class_ids]

    keep = scores >= conf_threshold
    boxes, scores, class_ids = boxes[keep], scores[keep], class_ids[keep]
    if boxes.size == 0:
        return []

    left, top = pad
    boxes[:, [0, 2]] = (boxes[:, [0, 2]] - left) / scale
    boxes[:, [1, 3]] = (boxes[:, [1, 3]] - top) / scale

    image_h, image_w = original_shape
    boxes[:, [0, 2]] = np.clip(boxes[:, [0, 2]], 0, image_w - 1)
    boxes[:, [1, 3]] = np.clip(boxes[:, [1, 3]], 0, image_h - 1)

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

    detections = []
    for idx in np.array(indices).reshape(-1):
        class_id = int(class_ids[idx])
        x, y, w, h = boxes_xywh[idx]
        detections.append({
            "class_id": class_id,
            "class_name": COCO_CLASSES[class_id] if class_id < len(COCO_CLASSES) else str(class_id),
            "score": float(scores[idx]),
            "bbox_xywh": [float(x), float(y), float(w), float(h)],
        })
    return sorted(detections, key=lambda d: d["score"], reverse=True)


def draw_detections(image: np.ndarray, detections: List[Dict]) -> np.ndarray:
    canvas = image.copy()
    for det in detections:
        x, y, w, h = [int(round(v)) for v in det["bbox_xywh"]]
        color = (0, 220, 80)
        cv2.rectangle(canvas, (x, y), (x + w, y + h), color, 2)
        label = f'{det["class_name"]} {det["score"]:.2f}'
        cv2.putText(
            canvas,
            label,
            (x, max(y - 8, 14)),
            cv2.FONT_HERSHEY_SIMPLEX,
            0.55,
            color,
            2,
            cv2.LINE_AA,
        )
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
    parser = argparse.ArgumentParser(description="YOLOv8s file-to-file inference for host CPU or VEK385 NPU.")
    parser.add_argument("--model", default="models/yolov8s.onnx")
    parser.add_argument("--input", required=True, help="Input image file or directory.")
    parser.add_argument("--output_dir", default="output_file2file")
    parser.add_argument("--device", choices=["cpu", "npu"], default="cpu")
    parser.add_argument("--config", default="vitisai_config.json")
    parser.add_argument("--cache_dir", default="compiled")
    parser.add_argument("--cache_key", default="yolov8s_fp32_bf16")
    parser.add_argument("--img_size", type=int, default=640)
    parser.add_argument("--conf_threshold", type=float, default=0.25)
    parser.add_argument("--nms_threshold", type=float, default=0.7)
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
        detections = postprocess(
            output,
            image.shape[:2],
            scale,
            pad,
            args.conf_threshold,
            args.nms_threshold,
        )

        annotated = draw_detections(image, detections)
        out_image = output_dir / f"{image_path.stem}_det{image_path.suffix}"
        cv2.imwrite(str(out_image), annotated)

        all_results.append({
            "input": str(image_path),
            "output": str(out_image),
            "detections": detections,
        })
        print(f"{image_path.name}: {len(detections)} detection(s) -> {out_image}")

    with open(output_dir / "detections.json", "w", encoding="utf-8") as f:
        json.dump(all_results, f, indent=2)
    print(f"wrote {output_dir / 'detections.json'}")


if __name__ == "__main__":
    main()
