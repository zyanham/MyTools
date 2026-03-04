import argparse
import os
import time

import cv2
import numpy as np
import onnxruntime as ort


def make_session(onnx_path: str, device: str, cache_dir: str, cache_key: str):
    so = ort.SessionOptions()
    so.log_severity_level = 2

    if device == "npu":
        vai = {
            "cache_dir": os.path.abspath(cache_dir),
            "cache_key": cache_key,
            "enable_cache_file_io_in_mem": 0,  # disk cache (stable)
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


def open_camera(index: int, backend: str, req_w: int, req_h: int, req_fps: int, fourcc: str):
    backend_map = {"auto": 0, "dshow": cv2.CAP_DSHOW, "msmf": cv2.CAP_MSMF}
    cap = cv2.VideoCapture(index, backend_map.get(backend, 0))

    try:
        cap.set(cv2.CAP_PROP_BUFFERSIZE, 1)
    except Exception:
        pass

    if fourcc:
        cap.set(cv2.CAP_PROP_FOURCC, cv2.VideoWriter_fourcc(*fourcc))
    if req_w > 0 and req_h > 0:
        cap.set(cv2.CAP_PROP_FRAME_WIDTH, req_w)
        cap.set(cv2.CAP_PROP_FRAME_HEIGHT, req_h)
    if req_fps > 0:
        cap.set(cv2.CAP_PROP_FPS, req_fps)

    return cap


def center_crop(bgr: np.ndarray, crop_w: int, crop_h: int) -> np.ndarray:
    h, w = bgr.shape[:2]
    if w < crop_w or h < crop_h:
        raise ValueError(f"Frame too small: {w}x{h} < crop {crop_w}x{crop_h}")
    x0 = (w - crop_w) // 2
    y0 = (h - crop_h) // 2
    return bgr[y0:y0 + crop_h, x0:x0 + crop_w, :]


def bgr_crop_to_nchw_float01(bgr_crop: np.ndarray) -> np.ndarray:
    rgb = cv2.cvtColor(bgr_crop, cv2.COLOR_BGR2RGB)
    x = rgb.astype(np.float32) / 255.0
    x = np.transpose(x, (2, 0, 1))[None, ...]  # NCHW
    return np.ascontiguousarray(x, dtype=np.float32)


def nchw_float01_to_bgr_uint8(y: np.ndarray) -> np.ndarray:
    y = y[0]  # CHW
    y = np.clip(y, 0.0, 1.0)
    y = np.transpose(y, (1, 2, 0))  # HWC RGB
    y = (y * 255.0).astype(np.uint8)
    return cv2.cvtColor(y, cv2.COLOR_RGB2BGR)


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

    ap.add_argument("--crop_w", type=int, default=960)
    ap.add_argument("--crop_h", type=int, default=544)

    ap.add_argument("--sigma", type=float, default=15.0)
    ap.add_argument("--warmup", type=int, default=10)

    ap.add_argument("--disp_scale", type=float, default=0.9, help="display scale only")
    ap.add_argument("--cache_dir", default=r"C:\vaip_cache")
    ap.add_argument("--cache_key", default="ffdnet_cam_crop")
    args = ap.parse_args()

    # report envが残ってると落ちる環境があるのでクリア
    os.environ.pop("XLNX_ONNX_EP_REPORT_FILE", None)

    os.makedirs(args.cache_dir, exist_ok=True)

    t0 = time.perf_counter()
    sess = make_session(args.onnx, args.device, args.cache_dir, args.cache_key)
    t1 = time.perf_counter()

    in0 = sess.get_inputs()[0].name
    in1 = sess.get_inputs()[1].name
    print("[providers]", sess.get_providers())
    print("[inputs]", [(i.name, i.shape, i.type) for i in sess.get_inputs()])
    print(f"[session_create] {(t1 - t0) * 1000:.2f} ms")

    cap = open_camera(args.cam, args.backend, args.req_w, args.req_h, args.req_fps, args.fourcc)
    if not cap.isOpened():
        raise RuntimeError("Failed to open camera")

    act_w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    act_h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    act_fps = cap.get(cv2.CAP_PROP_FPS)
    print(f"[camera] {act_w}x{act_h} fps={act_fps:.1f}")

    sigma = np.array([[[[args.sigma / 255.0]]]], dtype=np.float32)

    # warmup (dummy)
    dummy = np.zeros((1, 3, args.crop_h, args.crop_w), dtype=np.float32)
    for _ in range(max(0, args.warmup)):
        _ = sess.run(None, {in0: dummy, in1: sigma})

    times = []
    last_print = time.time()

    print("Keys: [ESC]=quit  [+]/[-]=sigma up/down  [s]=save side-by-side")

    while True:
        ok, frame = cap.read()
        if not ok:
            time.sleep(0.005)
            continue

        try:
            crop = center_crop(frame, args.crop_w, args.crop_h)  # NO resize
        except ValueError as e:
            print("crop error:", e)
            break

        x = bgr_crop_to_nchw_float01(crop)

        t_run0 = time.perf_counter()
        y = sess.run(None, {in0: x, in1: sigma})[0]
        t_run1 = time.perf_counter()

        out = nchw_float01_to_bgr_uint8(y)

        dt_ms = (t_run1 - t_run0) * 1000.0
        times.append(dt_ms)
        if len(times) > 60:
            times.pop(0)
        mean_ms = sum(times) / len(times)
        est_fps = 1000.0 / max(mean_ms, 1e-6)

        # side-by-side (orig | denoised)
        show = cv2.hconcat([crop, out])
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

        cv2.imshow("FFDNet crop 960x544  |  orig (L)  denoised (R)", show)
        k = cv2.waitKey(1) & 0xFF

        if k == 27:  # ESC
            break
        elif k in (ord('+'), ord('=')):
            args.sigma = min(args.sigma + 1.0, 75.0)
            sigma[:] = args.sigma / 255.0
        elif k == ord('-'):
            args.sigma = max(args.sigma - 1.0, 0.0)
            sigma[:] = args.sigma / 255.0
        elif k == ord('s'):
            ts = int(time.time())
            fn = f"crop_compare_{ts}.png"
            # 保存は非スケール版（評価向け）
            cv2.imwrite(fn, cv2.hconcat([crop, out]))
            print("saved:", fn)

        # たまに状態表示
        if time.time() - last_print > 5.0:
            last_print = time.time()
            print(f"infer_mean={mean_ms:.2f}ms  fps~{est_fps:.1f}  sigma={args.sigma:.1f}")

    cap.release()
    cv2.destroyAllWindows()


if __name__ == "__main__":
    main()