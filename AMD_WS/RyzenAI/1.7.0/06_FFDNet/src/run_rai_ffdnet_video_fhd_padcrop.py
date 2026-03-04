import argparse
import os
import time

import cv2
import numpy as np
import onnxruntime as ort


def reflect_pad_to(bgr, target_h, target_w):
    h, w = bgr.shape[:2]
    if h > target_h or w > target_w:
        raise ValueError(f"pad target must be >= input. input={w}x{h}, target={target_w}x{target_h}")
    pad_h = target_h - h
    pad_w = target_w - w
    top = pad_h // 2
    bottom = pad_h - top
    left = pad_w // 2
    right = pad_w - left
    out = cv2.copyMakeBorder(bgr, top, bottom, left, right, cv2.BORDER_REFLECT_101)
    return out, (top, bottom, left, right)


def crop_from_pad(img, pads, out_h, out_w):
    top, bottom, left, right = pads
    h, w = img.shape[:2]
    img = img[top:h-bottom, left:w-right, :]
    return img[:out_h, :out_w, :]


def center_crop(bgr, crop_w, crop_h):
    h, w = bgr.shape[:2]
    if w < crop_w or h < crop_h:
        raise ValueError(f"Frame too small: {w}x{h} < crop {crop_w}x{crop_h}")
    x0 = (w - crop_w) // 2
    y0 = (h - crop_h) // 2
    return bgr[y0:y0 + crop_h, x0:x0 + crop_w, :]


def make_session(onnx_path, device, cache_dir, cache_key, enable_disk_cache=True):
    so = ort.SessionOptions()
    so.log_severity_level = 2

    if device == "npu":
        os.environ.pop("XLNX_ONNX_EP_REPORT_FILE", None)  # 安定優先
        vai = {
            "cache_dir": os.path.abspath(cache_dir),
            "cache_key": cache_key,
            "enable_cache_file_io_in_mem": 0 if enable_disk_cache else 1,
        }
        sess = ort.InferenceSession(
            onnx_path,
            sess_options=so,
            providers=["VitisAIExecutionProvider", "CPUExecutionProvider"],
            provider_options=[vai, {}],
        )
    else:
        sess = ort.InferenceSession(onnx_path, sess_options=so, providers=["CPUExecutionProvider"])
    return sess


def open_writer(out_path, fps, w, h, fourcc_str):
    fourcc = cv2.VideoWriter_fourcc(*fourcc_str)
    writer = cv2.VideoWriter(out_path, fourcc, fps, (w, h))
    return writer


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--onnx", required=True)
    ap.add_argument("--in_video", required=True)
    ap.add_argument("--out_video", required=True)
    ap.add_argument("--device", choices=["cpu", "npu"], default="npu")

    # 評価したい出力解像
    ap.add_argument("--src_w", type=int, default=1920)
    ap.add_argument("--src_h", type=int, default=1080)

    # モデル入力解像（崩れ回避：1088x1920推奨）
    ap.add_argument("--model_w", type=int, default=1920)
    ap.add_argument("--model_h", type=int, default=1088)

    ap.add_argument("--fit", choices=["crop", "resize", "strict"], default="crop",
                    help="crop: center-crop to src_w/h, resize: resize to src_w/h, strict: require exact src_w/h")
    ap.add_argument("--sigma", type=float, default=15.0)

    ap.add_argument("--codec", default="mp4v", help="mp4v (mp4) or XVID (avi) etc.")
    ap.add_argument("--out_fps", type=float, default=0.0, help="0=use input fps")

    ap.add_argument("--warmup", type=int, default=5)
    ap.add_argument("--max_frames", type=int, default=0, help="0=all")
    ap.add_argument("--start_frame", type=int, default=0)
    ap.add_argument("--progress_every", type=int, default=30)

    ap.add_argument("--cache_dir", default=r"C:\vaip_cache")
    ap.add_argument("--cache_key", default="ffdnet_video_fhd_1088pad")
    args = ap.parse_args()

    os.makedirs(args.cache_dir, exist_ok=True)

    # Open video
    cap = cv2.VideoCapture(args.in_video)
    if not cap.isOpened():
        raise RuntimeError(f"Failed to open input video: {args.in_video}")

    in_w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    in_h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    in_fps = cap.get(cv2.CAP_PROP_FPS)
    total = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))

    fps = args.out_fps if args.out_fps > 0 else (in_fps if in_fps and in_fps > 0 else 30.0)

    print(f"[input] {in_w}x{in_h} fps={in_fps:.3f} frames={total}")
    print(f"[output] {args.src_w}x{args.src_h} fps={fps:.3f} codec={args.codec}")

    # Session
    t0 = time.perf_counter()
    sess = make_session(args.onnx, args.device, args.cache_dir, args.cache_key, enable_disk_cache=True)
    t1 = time.perf_counter()
    in0 = sess.get_inputs()[0].name
    in1 = sess.get_inputs()[1].name
    print("[providers]", sess.get_providers())
    print("[inputs]", [(i.name, i.shape, i.type) for i in sess.get_inputs()])
    print(f"[session_create] {(t1 - t0) * 1000:.2f} ms")

    # Writer
    writer = open_writer(args.out_video, fps, args.src_w, args.src_h, args.codec)
    if not writer.isOpened():
        raise RuntimeError(f"Failed to open VideoWriter. Try --codec XVID and output .avi")

    sigma = np.array([[[[args.sigma / 255.0]]]], dtype=np.float32)

    # seek
    if args.start_frame > 0:
        cap.set(cv2.CAP_PROP_POS_FRAMES, args.start_frame)

    # warmup (dummy)
    dummy = np.zeros((1, 3, args.model_h, args.model_w), dtype=np.float32)
    for _ in range(max(0, args.warmup)):
        _ = sess.run(None, {in0: dummy, in1: sigma})

    frames_done = 0
    infer_ms_sum = 0.0
    t_all0 = time.perf_counter()

    while True:
        if args.max_frames > 0 and frames_done >= args.max_frames:
            break

        ok, frame = cap.read()
        if not ok:
            break

        # fit to src_w/src_h
        if args.fit == "strict":
            if frame.shape[1] != args.src_w or frame.shape[0] != args.src_h:
                raise ValueError(f"strict: got {frame.shape[1]}x{frame.shape[0]}, expected {args.src_w}x{args.src_h}")
            src = frame
        elif args.fit == "resize":
            src = cv2.resize(frame, (args.src_w, args.src_h), interpolation=cv2.INTER_AREA)
        else:
            # center crop
            if frame.shape[1] == args.src_w and frame.shape[0] == args.src_h:
                src = frame
            else:
                # 先に resize してから crop したい場合は、ここを調整
                src = center_crop(frame, args.src_w, args.src_h)

        # pad to model_h/model_w (1088x1920)
        src_pad, pads = reflect_pad_to(src, args.model_h, args.model_w)

        # NCHW float
        rgb = cv2.cvtColor(src_pad, cv2.COLOR_BGR2RGB)
        x = (rgb.astype(np.float32) / 255.0)
        x = np.transpose(x, (2, 0, 1))[None, ...].copy()

        t_inf0 = time.perf_counter()
        y = sess.run(None, {in0: x, in1: sigma})[0]
        t_inf1 = time.perf_counter()

        dt_ms = (t_inf1 - t_inf0) * 1000.0
        infer_ms_sum += dt_ms

        # y -> BGR uint8
        y = np.clip(y[0], 0.0, 1.0)
        y = np.transpose(y, (1, 2, 0))  # HWC RGB
        y = (y * 255.0).astype(np.uint8)
        y = crop_from_pad(y, pads, args.src_h, args.src_w)
        out_bgr = cv2.cvtColor(y, cv2.COLOR_RGB2BGR)

        writer.write(out_bgr)
        frames_done += 1

        if args.progress_every > 0 and (frames_done % args.progress_every) == 0:
            avg_ms = infer_ms_sum / frames_done
            est_fps = 1000.0 / max(avg_ms, 1e-6)
            pos = args.start_frame + frames_done
            print(f"[{pos}/{total}] infer_mean={avg_ms:.2f} ms  (~{est_fps:.2f} fps)")

    t_all1 = time.perf_counter()
    cap.release()
    writer.release()

    if frames_done > 0:
        avg_ms = infer_ms_sum / frames_done
        est_fps = 1000.0 / max(avg_ms, 1e-6)
    else:
        avg_ms = 0.0
        est_fps = 0.0

    print(f"[done] frames={frames_done}  infer_mean={avg_ms:.2f} ms (~{est_fps:.2f} fps)  total_time={(t_all1 - t_all0):.1f}s")
    print("saved:", args.out_video)


if __name__ == "__main__":
    main()