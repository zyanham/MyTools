import argparse
import pathlib
import sys
import time

import cv2
import numpy as np
import onnxruntime as ort

ROOT = pathlib.Path(__file__).resolve().parent
sys.path.append(str(ROOT / "original_yolox"))

from yolox.data.data_augment import preproc as preprocess
from yolox.utils import demo_postprocess, multiclass_nms, vis
from yolox.data.datasets.coco_classes import COCO_CLASSES

PERSON_CLASS_ID = 0  # COCOの person


def sigmoid(x):
    return 1.0 / (1.0 + np.exp(-x))


def postprocess(outputs, input_shape, ratio, score_thr=0.35, nms_thr=0.45):
    # オリジナルYOLOX export は 1出力 [1, 8400, 85]
    if isinstance(outputs, (list, tuple)):
        if len(outputs) == 1 and outputs[0].ndim == 3 and outputs[0].shape[-1] == 85:
            outputs = outputs[0]
        else:
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


def count_persons(final_scores, final_cls_inds, count_thr):
    final_scores = np.asarray(final_scores, dtype=np.float32)
    final_cls_inds = np.asarray(final_cls_inds, dtype=np.int32)
    return int(np.sum((final_cls_inds == PERSON_CLASS_ID) & (final_scores >= count_thr)))


def filter_person_only(final_boxes, final_scores, final_cls_inds, count_thr):
    final_scores = np.asarray(final_scores, dtype=np.float32)
    final_cls_inds = np.asarray(final_cls_inds, dtype=np.int32)
    keep = (final_cls_inds == PERSON_CLASS_ID) & (final_scores >= count_thr)
    return final_boxes[keep], final_scores[keep], final_cls_inds[keep]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("-m", "--model", required=True)
    ap.add_argument("--config_file", default="vai_ep_config.json")
    ap.add_argument("--camera_id", type=int, default=0)
    ap.add_argument("--input_shape", default="640,640")
    ap.add_argument("--score_thr", type=float, default=0.35)
    ap.add_argument("--nms_thr", type=float, default=0.45)
    ap.add_argument("--count-person", action="store_true")
    ap.add_argument("--count-thr", type=float, default=0.40)
    ap.add_argument("--show-all-boxes", action="store_true")
    args = ap.parse_args()

    input_shape = tuple(map(int, args.input_shape.split(",")))

    sess_options = ort.SessionOptions()
    sess_options.log_severity_level = 3

    vai_ep_options = {
        "config_file": args.config_file,
    }

    session = ort.InferenceSession(
        args.model,
        sess_options=sess_options,
        providers=["VitisAIExecutionProvider", "CPUExecutionProvider"],
        provider_options=[vai_ep_options, {}],
    )

    print("Active providers:", session.get_providers())
    print("Input shape from model:", session.get_inputs()[0].shape)

    cap = cv2.VideoCapture(args.camera_id, cv2.CAP_DSHOW)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)
    cap.set(cv2.CAP_PROP_BUFFERSIZE, 1)

    if not cap.isOpened():
        raise RuntimeError("Failed to open webcam")

    fps = 0.0

    while True:
        ok, frame = cap.read()
        if not ok:
            break

        img, ratio = preprocess(frame, input_shape)

        t0 = time.time()
        ort_inputs = {session.get_inputs()[0].name: img[None, :, :, :]}  # NCHW
        outputs = session.run(None, ort_inputs)
        dets = postprocess(
            outputs,
            input_shape,
            ratio,
            score_thr=args.score_thr,
            nms_thr=args.nms_thr,
        )
        t1 = time.time()

        inst_fps = 1.0 / max(t1 - t0, 1e-6)
        fps = inst_fps if fps == 0.0 else (0.9 * fps + 0.1 * inst_fps)

        vis_img = frame.copy()
        person_count = 0

        if dets is not None:
            final_boxes = dets[:, :4]
            final_scores = dets[:, 4]
            final_cls_inds = dets[:, 5]

            if args.count_person:
                person_count = count_persons(final_scores, final_cls_inds, args.count_thr)

            if args.show_all_boxes:
                draw_boxes, draw_scores, draw_cls = final_boxes, final_scores, final_cls_inds
            else:
                draw_boxes, draw_scores, draw_cls = filter_person_only(
                    final_boxes, final_scores, final_cls_inds, args.count_thr
                )

            if len(draw_boxes) > 0:
                vis_img = vis(
                    vis_img,
                    draw_boxes,
                    draw_scores,
                    draw_cls,
                    conf=args.score_thr,
                    class_names=COCO_CLASSES,
                )

        cv2.putText(
            vis_img,
            f"FPS: {fps:.1f}",
            (20, 35),
            cv2.FONT_HERSHEY_SIMPLEX,
            1.0,
            (0, 255, 0),
            2,
        )

        if args.count_person:
            cv2.putText(
                vis_img,
                f"Persons: {person_count}",
                (20, 75),
                cv2.FONT_HERSHEY_SIMPLEX,
                1.0,
                (0, 255, 255),
                2,
            )

        cv2.imshow("YOLOX BF16 Person Counter", vis_img)
        key = cv2.waitKey(1) & 0xFF
        if key in (27, ord("q")):
            break

    cap.release()
    cv2.destroyAllWindows()


if __name__ == "__main__":
    main()