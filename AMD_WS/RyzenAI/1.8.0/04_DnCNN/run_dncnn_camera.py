import argparse
import time

import cv2
import numpy as np
import onnxruntime as ort


def make_session(model_path: str, device: str):
    providers = ["CPUExecutionProvider"]
    if device == "npu":
        providers = ["VitisAIExecutionProvider", "CPUExecutionProvider"]

    print("Available providers:", ort.get_available_providers())
    sess = ort.InferenceSession(model_path, providers=providers)
    print("Active providers   :", sess.get_providers())
    return sess


def add_demo_noise(frame_bgr: np.ndarray, sigma: float) -> np.ndarray:
    if sigma <= 0:
        return frame_bgr
    noise = np.random.normal(0.0, sigma, frame_bgr.shape).astype(np.float32)
    noisy = frame_bgr.astype(np.float32) + noise
    noisy = np.clip(noisy, 0, 255).astype(np.uint8)
    return noisy


def preprocess(frame_bgr: np.ndarray, w: int, h: int) -> np.ndarray:
    frame = cv2.resize(frame_bgr, (w, h), interpolation=cv2.INTER_LINEAR)
    frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    frame = frame.astype(np.float32) / 255.0
    frame = np.transpose(frame, (2, 0, 1))[None, ...]
    return np.ascontiguousarray(frame)


def postprocess(y: np.ndarray, out_w: int, out_h: int) -> np.ndarray:
    y = y[0]
    y = np.transpose(y, (1, 2, 0))
    y = np.clip(y, 0.0, 1.0)
    y = (y * 255.0).astype(np.uint8)
    y = cv2.cvtColor(y, cv2.COLOR_RGB2BGR)
    y = cv2.resize(y, (out_w, out_h), interpolation=cv2.INTER_LINEAR)
    return y


def blend_denoise(base_bgr: np.ndarray, denoised_bgr: np.ndarray, strength: float) -> np.ndarray:
    strength = float(np.clip(strength, 0.0, 1.0))
    out = cv2.addWeighted(base_bgr, 1.0 - strength, denoised_bgr, strength, 0.0)
    return out


def make_diff_map(a_bgr: np.ndarray, b_bgr: np.ndarray, gain: float = 4.0) -> np.ndarray:
    diff = cv2.absdiff(a_bgr, b_bgr).astype(np.float32) * gain
    diff = np.clip(diff, 0, 255).astype(np.uint8)
    return diff


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--model", required=True)
    ap.add_argument("--device", choices=["cpu", "npu"], default="npu")
    ap.add_argument("--camera_id", type=int, default=0)
    ap.add_argument("--model_width", type=int, default=640)
    ap.add_argument("--model_height", type=int, default=360)

    ap.add_argument("--strength", type=float, default=1.0,
                    help="0.0=original, 1.0=full denoise")
    ap.add_argument("--demo_noise_sigma", type=float, default=0.0,
                    help="demo only: add Gaussian noise in pixel units (e.g. 10, 20, 30)")
    ap.add_argument("--show_diff", action="store_true",
                    help="show amplified difference map")
    args = ap.parse_args()

    sess = make_session(args.model, args.device)
    input_name = sess.get_inputs()[0].name
    output_name = sess.get_outputs()[0].name

    cap = cv2.VideoCapture(args.camera_id, cv2.CAP_DSHOW)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, args.model_width)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, args.model_height)
    cap.set(cv2.CAP_PROP_BUFFERSIZE, 1)

    if not cap.isOpened():
        raise RuntimeError("Failed to open webcam")

    fps = 0.0
    while True:
        ok, frame = cap.read()
        if not ok:
            break

        h, w = frame.shape[:2]

        # デモ用に人工ノイズを加えた入力を作る
        noisy_frame = add_demo_noise(frame, args.demo_noise_sigma)

        x = preprocess(noisy_frame, args.model_width, args.model_height)

        t0 = time.time()
        y = sess.run([output_name], {input_name: x})[0]
        t1 = time.time()

        denoised = postprocess(y, w, h)
        mixed = blend_denoise(noisy_frame, denoised, args.strength)

        inst_fps = 1.0 / max(t1 - t0, 1e-6)
        fps = inst_fps if fps == 0.0 else (0.9 * fps + 0.1 * inst_fps)

        panels = [noisy_frame, mixed]

        if args.show_diff:
            diff = make_diff_map(noisy_frame, mixed, gain=5.0)
            panels.append(diff)

        vis = np.hstack(panels)

        cv2.putText(vis, f"{args.device.upper()} {fps:.1f} FPS", (20, 30),
                    cv2.FONT_HERSHEY_SIMPLEX, 1.0, (0, 255, 0), 2)
        cv2.putText(vis, f"strength={args.strength:.2f}", (20, 65),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 255), 2)
        cv2.putText(vis, f"demo_noise_sigma={args.demo_noise_sigma:.1f}", (20, 95),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 255), 2)

        cv2.putText(vis, "Input", (20, h - 20),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.8, (255, 255, 255), 2)
        cv2.putText(vis, "DnCNN", (w + 20, h - 20),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.8, (255, 255, 255), 2)
        if args.show_diff:
            cv2.putText(vis, "Diff x5", (2 * w + 20, h - 20),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.8, (255, 255, 255), 2)

        cv2.imshow("DnCNN Camera Denoise", vis)
        key = cv2.waitKey(1) & 0xFF
        if key in (27, ord("q")):
            break

    cap.release()
    cv2.destroyAllWindows()


if __name__ == "__main__":
    main()