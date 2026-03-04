import argparse
import os
import time
import statistics

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
            # キャッシュを確実に残す（初回compile後が速くなる）
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


def open_camera(index: int, backend: str, req_w: int, req_h: int, req_fps: int, fourcc: str):
    backend_map = {
        "auto": 0,
        "dshow": cv2.CAP_DSHOW,
        "msmf": cv2.CAP_MSMF,
    }
    cap = cv2.VideoCapture(index, backend_map.get(backend, 0))

    # 可能ならバッファを絞る（効かない環境もある）
    try:
        cap.set(cv2.CAP_PROP_BUFFERSIZE, 1)
    except Exception:
        pass

    # FourCC / 解像度 / FPS（すべてが適用されるとは限らない）
    if fourcc:
        cap.set(cv2.CAP_PROP_FOURCC, cv2.VideoWriter_fourcc(*fourcc))
    if req_w > 0 and req_h > 0:
        cap.set(cv2.CAP_PROP_FRAME_WIDTH, req_w)
        cap.set(cv2.CAP_PROP_FRAME_HEIGHT, req_h)
    if req_fps > 0:
        cap.set(cv2.CAP_PROP_FPS, req_fps)

    return cap


def bgr_to_nchw_float01(bgr: np.ndarray, proc_w: int, proc_h: int):
    if bgr.shape[1] != proc_w or bgr.shape[0] != proc_h:
        bgr = cv2.resize(bgr, (proc_w, proc_h), interpolation=cv2.INTER_AREA)
    rgb = cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB)
    x = rgb.astype(np.float32) / 255.0
    x = np.transpose(x, (2, 0, 1))[None, ...]  # NCHW
    return np.ascontiguousarray(x, dtype=np.float32), bgr


def nchw_float01_to_bgr_uint8(y: np.ndarray):
    # y: (1,3,H,W) float
    y = y[0]
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
    ap.add_argument("--fourcc", default="MJPG", help="e.g. MJPG, YUY2, empty to skip")
    ap.add_argument("--req_w", type=int, default=1920)
    ap.add_argument("--req_h", type=int, default=1080)
    ap.add_argument("--req_fps", type=int, default=30)

    # 推論解像度（FFDNetモデル入力に合わせる）
    ap.add_argument("--proc_w", type=int, default=960)
    ap.add_argument("--proc_h", type=int, default=544)

    ap.add_argument("--sigma", type=float, default=15.0, help="noise level (e.g. 5..30)")
    ap.add_argument("--warmup", type=int, default=10)
    ap.add_argument("--repeat_stat", type=int, default=60, help="EMA/FPS表示用の履歴数")

    ap.add_argument("--view", choices=["proc", "upscale"], default="upscale",
                    help="proc: show 960x544, upscale: scale to camera size for display")
    ap.add_argument("--side_by_side", action="store_true", help="show original | denoised")
    ap.add_argument("--skip", type=int, default=0, help="process every (skip+1) frames")

    ap.add_argument("--cache_dir", default=r"C:\vaip_cache")
    ap.add_argument("--cache_key", default="ffdnet_cam")
    args = ap.parse_args()

    # レポートが残っていると落ちる環境があるので、ここでクリア推奨
    os.environ.pop("XLNX_ONNX_EP_REPORT_FILE", None)

    os.makedirs(args.cache_dir, exist_ok=True)

    t0 = time.perf_counter()
    sess = make_session(args.onnx, args.device, args.cache_dir, args.cache_key)
    t1 = time.perf_counter()

    in0 = sess.get_inputs()[0].name  # input
    in1 = sess.get_inputs()[1].name  # sigma
    print("[providers]", sess.get_providers())
    print("[inputs]", [(i.name, i.shape, i.type) for i in sess.get_inputs()])
    print(f"[session_create] {(t1-t0)*1000:.2f} ms")

    cap = open_camera(args.cam, args.backend, args.req_w, args.req_h, args.req_fps, args.fourcc)
    if not cap.isOpened():
        raise RuntimeError("Failed to open camera")

    # 実際に取れている設定を表示
    act_w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    act_h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    act_fps = cap.get(cv2.CAP_PROP_FPS)
    print(f"[camera] {act_w}x{act_h} fps={act_fps:.1f} backend={args.backend} fourcc={args.fourcc}")

    sigma = np.array([[[[args.sigma / 255.0]]]], dtype=np.float32)

    # warmup（ダミー入力）
    dummy = np.zeros((1, 3, args.proc_h, args.proc_w), dtype=np.float32)
    for _ in range(max(0, args.warmup)):
        _ = sess.run(None, {in0: dummy, in1: sigma})

    times_ms = []
    fps_ema = None
    frame_id = 0

    print("Keys: [ESC]=quit  [+]/[-]=sigma up/down  [s]=save frame")

    while True:
        ok, frame = cap.read()
        if not ok:
            # ちょっと待ってリトライ
            time.sleep(0.01)
            continue

        frame_id += 1
        do_infer = True
        if args.skip > 0 and (frame_id % (args.skip + 1)) != 1:
            do_infer = False

        if do_infer:
            x, bgr_proc = bgr_to_nchw_float01(frame, args.proc_w, args.proc_h)

            t_run0 = time.perf_counter()
            y = sess.run(None, {in0: x, in1: sigma})[0]
            t_run1 = time.perf_counter()

            out_bgr_proc = nchw_float01_to_bgr_uint8(y)

            dt_ms = (t_run1 - t_run0) * 1000.0
            times_ms.append(dt_ms)
            if len(times_ms) > args.repeat_stat:
                times_ms.pop(0)
            mean_ms = sum(times_ms) / len(times_ms)

            # 表示FPS（全体ループ）
            if fps_ema is None:
                fps_ema = 0.0
            # “推論時間”からの簡易FPS見積もり
            est_fps = 1000.0 / max(mean_ms, 1e-6)
            fps_ema = 0.9 * fps_ema + 0.1 * est_fps

            if args.view == "upscale":
                out_show = cv2.resize(out_bgr_proc, (act_w, act_h), interpolation=cv2.INTER_LINEAR)
                in_show = cv2.resize(frame, (act_w, act_h), interpolation=cv2.INTER_LINEAR)
            else:
                out_show = out_bgr_proc
                in_show = bgr_proc

            if args.side_by_side:
                show = cv2.hconcat([in_show, out_show])
            else:
                show = out_show

            cv2.putText(
                show,
                f"{args.device}  sigma={args.sigma:.1f}  infer~{mean_ms:.2f}ms  fps~{fps_ema:.1f}",
                (10, 30),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.9,
                (0, 255, 0),
                2,
                cv2.LINE_AA,
            )
        else:
            # 推論スキップ時は入力だけ表示
            show = frame

        cv2.imshow("FFDNet Denoise", show)
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
            fn = f"capture_denoised_{ts}.png"
            cv2.imwrite(fn, show)
            print("saved:", fn)

    cap.release()
    cv2.destroyAllWindows()


if __name__ == "__main__":
    main()