import sys
from pathlib import Path
from importlib import metadata

def _fix_winrt_runtime():
    # MS docs snippet: winrt-runtime内の msvcp140.dll が衝突する場合があるので削除
    site = Path(str(metadata.distribution("winrt-runtime").locate_file("")))
    dll = site / "winrt" / "msvcp140.dll"
    if dll.exists():
        dll.unlink()

def main():
    _fix_winrt_runtime()

    from winui3.microsoft.windows.applicationmodel.dynamicdependency.bootstrap import (
        InitializeOptions, initialize
    )
    import winui3.microsoft.windows.ai.machinelearning as winml
    import onnxruntime as ort

    with initialize(options=InitializeOptions.ON_NO_MATCH_SHOW_UI):
        catalog = winml.ExecutionProviderCatalog.get_default()
        providers = catalog.find_all_providers()

        print("== ExecutionProviderCatalog.find_all_providers() ==")
        for p in providers:
            print(f"- {p.name:28s} ready_state={p.ready_state} lib={'yes' if p.library_path else 'no'}")

        # AMD NPU EP
        vitis = [p for p in providers if p.name == "VitisAIExecutionProvider"]
        if not vitis:
            print("\n[NG] VitisAIExecutionProvider is NOT listed.")
            print("    -> Windows ML judged it 'not compatible' (often driver gating).")
            return 2

        p = vitis[0]
        print(f"\n== ensure_ready_async() : {p.name} ==")
        r = p.ensure_ready_async().get()
        print("result.status:", r.status)

        if not p.library_path:
            print("[NG] library_path empty after ensure_ready_async()")
            return 3

        # Pythonでは TryRegister() ではなく register_execution_provider_library を使うのがガイドライン
        # (MS register execution providers doc)
        ort.register_execution_provider_library(p.name, p.library_path)  # :contentReference[oaicite:3]{index=3}

        print("\n== ort.get_ep_devices() ==")
        devs = ort.get_ep_devices()
        for d in devs:
            print(f"- {d.ep_name:28s} type={d.hardware_device.type}")

        npu = [d for d in devs if d.ep_name == "VitisAIExecutionProvider"
               and d.hardware_device.type == ort.OrtHardwareDeviceType.NPU]
        print("\nAMD NPU visible via Windows ML:", bool(npu))
        return 0

if __name__ == "__main__":
    raise SystemExit(main())