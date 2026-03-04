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
    return bgr[y0:y0+crop_h, x0:x0+crop_w, :]


def make_session(onnx_path, device, cache_dir, cache_key):
    so = ort.SessionOptions()
    so.log_severity_level = 2

    if device == "npu":
        vai = {
            "cache_dir": os.path.abspath(cache_dir),
            "cache_key": cache_key,
            # 安定重視：ディスクキャッシュ
            "enable_cache_file_io_in_mem": 0,
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


def open_camera(index, backend, fourcc, req_w, req_h, req_fps):
    backend_map = {"auto": 0, "dshow": cv2.CAP_DSHOW, "msmf": cv2.CAP_MSMF}
    cap = cv2.VideoCapture(index, backend_map.get(backend, 0))

    # 低遅延化（効かない環境もある）
    try:
        cap.set(cv2.CAP_PROP_BUFFERSIZE, 1)
    except Exception:
        pass

    if fourcc:
        cap.set(cv2.CAP_PROP_FOURCC, cv2.VideoWriter_fourcc(*fourcc))
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, req_w)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, req_h)
    cap.set(cv2.CAP_PROP_FPS, req_fps)
    return cap


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--onnx", required=True)
    ap.add_argument("--device", choices=["cpu", "npu"], default="npu")

    ap.add_argument("--cam", type=int, default=0)
    ap.add_argument("--backend", choices=["auto", "dshow", "msmf"], default="dshow")
    ap.add_argument("--fourcc", default="MJPG")
    ap.add_argument("--req_w", type=int, default=1920)
    ap.add_argument("--req_h", type=int, default=1080)
    ap.add_argument("--req_fps", type=int, default=30)

    # 評価したい出力（FullHD）
    ap.add_argument("--src_w", type=int, default=1920)
    ap.add_argument("--src_h", type=int, default=1080)

    # モデル入力（崩れ回避の 1088x1920）
    ap.add_argument("--model_w", type=int, default=1920)
    ap.add_argument("--model_h", type=int, default=1088)

    ap.add_argument("--sigma", type=float, default=15.0)
    ap.add_argument("--warmup", type=int, default=10)

    ap.add_argument("--disp_scale", type=float, default=0.6, help="display scale (side-by-side is wide)")
    ap.add_argument("--side_by_side", action="store_true")
    ap.add_argument("--grab_flush", type=int, default=0,
                    help="flush N frames by cap.grab() each loop (0=off). Helps reduce latency.")

    ap.add_argument("--cache_dir", default=r"C:\vaip_cache")
    ap.add_argument("--cache_key", default="ffdnet_cam_fhd_1088pad")
    args = ap.parse_args()

    # report env が残ってると落ちるケースがあるので消す
    os.environ.pop("XLNX_ONNX_EP_REPORT_FILE", None)
    os.makedirs(args.cache_dir, exist_ok=True)

    t0 = time.perf_counter()
    sess = make_session(args.onnx, args.device, args.cache_dir, args.cache_key)
    t1 = time.perf_counter()

    in0 = sess.get_inputs()[0].name
    in1 = sess.get_inputs()[1].name
    print("[providers]", sess.get_providers())
    print("[inputs]", [(i.name, i.shape, i.type) for i in sess.get_inputs()])
    print(f"[session_create] {(t1-t0)*1000:.2f} ms")

    cap = open_camera(args.cam, args.backend, args.fourcc, args.req_w, args.req_h, args.req_fps)
    if not cap.isOpened():
        raise RuntimeError("Failed to open camera")

    act_w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    act_h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    act_fps = cap.get(cv2.CAP_PROP_FPS)
    print(f"[camera] {act_w}x{act_h} fps={act_fps:.1f} fourcc={args.fourcc} backend={args.backend}")

    sigma = np.array([[[[args.sigma / 255.0]]]], dtype=np.float32)

    # warmup (dummy)
    dummy = np.zeros((1, 3, args.model_h, args.model_w), dtype=np.float32)
    for _ in range(max(0, args.warmup)):
        _ = sess.run(None, {in0: dummy, in1: sigma})

    times = []
    last_print = time.time()

    print("Keys: [ESC]=quit  [+]/[-]=sigma up/down  [s]=save compare.png")

    while True:
        # optional flush
        for _ in range(max(0, args.grab_flush)):
            cap.grab()

        ok, frame = cap.read()
        if not ok:
            time.sleep(0.005)
            continue

        # まず src_w x src_h をセンタークロップ（リサイズ無し）
        # カメラがちょうど1920x1080なら実質そのまま
        try:
            src = center_crop(frame, args.src_w, args.src_h)
        except ValueError as e:
            print("crop error:", e)
            break

        # 1088へ反射パッド（上下+4）
        src_pad, pads = reflect_pad_to(src, args.model_h, args.model_w)

        # NCHW float
        rgb = cv2.cvtColor(src_pad, cv2.COLOR_BGR2RGB)
        x = (rgb.astype(np.float32) / 255.0)
        x = np.transpose(x, (2, 0, 1))[None, ...].copy()

        t_run0 = time.perf_counter()
        y = sess.run(None, {in0: x, in1: sigma})[0]
        t_run1 = time.perf_counter()

        dt_ms = (t_run1 - t_run0) * 1000.0
        times.append(dt_ms)
        if len(times) > 60:
            times.pop(0)
        mean_ms = sum(times) / len(times)
        est_fps = 1000.0 / max(mean_ms, 1e-6)

        # y -> BGR uint8
        y = np.clip(y[0], 0.0, 1.0)
        y = np.transpose(y, (1, 2, 0))  # HWC RGB
        y = (y * 255.0).astype(np.uint8)
        y = crop_from_pad(y, pads, args.src_h, args.src_w)
        out = cv2.cvtColor(y, cv2.COLOR_RGB2BGR)

        if args.side_by_side:
            show = cv2.hconcat([src, out])
        else:
            show = out

        cv2.putText(
            show,
            f"{args.device}  sigma={args.sigma:.1f}  infer~{mean_ms:.2f}ms  fps~{est_fps:.1f}",
            (10, 30),
            cv2.FONT_HERSHEY_SIMPLEX,
            0.9,
            (0, 255, 0),
            2,
            cv2.LINE_AA,
        )

        if args.disp_scale != 1.0:
            show = cv2.resize(show, None, fx=args.disp_scale, fy=args.disp_scale, interpolation=cv2.INTER_AREA)

        cv2.imshow("FFDNet FullHD (pad to 1088)  orig | denoised", show)
        k = cv2.waitKey(1) & 0xFF

        if k == 27:
            break
        elif k in (ord('+'), ord('=')):
            args.sigma = min(args.sigma + 1.0, 75.0)
            sigma[:] = args.sigma / 255.0
        elif k == ord('-'):
            args.sigma = max(args.sigma - 1.0, 0.0)
            sigma[:] = args.sigma / 255.0
        elif k == ord('s'):
            ts = int(time.time())
            fn = f"fhd_compare_{ts}.png"
            cv2.imwrite(fn, cv2.hconcat([src, out]))
            print("saved:", fn)

        if time.time() - last_print > 5.0:
            last_print = time.time()
            print(f"infer_mean={mean_ms:.2f}ms  fps~{est_fps:.1f}  sigma={args.sigma:.1f}")

    cap.release()
    cv2.destroyAllWindows()


if __name__ == "__main__":
    main()