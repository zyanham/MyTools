import argparse
from pathlib import Path

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


def preprocess(img_bgr: np.ndarray, w: int, h: int) -> np.ndarray:
    img = cv2.resize(img_bgr, (w, h), interpolation=cv2.INTER_LINEAR)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img = img.astype(np.float32) / 255.0
    img = np.transpose(img, (2, 0, 1))[None, ...]
    return np.ascontiguousarray(img)


def postprocess(y: np.ndarray, orig_w: int, orig_h: int) -> np.ndarray:
    y = y[0]
    y = np.transpose(y, (1, 2, 0))
    y = np.clip(y, 0.0, 1.0)
    y = (y * 255.0).astype(np.uint8)
    y = cv2.cvtColor(y, cv2.COLOR_RGB2BGR)
    y = cv2.resize(y, (orig_w, orig_h), interpolation=cv2.INTER_LINEAR)
    return y


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--model", required=True)
    ap.add_argument("--input_image", required=True)
    ap.add_argument("--output_image", required=True)
    ap.add_argument("--device", choices=["cpu", "npu"], default="npu")
    ap.add_argument("--model_width", type=int, default=640)
    ap.add_argument("--model_height", type=int, default=360)
    args = ap.parse_args()

    sess = make_session(args.model, args.device)
    input_name = sess.get_inputs()[0].name
    output_name = sess.get_outputs()[0].name

    img = cv2.imread(args.input_image)
    if img is None:
        raise FileNotFoundError(args.input_image)

    h, w = img.shape[:2]
    x = preprocess(img, args.model_width, args.model_height)
    y = sess.run([output_name], {input_name: x})[0]
    den = postprocess(y, w, h)

    side = np.hstack([img, den])
    Path(args.output_image).parent.mkdir(parents=True, exist_ok=True)
    cv2.imwrite(args.output_image, side)
    print(f"[OK] saved: {args.output_image}")


if __name__ == "__main__":
    main()