from pathlib import Path
import numpy as np
import onnxruntime as ort

onnx_path = Path("weights/lraspp_mobilenetv3_large_op17_1x3x512x512.onnx")

sess = ort.InferenceSession(
    str(onnx_path),
    providers=["CPUExecutionProvider"],
)

print("[INFO] providers:", sess.get_providers())

inp = sess.get_inputs()[0]
print("[INFO] input:", inp.name, inp.shape, inp.type)

x = np.random.rand(1, 3, 512, 512).astype(np.float32)

outputs = sess.run(None, {inp.name: x})

for i, y in enumerate(outputs):
    y = np.asarray(y)
    print(
        f"[INFO] output[{i}] shape={y.shape} dtype={y.dtype} "
        f"nan={np.isnan(y).any()} inf={np.isinf(y).any()} "
        f"min={y.min():.6f} max={y.max():.6f}"
    )

print("[OK] CPU inference done")