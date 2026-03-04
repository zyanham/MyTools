import argparse
import statistics
import time
import os

import cv2
import numpy as np
import onnxruntime as ort


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--onnx", required=True)
    ap.add_argument("--input", required=True)
    ap.add_argument("--out", default="out.png")
    ap.add_argument("--device", choices=["cpu", "npu"], default="npu")
    ap.add_argument("--h", type=int, default=544)
    ap.add_argument("--w", type=int, default=960)
    ap.add_argument("--fit", choices=["resize", "strict"], default="resize")
    ap.add_argument("--sigma", type=float, default=15.0, help="noise level in [0..75] like 15")
    ap.add_argument("--warmup", type=int, default=5)
    ap.add_argument("--repeat", type=int, default=30)

    # cache/report（任意）
    ap.add_argument("--cache_dir", default="./vaip_cache")
    ap.add_argument("--cache_key", default="ffdnet_544x960_fp32")
    ap.add_argument("--report", action="store_true")
    ap.add_argument("--report_file", default="vitisai_ep_report.json")
    args = ap.parse_args()

    so = ort.SessionOptions()
    so.log_severity_level = 2

    if args.device == "npu":
        if args.report:
            os.environ["XLNX_ONNX_EP_REPORT_FILE"] = os.path.abspath(args.report_file)
        vai = {
            "cache_dir": os.path.abspath(args.cache_dir),
            "cache_key": args.cache_key,
            "enable_cache_file_io_in_mem": 0 if args.report else 1,
        }
        sess = ort.InferenceSession(
            args.onnx,
            sess_options=so,
            providers=["VitisAIExecutionProvider", "CPUExecutionProvider"],
            provider_options=[vai, {}],
        )
    else:
        sess = ort.InferenceSession(args.onnx, sess_options=so, providers=["CPUExecutionProvider"])

    in0 = sess.get_inputs()[0].name   # input
    in1 = sess.get_inputs()[1].name   # sigma
    print("[providers]", sess.get_providers())
    print("[inputs]", [(i.name, i.shape, i.type) for i in sess.get_inputs()])

    bgr = cv2.imread(args.input, cv2.IMREAD_COLOR)
    if bgr is None:
        raise FileNotFoundError(args.input)

    if args.fit == "resize":
        bgr = cv2.resize(bgr, (args.w, args.h), interpolation=cv2.INTER_AREA)
    else:
        if bgr.shape[0] != args.h or bgr.shape[1] != args.w:
            raise ValueError(f"strict: image is {bgr.shape[1]}x{bgr.shape[0]} expected {args.w}x{args.h}")

    rgb = cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB)
    x = (rgb.astype(np.float32) / 255.0)              # HWC
    x = np.transpose(x, (2, 0, 1))[None, ...].copy()  # NCHW

    sigma = np.array([[[[args.sigma / 255.0]]]], dtype=np.float32)

    # warmup
    for _ in range(max(0, args.warmup)):
        _ = sess.run(None, {in0: x, in1: sigma})

    # repeats
    times = []
    y = None
    for _ in range(max(1, args.repeat)):
        t0 = time.perf_counter()
        y = sess.run(None, {in0: x, in1: sigma})[0]
        t1 = time.perf_counter()
        times.append((t1 - t0) * 1000.0)

    print(f"runs: {len(times)} warmup: {args.warmup}")
    print(
        "latency_ms: mean={:.2f} median={:.2f} min={:.2f} max={:.2f}".format(
            sum(times) / len(times),
            statistics.median(times),
            min(times),
            max(times),
        )
    )
    print("[output]", sess.get_outputs()[0].shape, y.shape)

    # save last output
    y = np.clip(y[0], 0.0, 1.0)                        # CHW
    y = np.transpose(y, (1, 2, 0))                     # HWC RGB
    y = (y * 255.0).astype(np.uint8)
    out_bgr = cv2.cvtColor(y, cv2.COLOR_RGB2BGR)
    cv2.imwrite(args.out, out_bgr)
    print("saved:", args.out)


if __name__ == "__main__":
    main()