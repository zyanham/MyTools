import argparse
import sys
import time
from pathlib import Path

import cv2
import numpy as np
import onnxruntime as ort

# RyzenAI-SW の yolov8m サンプルにある utils.py を使う前提
from utils import get_npu_info, get_xclbin

# COCO 80 classes (YOLOv8 COCO pretrained想定)
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
    "hair drier", "toothbrush"
]


def fourcc_to_str(v: int) -> str:
    return "".join([chr((v >> (8 * i)) & 0xFF) for i in range(4)])


def letterbox_bgr(img_bgr: np.ndarray, new_size: int = 640, color=(114, 114, 114)):
    """
    Letterbox resize (aspect keep + pad).
    return:
      padded_bgr, scale, pad_x, pad_y
    """
    h, w = img_bgr.shape[:2]
    scale = min(new_size / w, new_size / h)
    nw = int(round(w * scale))
    nh = int(round(h * scale))

    resized = cv2.resize(img_bgr, (nw, nh), interpolation=cv2.INTER_LINEAR)

    pad_x = (new_size - nw) // 2
    pad_y = (new_size - nh) // 2

    out = np.full((new_size, new_size, 3), color, dtype=np.uint8)
    out[pad_y:pad_y + nh, pad_x:pad_x + nw] = resized
    return out, scale, pad_x, pad_y


def preprocess_frame(frame_bgr: np.ndarray, img_size: int = 640, fit: str = "resize"):
    """
    fit:
      - resize: force resize to (img_size,img_size)
      - letterbox: aspect keep + pad (recommended for demo)
    returns:
      input_nchw_float32, draw_bgr(original), meta(dict)
    """
    meta = {"fit": fit}

    if fit == "letterbox":
        padded, scale, pad_x, pad_y = letterbox_bgr(frame_bgr, new_size=img_size)
        img_rgb = cv2.cvtColor(padded, cv2.COLOR_BGR2RGB)
        meta.update({"scale": scale, "pad_x": pad_x, "pad_y": pad_y, "img_size": img_size})
    else:
        # resize
        resized = cv2.resize(frame_bgr, (img_size, img_size), interpolation=cv2.INTER_LINEAR)
        img_rgb = cv2.cvtColor(resized, cv2.COLOR_BGR2RGB)
        meta.update({"img_size": img_size})

    x = img_rgb.astype(np.float32) / 255.0
    x = np.transpose(x, (2, 0, 1))  # HWC -> CHW
    x = np.expand_dims(x, axis=0)   # -> NCHW
    x = np.ascontiguousarray(x, dtype=np.float32)
    return x, frame_bgr, meta


def _normalize_output_to_2d(outputs0: np.ndarray) -> np.ndarray:
    """
    YOLOv8 ONNX output shape can be:
      - (1, 84, 8400)
      - (1, 8400, 84)
      - (84, 8400)
      - (8400, 84)
    Return: (N, 84) where N=8400 typically.
    """
    a = outputs0
    a = np.squeeze(a)
    if a.ndim != 2:
        raise ValueError(f"Unexpected output ndim={a.ndim}, shape={outputs0.shape}")

    # decide which axis is features(84)
    if a.shape[1] == 84:
        return a  # (N,84)
    if a.shape[0] == 84:
        return a.transpose(1, 0)  # (N,84)
    # fallback: assume last dim features
    if a.shape[-1] == 84:
        return a.reshape(-1, 84)
    raise ValueError(f"Cannot normalize output to (N,84), got shape={a.shape}")


def postprocess_fast(outputs, img_bgr, meta, conf_thres=0.4, nms_thres=0.5, topk=300):
    """
    Vectorized postprocess for YOLOv8 head output.
    Draw results on img_bgr and return it.

    NOTE:
      - For fit="resize": map model coords to original directly by scaling W/H.
      - For fit="letterbox": unpad + unscale to original.
    """
    pred = _normalize_output_to_2d(outputs[0])  # (N,84)
    boxes_xywh = pred[:, :4]                   # cx,cy,w,h in input space (pixels in img_size)
    scores = pred[:, 4:]                       # (N,80)

    class_ids = np.argmax(scores, axis=1)
    confs = scores[np.arange(scores.shape[0]), class_ids]

    m = confs >= conf_thres
    if not np.any(m):
        return img_bgr

    boxes_xywh = boxes_xywh[m]
    class_ids = class_ids[m]
    confs = confs[m]

    # Keep topK by confidence to reduce NMS cost
    if topk and boxes_xywh.shape[0] > topk:
        idx = np.argpartition(-confs, topk)[:topk]
        boxes_xywh = boxes_xywh[idx]
        class_ids = class_ids[idx]
        confs = confs[idx]

    img_h, img_w = img_bgr.shape[:2]
    img_size = float(meta["img_size"])

    # Convert model-space xywh(center) -> xyxy in model space
    cx = boxes_xywh[:, 0]
    cy = boxes_xywh[:, 1]
    bw = boxes_xywh[:, 2]
    bh = boxes_xywh[:, 3]
    x1 = cx - bw / 2.0
    y1 = cy - bh / 2.0
    x2 = cx + bw / 2.0
    y2 = cy + bh / 2.0

    # Map to original image coordinates
    if meta["fit"] == "letterbox":
        scale = float(meta["scale"])
        pad_x = float(meta["pad_x"])
        pad_y = float(meta["pad_y"])
        # unpad then unscale
        x1 = (x1 - pad_x) / scale
        x2 = (x2 - pad_x) / scale
        y1 = (y1 - pad_y) / scale
        y2 = (y2 - pad_y) / scale
    else:
        # resize mapping: model coords are in [0,img_size] -> original
        x1 = x1 * (img_w / img_size)
        x2 = x2 * (img_w / img_size)
        y1 = y1 * (img_h / img_size)
        y2 = y2 * (img_h / img_size)

    # clamp
    x1 = np.clip(x1, 0, img_w - 1).astype(np.int32)
    y1 = np.clip(y1, 0, img_h - 1).astype(np.int32)
    x2 = np.clip(x2, 0, img_w - 1).astype(np.int32)
    y2 = np.clip(y2, 0, img_h - 1).astype(np.int32)

    # OpenCV NMSBoxes expects [x,y,w,h]
    w = (x2 - x1).clip(0, img_w - 1).astype(np.int32)
    h = (y2 - y1).clip(0, img_h - 1).astype(np.int32)
    boxes_cv = np.stack([x1, y1, w, h], axis=1).tolist()
    conf_list = confs.astype(float).tolist()

    idxs = cv2.dnn.NMSBoxes(boxes_cv, conf_list, conf_thres, nms_thres)
    if len(idxs) == 0:
        return img_bgr

    idxs = np.array(idxs).reshape(-1)

    # Draw (limit draw count to avoid UI overload)
    max_draw = 50
    for k, i in enumerate(idxs):
        if k >= max_draw:
            break
        xx, yy, ww, hh = boxes_cv[i]
        cid = int(class_ids[i])
        conf = float(conf_list[i])
        label = f"{COCO_CLASSES[cid]} {conf:.2f}"
        cv2.rectangle(img_bgr, (xx, yy), (xx + ww, yy + hh), (0, 255, 0), 2)
        cv2.putText(img_bgr, label, (xx, max(0, yy - 8)),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 0, 0), 2)

    return img_bgr


def create_session(onnx_path: str, device: str):
    session_options = ort.SessionOptions()
    session_options.log_severity_level = 1

    if device == "cpu":
        print("[INFO] Running Model on CPU")
        return ort.InferenceSession(
            onnx_path,
            sess_options=session_options,
            providers=["CPUExecutionProvider"],
        )

    if device == "npu-bf16":
        print("[INFO] Running BF16 Model on NPU")
        provider_options = [{
            # config_file は絶対パスにしておくと動作が安定しやすい
            "config_file": str((Path(__file__).parent / "vaiml_config.json").resolve()),
            "cache_dir": str(Path(__file__).parent.resolve()),
            "cache_key": "modelcachekey",
        }]
        return ort.InferenceSession(
            onnx_path,
            sess_options=session_options,
            providers=["VitisAIExecutionProvider"],
            provider_options=provider_options,
        )

    if device == "npu-int8":
        print("[INFO] Running INT8 Model on NPU")
        npu_device = get_npu_info()

        if npu_device == "PHX/HPT":
            provider_options = [{
                "cache_dir": str(Path(__file__).parent.resolve()),
                "cache_key": "modelcachekey",
                "enable_cache_file_io_in_mem": "0",
                "target": "X1",
                "xclbin": get_xclbin(npu_device),
            }]
        elif npu_device in ("STX", "KRK"):
            provider_options = [{
                "cache_dir": str(Path(__file__).parent.resolve()),
                "cache_key": "modelcachekey",
                "enable_cache_file_io_in_mem": "0",
            }]
        else:
            provider_options = [{
                "cache_dir": str(Path(__file__).parent.resolve()),
                "cache_key": "modelcachekey",
                "enable_cache_file_io_in_mem": "0",
            }]

        return ort.InferenceSession(
            onnx_path,
            sess_options=session_options,
            providers=["VitisAIExecutionProvider"],
            provider_options=provider_options,
        )

    print("[ERROR] Unsupported device. Use cpu / npu-int8 / npu-bf16")
    sys.exit(1)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--model_input", type=str, required=True, help="ONNX path")
    parser.add_argument("--device", type=str, default="cpu", choices=["cpu", "npu-int8", "npu-bf16"])
    parser.add_argument("--camera", type=int, default=0, help="camera index (0,1,...)")
    parser.add_argument("--backend", type=str, default="dshow", choices=["any", "dshow", "msmf"])
    parser.add_argument("--cam_width", type=int, default=1280)
    parser.add_argument("--cam_height", type=int, default=720)
    parser.add_argument("--cam_fps", type=float, default=30.0, help="requested camera fps")
    parser.add_argument("--fourcc", type=str, default="MJPG", help="requested FOURCC (e.g. MJPG, YUY2)")
    parser.add_argument("--grab", type=int, default=0, help="drop old frames by cap.grab() N times each loop")
    parser.add_argument("--img_size", type=int, default=640, help="model input size (yolov8m is 640)")
    parser.add_argument("--fit", type=str, default="resize", choices=["resize", "letterbox"])
    parser.add_argument("--conf", type=float, default=0.4)
    parser.add_argument("--nms", type=float, default=0.5)
    parser.add_argument("--topk", type=int, default=300, help="pre-NMS topK boxes (smaller=faster)")
    parser.add_argument("--show", action="store_true", help="imshow window")
    parser.add_argument("--save_video", type=str, default="", help="output mp4 path (optional)")
    parser.add_argument("--max_fps", type=float, default=0.0, help="limit loop fps (0=unlimited)")
    parser.add_argument("--opencv_threads", type=int, default=1, help="cv2.setNumThreads(N)")
    args = parser.parse_args()

    # OpenCV thread tuning (can reduce jitter)
    try:
        cv2.setNumThreads(args.opencv_threads)
    except Exception:
        pass

    # Create ORT session
    sess = create_session(args.model_input, args.device)
    input_name = sess.get_inputs()[0].name
    print("[INFO] input:", sess.get_inputs()[0].name, sess.get_inputs()[0].shape, sess.get_inputs()[0].type)
    print("[INFO] providers:", sess.get_providers())

    # Camera backend
    api = cv2.CAP_ANY
    if args.backend == "dshow":
        api = cv2.CAP_DSHOW
    elif args.backend == "msmf":
        api = cv2.CAP_MSMF

    cap = cv2.VideoCapture(args.camera, api)
    if not cap.isOpened():
        print(f"[ERROR] Cannot open camera index={args.camera}")
        sys.exit(1)

    # Request format/fps first, then size
    if args.fourcc and len(args.fourcc) == 4:
        cap.set(cv2.CAP_PROP_FOURCC, cv2.VideoWriter_fourcc(*args.fourcc))
    if args.cam_fps and args.cam_fps > 0:
        cap.set(cv2.CAP_PROP_FPS, float(args.cam_fps))

    cap.set(cv2.CAP_PROP_FRAME_WIDTH, args.cam_width)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, args.cam_height)

    # Try low-latency buffer if supported
    try:
        cap.set(cv2.CAP_PROP_BUFFERSIZE, 1)
    except Exception:
        pass

    # Print negotiated camera params (super important)
    w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    fps = cap.get(cv2.CAP_PROP_FPS)
    fcc = int(cap.get(cv2.CAP_PROP_FOURCC))
    print(f"[CAM] {w}x{h} fps={fps:.1f} fourcc={fourcc_to_str(fcc)}({fcc}) backend={args.backend} grab={args.grab}")

    # Video writer (optional)
    writer = None
    if args.save_video:
        out_path = args.save_video
        # If camera FPS is 0/unknown, fallback to 30
        out_fps = fps if fps and fps > 1 else 30.0
        fourcc_out = cv2.VideoWriter_fourcc(*"mp4v")
        writer = cv2.VideoWriter(out_path, fourcc_out, out_fps, (w, h))
        if not writer.isOpened():
            print("[WARN] VideoWriter open failed; disable save_video")
            writer = None

    ema_fps = 0.0
    alpha = 0.1

    while True:
        t_loop0 = time.perf_counter()

        # ---- capture (drop old frames if requested) ----
        t0 = time.perf_counter()
        if args.grab > 0:
            for _ in range(args.grab):
                cap.grab()
            ret, frame = cap.retrieve()
        else:
            ret, frame = cap.read()
        t_cap = (time.perf_counter() - t0) * 1000.0

        if not ret or frame is None:
            print("[WARN] frame grab failed")
            continue

        # ---- preprocess ----
        t0 = time.perf_counter()
        inp, draw, meta = preprocess_frame(frame, img_size=args.img_size, fit=args.fit)
        t_pre = (time.perf_counter() - t0) * 1000.0

        # ---- inference ----
        t0 = time.perf_counter()
        outputs = sess.run(None, {input_name: inp})
        t_inf = (time.perf_counter() - t0) * 1000.0

        # ---- postprocess ----
        t0 = time.perf_counter()
        out = postprocess_fast(outputs, draw, meta, conf_thres=args.conf, nms_thres=args.nms, topk=args.topk)
        t_post = (time.perf_counter() - t0) * 1000.0

        # ---- loop timing / fps ----
        t_loop = (time.perf_counter() - t_loop0) * 1000.0
        inst_fps = 1000.0 / max(1e-6, t_loop)
        ema_fps = inst_fps if ema_fps == 0.0 else (1 - alpha) * ema_fps + alpha * inst_fps

        # ---- overlay (must be BEFORE imshow) ----
        cv2.putText(out, f"{ema_fps:.1f} FPS | {args.device} | fit={args.fit}",
                    (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 0), 3)
        cv2.putText(out, f"{ema_fps:.1f} FPS | {args.device} | fit={args.fit}",
                    (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 1)

        cv2.putText(out, f"cap {t_cap:.1f} pre {t_pre:.1f} inf {t_inf:.1f} post {t_post:.1f} loop {t_loop:.1f} ms",
                    (10, 58), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 0, 0), 3)
        cv2.putText(out, f"cap {t_cap:.1f} pre {t_pre:.1f} inf {t_inf:.1f} post {t_post:.1f} loop {t_loop:.1f} ms",
                    (10, 58), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 1)

        # ---- save ----
        if writer is not None:
            writer.write(out)

        # ---- show ----
        if args.show:
            cv2.imshow("YOLOv8m Webcam", out)
            key = cv2.waitKey(1) & 0xFF
            if key in (ord("q"), 27):  # q or ESC
                break

        # ---- optional limiter ----
        if args.max_fps and args.max_fps > 0:
            target = 1.0 / args.max_fps
            elapsed = time.perf_counter() - t_loop0
            if elapsed < target:
                time.sleep(target - elapsed)

    cap.release()
    if writer is not None:
        writer.release()
    if args.show:
        cv2.destroyAllWindows()


if __name__ == "__main__":
    main()