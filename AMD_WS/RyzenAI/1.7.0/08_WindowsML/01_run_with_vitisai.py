import os
import numpy as np
from pathlib import Path
from importlib import metadata

def _fix_winrt_runtime():
    try:
        site = Path(str(metadata.distribution("winrt-runtime").locate_file("")))
        dll = site / "winrt" / "msvcp140.dll"
        if dll.exists():
            dll.unlink()
    except Exception as e:
        print("[WARN] winrt-runtime fix skipped:", e)

def _shape_to_concrete(shape):
    out = []
    for i, dim in enumerate(shape):
        if isinstance(dim, int) and dim > 0:
            out.append(dim)
        else:
            # 動的次元は適当に埋める
            if i == 0:
                out.append(1)      # batch
            elif i in (2, 3):
                out.append(224)    # H/W
            else:
                out.append(3)      # C など
    return out

def _dtype_from_ort_type(ort_type: str):
    t = ort_type.lower()
    if "float16" in t:
        return np.float16
    if "float" in t:
        return np.float32
    if "int64" in t:
        return np.int64
    if "int32" in t:
        return np.int32
    if "int8" in t:
        return np.int8
    if "uint8" in t:
        return np.uint8
    return np.float32

def main():
    _fix_winrt_runtime()

    from winui3.microsoft.windows.applicationmodel.dynamicdependency.bootstrap import (
        InitializeOptions, initialize
    )
    import winui3.microsoft.windows.ai.machinelearning as winml
    import onnxruntime as ort

    model_path = os.environ.get("MODEL_ONNX", r".\model.onnx")
    if not os.path.exists(model_path):
        raise FileNotFoundError(f"MODEL_ONNX not found: {model_path}")

    with initialize(options=InitializeOptions.ON_NO_MATCH_SHOW_UI):
        # 1) Windows ML から VitisAI EP を準備
        catalog = winml.ExecutionProviderCatalog.get_default()
        providers = catalog.find_all_providers()
        vitis = [p for p in providers if p.name == "VitisAIExecutionProvider"]
        if not vitis:
            raise RuntimeError("VitisAIExecutionProvider not found")

        p = vitis[0]
        result = p.ensure_ready_async().get()
        if result.status != winml.ExecutionProviderReadyResultState.SUCCESS:
            raise RuntimeError(f"ensure_ready_async failed: {result.status}")
        if not p.library_path:
            raise RuntimeError("library_path is empty")

        # 2) Python ORT に登録
        ort.register_execution_provider_library(p.name, p.library_path)

        # 3) EP device を列挙して VitisAI を拾う
        ep_devices = ort.get_ep_devices()
        print("== ep_devices ==")
        for i, d in enumerate(ep_devices):
            print(f"[{i}] ep_name={getattr(d, 'ep_name', None)} "
                  f"vendor={getattr(d, 'ep_vendor', None)} "
                  f"device={getattr(d, 'device', None)}")

        vitis_devices = [d for d in ep_devices if getattr(d, "ep_name", "") == "VitisAIExecutionProvider"]
        if not vitis_devices:
            raise RuntimeError("No VitisAIExecutionProvider device found in ort.get_ep_devices()")

        # 4) セッションを明示的に VitisAI device で作る
        so = ort.SessionOptions()
        # provider options はまず空でよい
        so.add_provider_for_devices([vitis_devices[0]], {})

        sess = ort.InferenceSession(model_path, sess_options=so)

        print("session providers:", sess.get_providers())

        # 5) ダミー入力で1回回す
        inputs = {}
        for inp in sess.get_inputs():
            shape = _shape_to_concrete(inp.shape)
            dtype = _dtype_from_ort_type(inp.type)

            if np.issubdtype(dtype, np.floating):
                x = (np.random.rand(*shape) * 0.1).astype(dtype)
            else:
                x = np.zeros(shape, dtype=dtype)

            inputs[inp.name] = x
            print(f"input: name={inp.name}, type={inp.type}, shape={shape}, dtype={dtype}")

        outputs = sess.run(None, inputs)

        print("== outputs ==")
        for i, y in enumerate(outputs):
            print(f"[{i}] shape={getattr(y, 'shape', None)} dtype={getattr(y, 'dtype', None)}")

if __name__ == "__main__":
    main()