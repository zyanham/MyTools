import argparse
import time
import cv2
import numpy as np
import onnxruntime as ort

# COCO 17-keypoint skeleton
SKELETON = [
    (0, 1), (0, 2),
    (1, 3), (2, 4),
    (5, 6),
    (5, 7), (7, 9),
    (6, 8), (8, 10),
    (5, 11), (6, 12),
    (11, 12),
    (11, 13), (13, 15),
    (12, 14), (14, 16),
]


def letterbox(image, new_shape=(640, 640), color=(114, 114, 114)):
    h, w = image.shape[:2]
    nh, nw = new_shape

    r = min(nh / h, nw / w)
    new_unpad = (int(round(w * r)), int(round(h * r)))

    dw = nw - new_unpad[0]
    dh = nh - new_unpad[1]
    dw /= 2
    dh /= 2

    resized = cv2.resize(image, new_unpad, interpolation=cv2.INTER_LINEAR)

    top = int(round(dh - 0.1))
    bottom = int(round(dh + 0.1))
    left = int(round(dw - 0.1))
    right = int(round(dw + 0.1))

    out = cv2.copyMakeBorder(
        resized, top, bottom, left, right,
        cv2.BORDER_CONSTANT, value=color
    )
    return out, r, (left, top)


def preprocess_bgr(image_bgr, input_shape):
    _, _, h, w = input_shape
    padded, ratio, pad = letterbox(image_bgr, (h, w))
    rgb = cv2.cvtColor(padded, cv2.COLOR_BGR2RGB)
    x = rgb.astype(np.float32) / 255.0
    x = np.transpose(x, (2, 0, 1))  # CHW
    x = np.expand_dims(x, 0)        # NCHW
    return x, ratio, pad


def xywh_to_xyxy(boxes):
    out = np.empty_like(boxes)
    out[:, 0] = boxes[:, 0] - boxes[:, 2] / 2.0
    out[:, 1] = boxes[:, 1] - boxes[:, 3] / 2.0
    out[:, 2] = boxes[:, 0] + boxes[:, 2] / 2.0
    out[:, 3] = boxes[:, 1] + boxes[:, 3] / 2.0
    return out


def nms(boxes, scores, iou_thr=0.45):
    if len(boxes) == 0:
        return []

    x1 = boxes[:, 0]
    y1 = boxes[:, 1]
    x2 = boxes[:, 2]
    y2 = boxes[:, 3]

    areas = np.maximum(0, x2 - x1) * np.maximum(0, y2 - y1)
    order = scores.argsort()[::-1]

    keep = []
    while order.size > 0:
        i = order[0]
        keep.append(i)

        xx1 = np.maximum(x1[i], x1[order[1:]])
        yy1 = np.maximum(y1[i], y1[order[1:]])
        xx2 = np.minimum(x2[i], x2[order[1:]])
        yy2 = np.minimum(y2[i], y2[order[1:]])

        w = np.maximum(0.0, xx2 - xx1)
        h = np.maximum(0.0, yy2 - yy1)
        inter = w * h
        union = areas[i] + areas[order[1:]] - inter + 1e-6
        iou = inter / union

        inds = np.where(iou <= iou_thr)[0]
        order = order[inds + 1]

    return keep


def postprocess(output, orig_image, ratio, pad, conf_th=0.25, iou_th=0.45):
    """
    output: (1, 56, 8400)
    56 = 4 box + 1 score + 17*3 keypoints
    """
    pred = np.asarray(output[0])
    pred = np.transpose(pred, (1, 0))  # (8400, 56)

    scores = pred[:, 4]
    keep = scores > conf_th
    pred = pred[keep]
    scores = scores[keep]

    if pred.shape[0] == 0:
        return []

    boxes = xywh_to_xyxy(pred[:, :4])

    pad_x, pad_y = pad
    boxes[:, [0, 2]] -= pad_x
    boxes[:, [1, 3]] -= pad_y
    boxes /= ratio

    h, w = orig_image.shape[:2]
    boxes[:, 0] = np.clip(boxes[:, 0], 0, w - 1)
    boxes[:, 1] = np.clip(boxes[:, 1], 0, h - 1)
    boxes[:, 2] = np.clip(boxes[:, 2], 0, w - 1)
    boxes[:, 3] = np.clip(boxes[:, 3], 0, h - 1)

    kpts = pred[:, 5:].reshape(-1, 17, 3).copy()
    kpts[:, :, 0] -= pad_x
    kpts[:, :, 1] -= pad_y
    kpts[:, :, 0] /= ratio
    kpts[:, :, 1] /= ratio
    kpts[:, :, 0] = np.clip(kpts[:, :, 0], 0, w - 1)
    kpts[:, :, 1] = np.clip(kpts[:, :, 1], 0, h - 1)

    keep_idx = nms(boxes, scores, iou_thr=iou_th)

    results = []
    for i in keep_idx:
        results.append({
            "box": boxes[i],
            "score": float(scores[i]),
            "kpts": kpts[i],
        })
    return results


def draw_results(image, results, kpt_th=0.30, show_box=True):
    out = image.copy()

    for det in results:
        box = det["box"].astype(np.int32)
        score = det["score"]
        kpts = det["kpts"]

        x1, y1, x2, y2 = box
        if show_box:
            cv2.rectangle(out, (x1, y1), (x2, y2), (0, 255, 0), 2)
            cv2.putText(
                out,
                f"person {score:.2f}",
                (x1, max(0, y1 - 8)),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.6,
                (0, 255, 0),
                2,
                cv2.LINE_AA,
            )

        pts = []
        for i in range(17):
            x, y, s = kpts[i]
            if s < kpt_th:
                pts.append(None)
                continue
            p = (int(x), int(y))
            pts.append(p)
            cv2.circle(out, p, 4, (0, 255, 255), -1)

        for a, b in SKELETON:
            if pts[a] is not None and pts[b] is not None:
                cv2.line(out, pts[a], pts[b], (255, 0, 0), 2)

    return out


def put_status(frame, mode_text, person_count, fps, infer_ms, prep_ms, post_ms):
    y = 28
    dy = 26
    items = [
        f"Mode: {mode_text}",
        f"Persons: {person_count}",
        f"FPS: {fps:.1f}",
        f"Pre: {prep_ms:.1f} ms",
        f"Infer: {infer_ms:.1f} ms",
        f"Post: {post_ms:.1f} ms",
        "Keys: q=quit  s=save frame",
    ]
    for text in items:
        cv2.putText(
            frame, text, (12, y),
            cv2.FONT_HERSHEY_SIMPLEX, 0.7,
            (0, 255, 0), 2, cv2.LINE_AA
        )
        y += dy


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--model", default="yolo11n-pose.onnx")
    ap.add_argument("--provider_config", default=r".\vaip_config.json")
    ap.add_argument("--camera", type=int, default=0)
    ap.add_argument("--width", type=int, default=1280)
    ap.add_argument("--height", type=int, default=720)
    ap.add_argument("--conf_th", type=float, default=0.25)
    ap.add_argument("--iou_th", type=float, default=0.45)
    ap.add_argument("--kpt_th", type=float, default=0.30)
    ap.add_argument("--cpu", action="store_true")
    ap.add_argument("--show_box", action="store_true")
    ap.add_argument("--save_dir", default="results_camera")
    args = ap.parse_args()

    if args.cpu:
        sess = ort.InferenceSession(
            args.model,
            providers=["CPUExecutionProvider"],
        )
        mode_text = "CPU"
    else:
        sess = ort.InferenceSession(
            args.model,
            providers=["VitisAIExecutionProvider", "CPUExecutionProvider"],
            provider_options=[{"config_file": args.provider_config}, {}],
        )
        mode_text = "NPU"

    print("Providers:", sess.get_providers())
    for i, inp in enumerate(sess.get_inputs()):
        print(f"input[{i}] {inp.name} shape={inp.shape} type={inp.type}")
    for i, out in enumerate(sess.get_outputs()):
        print(f"output[{i}] {out.name} shape={out.shape} type={out.type}")

    input_meta = sess.get_inputs()[0]
    shape = [1 if isinstance(x, str) else x for x in input_meta.shape]

    cap = cv2.VideoCapture(args.camera, cv2.CAP_DSHOW)
    if not cap.isOpened():
        cap = cv2.VideoCapture(args.camera)

    if not cap.isOpened():
        raise RuntimeError(f"Could not open camera index {args.camera}")

    cap.set(cv2.CAP_PROP_FRAME_WIDTH, args.width)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, args.height)
    cap.set(cv2.CAP_PROP_BUFFERSIZE, 1)

    os.makedirs(args.save_dir, exist_ok=True)

    prev_t = time.perf_counter()
    fps = 0.0
    frame_id = 0

    while True:
        ok, frame = cap.read()
        if not ok:
            print("Failed to read frame from camera.")
            break

        t0 = time.perf_counter()
        x, ratio, pad = preprocess_bgr(frame, shape)
        t1 = time.perf_counter()

        outputs = sess.run(None, {input_meta.name: x})
        t2 = time.perf_counter()

        results = postprocess(
            outputs[0],
            frame,
            ratio,
            pad,
            conf_th=args.conf_th,
            iou_th=args.iou_th,
        )
        vis = draw_results(
            frame,
            results,
            kpt_th=args.kpt_th,
            show_box=args.show_box,
        )
        t3 = time.perf_counter()

        now = time.perf_counter()
        inst_fps = 1.0 / max(now - prev_t, 1e-6)
        fps = inst_fps if fps == 0.0 else (0.9 * fps + 0.1 * inst_fps)
        prev_t = now

        prep_ms = (t1 - t0) * 1000.0
        infer_ms = (t2 - t1) * 1000.0
        post_ms = (t3 - t2) * 1000.0

        put_status(
            vis,
            mode_text,
            len(results),
            fps,
            infer_ms,
            prep_ms,
            post_ms,
        )

        cv2.imshow("YOLO11 Pose Camera", vis)
        key = cv2.waitKey(1) & 0xFF

        if key == ord("q"):
            break
        elif key == ord("s"):
            out_path = os.path.join(args.save_dir, f"frame_{frame_id:06d}.jpg")
            cv2.imwrite(out_path, vis)
            print("Saved:", out_path)

        frame_id += 1

    cap.release()
    cv2.destroyAllWindows()


if __name__ == "__main__":
    import os
    main()