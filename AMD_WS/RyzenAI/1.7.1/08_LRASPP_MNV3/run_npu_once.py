from pathlib import Path
import os
import numpy as np
import onnxruntime as ort

ROOT = Path(".").resolve()
onnx_path = ROOT / "weights" / "lraspp_mobilenetv3_large_op17_1x3x512x512.onnx"
config_path = ROOT / "vai_ep_config.json"
cache_dir = ROOT / "cache"
results_dir = ROOT / "results"

cache_dir.mkdir(exist_ok=True)
results_dir.mkdir(exist_ok=True)

# EP割当レポート
os.environ["XLNX_ONNX_EP_REPORT_FILE"] = "lraspp_mnv3_ep_report.json"

provider_options = {
    "config_file": str(config_path),
    "cache_dir": str(cache_dir),
    "cache_key": "lraspp_mnv3_bf16_op17_512",
    "enable_cache_file_io_in_mem": "0"
}

print("[INFO] ONNX:", onnx_path)
print("[INFO] config:", config_path)
print("[INFO] cache:", cache_dir)

sess = ort.InferenceSession(
    str(onnx_path),
    providers=["VitisAIExecutionProvider", "CPUExecutionProvider"],
    provider_options=[provider_options, {}],
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
    np.save(results_dir / f"output_{i}.npy", y)

print("[OK] NPU inference done")