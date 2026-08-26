import argparse
import cv2
import numpy as np
import onnxruntime as ort


def preprocess(image_path, input_shape):
    img = cv2.imread(image_path)
    if img is None:
        raise FileNotFoundError(image_path)

    _, c, h, w = input_shape
    resized = cv2.resize(img, (w, h), interpolation=cv2.INTER_LINEAR)
    rgb = cv2.cvtColor(resized, cv2.COLOR_BGR2RGB)
    x = rgb.astype(np.float32) / 255.0
    x = np.transpose(x, (2, 0, 1))
    x = np.expand_dims(x, 0)
    return x


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--model", default="yolo11n-pose.onnx")
    ap.add_argument("--input", required=True)
    ap.add_argument("--provider_config", default=r".\vaip_config.json")
    ap.add_argument("--cpu", action="store_true")
    args = ap.parse_args()

    if args.cpu:
        sess = ort.InferenceSession(args.model, providers=["CPUExecutionProvider"])
    else:
        sess = ort.InferenceSession(
            args.model,
            providers=["VitisAIExecutionProvider", "CPUExecutionProvider"],
            provider_options=[{"config_file": args.provider_config}, {}],
        )

    print("Providers:", sess.get_providers())
    for i, inp in enumerate(sess.get_inputs()):
        print(f"input[{i}] {inp.name} shape={inp.shape} type={inp.type}")
    for i, out in enumerate(sess.get_outputs()):
        print(f"output[{i}] {out.name} shape={out.shape} type={out.type}")

    input_meta = sess.get_inputs()[0]
    shape = [1 if isinstance(x, str) else x for x in input_meta.shape]
    x = preprocess(args.input, shape)

    outs = sess.run(None, {input_meta.name: x})
    for i, out in enumerate(outs):
        arr = np.asarray(out)
        print(
            f"output[{i}] shape={arr.shape} dtype={arr.dtype} "
            f"min={np.nanmin(arr):.6f} max={np.nanmax(arr):.6f} mean={np.nanmean(arr):.6f}"
        )


if __name__ == "__main__":
    main()