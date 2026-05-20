import argparse
from pathlib import Path
import time
import cv2

from lraspp_utils import (
    build_session,
    infer_mask,
    make_overlay,
    summarize_classes,
    draw_class_legend,
)

ROOT = Path(__file__).resolve().parent
DEFAULT_ONNX = ROOT / "weights" / "lraspp_mobilenetv3_large_op17_1x3x512x512.onnx"
DEFAULT_CONFIG = ROOT / "vai_ep_config.json"
DEFAULT_CACHE = ROOT / "cache"
DEFAULT_RESULTS = ROOT / "results"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--camera_id", type=int, default=0)
    ap.add_argument("--width", type=int, default=640)
    ap.add_argument("--height", type=int, default=480)
    ap.add_argument("--onnx", default=str(DEFAULT_ONNX))
    ap.add_argument("--config", default=str(DEFAULT_CONFIG))
    ap.add_argument("--cache_dir", default=str(DEFAULT_CACHE))
    ap.add_argument("--cache_key", default="lraspp_mnv3_bf16_op17_512")
    args = ap.parse_args()

    results_dir = DEFAULT_RESULTS / "camera"
    results_dir.mkdir(parents=True, exist_ok=True)

    sess = build_session(
        onnx_path=args.onnx,
        config_path=args.config,
        cache_dir=args.cache_dir,
        cache_key=args.cache_key,
        report_file="lraspp_mnv3_camera_ep_report.json",
    )
    print("[INFO] providers:", sess.get_providers())

    cap = cv2.VideoCapture(args.camera_id, cv2.CAP_DSHOW)
    if not cap.isOpened():
        cap = cv2.VideoCapture(args.camera_id)

    if not cap.isOpened():
        raise RuntimeError("Failed to open camera")

    cap.set(cv2.CAP_PROP_FRAME_WIDTH, args.width)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, args.height)

    prev_t = time.time()
    frame_count = 0

    print("[INFO] press 'q' to quit, 's' to save snapshot")

    while True:
        ret, frame = cap.read()
        if not ret:
            print("[WARN] camera read failed")
            break

        t0 = time.time()
        _, mask_512 = infer_mask(sess, frame, input_size=512)
        class_items = summarize_classes(mask_512)
        overlay, _ = make_overlay(frame, mask_512)
        overlay = draw_class_legend(overlay, class_items)

        t1 = time.time()
        frame_count += 1

        dt = t1 - prev_t
        prev_t = t1
        fps = 1.0 / dt if dt > 0 else 0.0
        infer_ms = (t1 - t0) * 1000.0

        cv2.putText(
            overlay,
            f"FPS: {fps:.2f}  Infer: {infer_ms:.1f} ms",
            (10, overlay.shape[0] - 15),
            cv2.FONT_HERSHEY_SIMPLEX,
            0.65,
            (0, 255, 255),
            2,
            cv2.LINE_AA,
        )

        cv2.imshow("LRASPP NPU Camera Demo", overlay)
        key = cv2.waitKey(1) & 0xFF

        if key == ord("q"):
            break
        elif key == ord("s"):
            ts = int(time.time())
            out_path = results_dir / f"camera_overlay_{ts}.jpg"
            cv2.imwrite(str(out_path), overlay)
            print("[OK] saved:", out_path)

    cap.release()
    cv2.destroyAllWindows()


if __name__ == "__main__":
    main()