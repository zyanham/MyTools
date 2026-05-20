from pathlib import Path
import os
import cv2
import numpy as np
import onnxruntime as ort

VOC_CLASSES = [
    "background", "aeroplane", "bicycle", "bird", "boat",
    "bottle", "bus", "car", "cat", "chair", "cow",
    "diningtable", "dog", "horse", "motorbike", "person",
    "pottedplant", "sheep", "sofa", "train", "tvmonitor"
]

# BGR
PALETTE = np.array([
    [0, 0, 0],
    [128, 0, 0],
    [0, 128, 0],
    [128, 128, 0],
    [0, 0, 128],
    [128, 0, 128],
    [0, 128, 128],
    [128, 128, 128],
    [64, 0, 0],
    [192, 0, 0],
    [64, 128, 0],
    [192, 128, 0],
    [64, 0, 128],
    [192, 0, 128],
    [64, 128, 128],
    [192, 128, 128],
    [0, 64, 0],
    [128, 64, 0],
    [0, 192, 0],
    [128, 192, 0],
    [0, 64, 128],
], dtype=np.uint8)


def build_session(
    onnx_path,
    config_path,
    cache_dir,
    cache_key="lraspp_mnv3_bf16_op17_512",
    report_file=None,
):
    cache_dir = Path(cache_dir)
    cache_dir.mkdir(parents=True, exist_ok=True)

    if report_file is not None:
        os.environ["XLNX_ONNX_EP_REPORT_FILE"] = str(report_file)

    provider_options = {
        "config_file": str(config_path),
        "cache_dir": str(cache_dir),
        "cache_key": cache_key,
        "enable_cache_file_io_in_mem": "0",
    }

    sess = ort.InferenceSession(
        str(onnx_path),
        providers=["VitisAIExecutionProvider", "CPUExecutionProvider"],
        provider_options=[provider_options, {}],
    )
    return sess


def preprocess_bgr(img_bgr, size=512):
    img_rgb = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
    img_rgb = cv2.resize(img_rgb, (size, size), interpolation=cv2.INTER_LINEAR)

    x = img_rgb.astype(np.float32) / 255.0

    mean = np.array([0.485, 0.456, 0.406], dtype=np.float32)
    std = np.array([0.229, 0.224, 0.225], dtype=np.float32)
    x = (x - mean) / std

    x = x.transpose(2, 0, 1)[None, :, :, :]
    return np.ascontiguousarray(x.astype(np.float32))


def infer_mask(sess, img_bgr, input_size=512):
    input_name = sess.get_inputs()[0].name
    x = preprocess_bgr(img_bgr, size=input_size)
    outputs = sess.run(None, {input_name: x})
    logits = outputs[0]
    mask_512 = np.argmax(logits, axis=1)[0].astype(np.uint8)
    return logits, mask_512


def make_overlay(img_bgr, mask_512, alpha=0.45):
    h, w = img_bgr.shape[:2]
    mask = cv2.resize(mask_512, (w, h), interpolation=cv2.INTER_NEAREST)

    color_mask = PALETTE[mask]
    overlay = cv2.addWeighted(img_bgr, 1.0 - alpha, color_mask, alpha, 0.0)

    bg = (mask == 0)
    overlay[bg] = img_bgr[bg]

    return overlay, mask


def summarize_classes(mask, min_ratio_percent=0.05):
    ids, counts = np.unique(mask, return_counts=True)
    total = mask.size
    items = []

    for cls_id, count in zip(ids, counts):
        ratio = count / total * 100.0
        if ratio < min_ratio_percent:
            continue
        name = VOC_CLASSES[cls_id] if cls_id < len(VOC_CLASSES) else f"class_{cls_id}"
        items.append((int(cls_id), name, float(ratio)))

    items.sort(key=lambda x: x[2], reverse=True)
    return items


def draw_class_legend(img_bgr, class_items, max_lines=6):
    out = img_bgr.copy()
    lines = []
    for cls_id, name, ratio in class_items[:max_lines]:
        lines.append(f"{name}: {ratio:.1f}%")

    if not lines:
        return out

    x0, y0 = 10, 25
    line_h = 24

    box_w = 260
    box_h = 10 + line_h * len(lines)

    cv2.rectangle(out, (x0 - 5, y0 - 20), (x0 - 5 + box_w, y0 - 20 + box_h), (0, 0, 0), -1)
    cv2.rectangle(out, (x0 - 5, y0 - 20), (x0 - 5 + box_w, y0 - 20 + box_h), (255, 255, 255), 1)

    for i, line in enumerate(lines):
        y = y0 + i * line_h
        cv2.putText(out, line, (x0, y), cv2.FONT_HERSHEY_SIMPLEX, 0.65, (255, 255, 255), 2, cv2.LINE_AA)

    return out


def save_mask_as_png(mask, out_path):
    cv2.imwrite(str(out_path), mask)