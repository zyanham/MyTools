import os
from pathlib import Path

import cv2
import numpy as np
import onnx

from onnxruntime.quantization import CalibrationDataReader
from quark.onnx.quantization.config import Config, get_default_config
from quark.onnx import ModelQuantizer


def get_model_input_name(input_model_path: str) -> str:
    model = onnx.load(input_model_path)
    return model.graph.input[0].name


class YOLOXCalibrationDataReader(CalibrationDataReader):
    def __init__(self, image_dir: str, input_name: str, input_size=(640, 640)):
        self.input_name = input_name
        self.input_h, self.input_w = input_size
        self.enum_data = None
        self.data_list = self._load_images(image_dir)

    def _preprocess_one(self, img_bgr: np.ndarray) -> np.ndarray:
        # YOLOX letterbox風
        padded = np.ones((self.input_h, self.input_w, 3), dtype=np.uint8) * 114
        ratio = min(self.input_h / img_bgr.shape[0], self.input_w / img_bgr.shape[1])
        resized = cv2.resize(
            img_bgr,
            (int(img_bgr.shape[1] * ratio), int(img_bgr.shape[0] * ratio)),
            interpolation=cv2.INTER_LINEAR,
        ).astype(np.uint8)

        padded[: resized.shape[0], : resized.shape[1]] = resized
        x = padded.transpose(2, 0, 1).astype(np.float32)  # NCHW
        x = np.expand_dims(x, axis=0)
        return np.ascontiguousarray(x)

    def _load_images(self, image_dir: str):
        out = []
        for name in sorted(os.listdir(image_dir)):
            if not name.lower().endswith((".jpg", ".jpeg", ".png", ".bmp")):
                continue
            fp = os.path.join(image_dir, name)
            img = cv2.imread(fp)
            if img is None:
                continue
            out.append(self._preprocess_one(img))
        return out

    def get_next(self):
        if self.enum_data is None:
            self.enum_data = iter([{self.input_name: data} for data in self.data_list])
        return next(self.enum_data, None)

    def rewind(self):
        self.enum_data = None


def main():
    root = Path(r"D:\RyzenWS\RyzenAI-SW_1.7.1\TEST_WS\YOLOX")
    input_model = root / "original_yolox" / "models" / "yolox_m_op17.onnx"
    output_model = root / "original_yolox" / "models" / "yolox_m_xint8.onnx"
    calib_dir = root / "calib_images"

    input_name = get_model_input_name(str(input_model))
    dr = YOLOXCalibrationDataReader(str(calib_dir), input_name, input_size=(640, 640))

    quant_config = get_default_config("XINT8")
    config = Config(global_quant_config=quant_config)

    quantizer = ModelQuantizer(config)
    quantizer.quantize_model(str(input_model), str(output_model), dr)

    print(f"[OK] saved: {output_model}")


if __name__ == "__main__":
    main()