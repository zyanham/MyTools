import argparse
import os
import sys
import pathlib
import cv2
import numpy as np
import onnxruntime as ort

ROOT = pathlib.Path(__file__).resolve().parent
sys.path.append(str(ROOT))

from yolox.data.data_augment import preproc as preprocess
from yolox.utils import demo_postprocess, multiclass_nms, vis
from yolox.data.datasets.coco_classes import COCO_CLASSES
from pathlib import Path

def sigmoid(x):
    return 1.0 / (1.0 + np.exp(-x))


def postprocess(outputs, input_shape, ratio, score_thr=0.3, nms_thr=0.45):
    # BF16版のオリジナルYOLOX exportは 1出力 [1, 8400, 85]
    if isinstance(outputs, (list, tuple)):
        if len(outputs) == 1 and outputs[0].ndim == 3 and outputs[0].shape[-1] == 85:
            outputs = outputs[0]
        else:
            # 旧来の3出力モデルにも対応
            outputs = [out.reshape(*out.shape[:2], -1).transpose(0, 2, 1) for out in outputs]
            outputs = np.concatenate(outputs, axis=1)

    outputs[..., 4:] = sigmoid(outputs[..., 4:])
    predictions = demo_postprocess(outputs, input_shape, p6=False)[0]

    boxes = predictions[:, :4]
    scores = predictions[:, 4:5] * predictions[:, 5:]

    boxes_xyxy = np.ones_like(boxes)
    boxes_xyxy[:, 0] = boxes[:, 0] - boxes[:, 2] / 2.0
    boxes_xyxy[:, 1] = boxes[:, 1] - boxes[:, 3] / 2.0
    boxes_xyxy[:, 2] = boxes[:, 0] + boxes[:, 2] / 2.0
    boxes_xyxy[:, 3] = boxes[:, 1] + boxes[:, 3] / 2.0
    boxes_xyxy /= ratio

    dets = multiclass_nms(boxes_xyxy, scores, nms_thr=nms_thr, score_thr=score_thr)
    return dets


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("-m", "--model", required=True)
    ap.add_argument("-i", "--image", required=True)
    ap.add_argument("-o", "--output", default="bf16_out.jpg")
    ap.add_argument("--config_file", default="vai_ep_config.json")
    ap.add_argument("--score_thr", type=float, default=0.3)
    ap.add_argument("--input_shape", default="640,640")
    ap.add_argument("--cpu", action="store_true")
    args = ap.parse_args()

    input_shape = tuple(map(int, args.input_shape.split(",")))

    img_bgr = cv2.imread(args.image)
    if img_bgr is None:
        raise FileNotFoundError(args.image)

    img, ratio = preprocess(img_bgr, input_shape)

    sess_options = ort.SessionOptions()
    sess_options.log_severity_level = 1

    vai_ep_options = {
        "config_file": args.config_file,
    }

    if args.cpu:
        session = ort.InferenceSession(
            args.model,
            providers=["CPUExecutionProvider"],
        )
    else:
        provider_options = {
            "config_file": args.config_file,
            "target": "VAIML",
            "cache_dir": "vaip_cache",
            "cache_key": Path(args.model).stem,
            "log_level": "info",
        }
    
        session = ort.InferenceSession(
            args.model,
            providers=["VitisAIExecutionProvider", "CPUExecutionProvider"],
            provider_options=[provider_options, {}],
        )

    print("Active providers:", session.get_providers())
    print("Input shape from model:", session.get_inputs()[0].shape)

    # ここ重要: オリジナル YOLOX export は NCHW のまま渡す
    ort_inputs = {session.get_inputs()[0].name: img[None, :, :, :]}
    outputs = session.run(None, ort_inputs)

    for idx, out in enumerate(outputs):
        arr = np.asarray(out)
        print(
            f"raw output[{idx}] shape={arr.shape} dtype={arr.dtype} "
            f"min={arr.min():.6f} max={arr.max():.6f} mean={arr.mean():.6f}"
        )

    dets = postprocess(outputs, input_shape, ratio, score_thr=args.score_thr)

    out_img = img_bgr.copy()
    if dets is None:
        print("No detections")
    else:
        print("Detections:", len(dets))
        print("Top scores:", dets[:10, 4])
        print("Top classes:", dets[:10, 5])
        final_boxes, final_scores, final_cls_inds = dets[:, :4], dets[:, 4], dets[:, 5]
        out_img = vis(
            out_img,
            final_boxes,
            final_scores,
            final_cls_inds,
            conf=args.score_thr,
            class_names=COCO_CLASSES,
        )

    cv2.imwrite(args.output, out_img)
    print("Saved:", args.output)


if __name__ == "__main__":
    main()