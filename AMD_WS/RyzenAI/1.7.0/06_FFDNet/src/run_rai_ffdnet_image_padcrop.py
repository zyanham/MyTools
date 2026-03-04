import argparse
import os
import time
import statistics

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


def make_session(args):
    so = ort.SessionOptions()
    so.log_severity_level = 2
    if args.device == "npu":
        # report envが残っていると落ちるケースがあるので念のため消す
        if not args.report:
            os.environ.pop("XLNX_ONNX_EP_REPORT_FILE", None)
        else:
            os.environ["XLNX_ONNX_EP_REPORT_FILE"] = os.path.abspath(args.report_file)

        vai = {
            "cache_dir": os.path.abspath(args.cache_dir),
            "cache_key": args.cache_key,
            "enable_cache_file_io_in_mem": 0 if args.report else 1,
        }
        return ort.InferenceSession(
            args.onnx,
            sess_options=so,
            providers=["VitisAIExecutionProvider", "CPUExecutionProvider"],
            provider_options=[vai, {}],
        )
    else:
        return ort.InferenceSession(args.onnx, sess_options=so, providers=["CPUExecutionProvider"])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--onnx", required=True)
    ap.add_argument("--input", required=True)
    ap.add_argument("--out", default="out.png")
    ap.add_argument("--device", choices=["cpu", "npu"], default="npu")

    # 元の評価解像（FullHD）
    ap.add_argument("--src_h", type=int, default=1080)
    ap.add_argument("--src_w", type=int, default=1920)

    # モデル解像（推奨: 1088x1920）
    ap.add_argument("--h", type=int, default=1088)
    ap.add_argument("--w", type=int, default=1920)

    ap.add_argument("--fit", choices=["resize", "strict"], default="resize")
    ap.add_argument("--sigma", type=float, default=15.0)
    ap.add_argument("--warmup", type=int, default=5)
    ap.add_argument("--repeat", type=int, default=30)

    ap.add_argument("--cache_dir", default="./vaip_cache")
    ap.add_argument("--cache_key", default="ffdnet_1088_1920_fp32")
    ap.add_argument("--report", action="store_true")
    ap.add_argument("--report_file", default="vitisai_ep_report.json")
    args = ap.parse_args()

    sess = make_session(args)
    in0 = sess.get_inputs()[0].name
    in1 = sess.get_inputs()[1].name
    print("[providers]", sess.get_providers())
    print("[inputs]", [(i.name, i.shape, i.type) for i in sess.get_inputs()])

    bgr = cv2.imread(args.input, cv2.IMREAD_COLOR)
    if bgr is None:
        raise FileNotFoundError(args.input)

    # まず評価解像へ揃える（1080x1920）
    if args.fit == "resize":
        bgr = cv2.resize(bgr, (args.src_w, args.src_h), interpolation=cv2.INTER_AREA)
    else:
        if bgr.shape[0] != args.src_h or bgr.shape[1] != args.src_w:
            raise ValueError(f"strict: image is {bgr.shape[1]}x{bgr.shape[0]} expected {args.src_w}x{args.src_h}")

    # 次にモデル解像へ反射パッド（1088x1920）
    bgr_pad, pads = reflect_pad_to(bgr, args.h, args.w)

    rgb = cv2.cvtColor(bgr_pad, cv2.COLOR_BGR2RGB)
    x = (rgb.astype(np.float32) / 255.0)
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
    print("latency_ms: mean={:.2f} median={:.2f} min={:.2f} max={:.2f}".format(
        sum(times)/len(times), statistics.median(times), min(times), max(times)
    ))
    print("[output]", sess.get_outputs()[0].shape, y.shape)

    # save last output（モデル解像→評価解像に戻す）
    y = np.clip(y[0], 0.0, 1.0)                # CHW
    y = np.transpose(y, (1, 2, 0))             # HWC RGB
    y = (y * 255.0).astype(np.uint8)
    y = crop_from_pad(y, pads, args.src_h, args.src_w)

    out_bgr = cv2.cvtColor(y, cv2.COLOR_RGB2BGR)
    cv2.imwrite(args.out, out_bgr)
    print("saved:", args.out)


if __name__ == "__main__":
    main()