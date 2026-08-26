from pathlib import Path
import torch
import torchvision


ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "LRASPP_MNV3" / "weights"


class LRASPPWrapper(torch.nn.Module):
    """
    torchvision segmentation model は出力が dict なので、
    ONNX export しやすいように y["out"] だけを返す。
    """
    def __init__(self, model):
        super().__init__()
        self.model = model.eval()

    def forward(self, x):
        y = self.model(x)
        return y["out"]


def main():
    print("[INFO] Loading LR-ASPP MobileNetV3 Large pretrained weights...")

    model = torchvision.models.segmentation.lraspp_mobilenet_v3_large(
        weights=torchvision.models.segmentation.LRASPP_MobileNet_V3_Large_Weights.DEFAULT
    )

    model = LRASPPWrapper(model).eval()

    # まずはNPUスモーク用に 512x512 固定。
    # 本来のTorchVision推奨は可変入力寄りだが、NPU確認ではstatic shapeが楽。
    dummy = torch.randn(1, 3, 512, 512, dtype=torch.float32)

    onnx_path = OUT_DIR / "lraspp_mobilenetv3_large_op17_1x3x512x512.onnx"

    print(f"[INFO] Exporting to {onnx_path}")

    with torch.no_grad():
        torch.onnx.export(
            model,
            dummy,
            str(onnx_path),
            opset_version=17,
            input_names=["input"],
            output_names=["logits"],
            dynamic_axes=None,
            do_constant_folding=True,
            dynamo=False,   # 追加：従来ONNX exporterを使う
        )
        
    print("[OK] Export complete")
    print(f"[OK] ONNX: {onnx_path}")


if __name__ == "__main__":
    main()