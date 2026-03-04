import argparse
import glob
from pathlib import Path

import numpy as np
from PIL import Image

from onnxruntime.quantization.calibrate import CalibrationDataReader
from quark.onnx.quantization.config import Config, get_default_config
from quark.onnx import ModelQuantizer


class CalibReader(CalibrationDataReader):
    def __init__(self, calib_dir: str, input_name: str, sigma_name: str, h: int, w: int, sigma: float, max_samples: int):
        super().__init__()
        self.input_name = input_name
        self.sigma_name = sigma_name
        self.h = h
        self.w = w
        self.sigma = np.array([[[[sigma / 255.0]]]], dtype=np.float32)

        exts = (".jpg", ".jpeg", ".png", ".bmp", ".webp")
        files = [str(p) for p in Path(calib_dir).rglob("*") if p.suffix.lower() in exts]
        files = sorted(files)
        if max_samples > 0:
            files = files[:max_samples]
        if not files:
            raise FileNotFoundError(f"No images in {calib_dir}")
        self.files = files
        self.i = 0

    def get_next(self):
        while self.i < len(self.files):
            fp = self.files[self.i]
            self.i += 1
            try:
                im = Image.open(fp).convert("RGB")
                im = im.resize((self.w, self.h), resample=Image.BILINEAR)
                x = (np.asarray(im, dtype=np.float32) / 255.0)          # HWC
                x = np.transpose(x, (2, 0, 1))[None, ...].copy()        # NCHW
                return {self.input_name: x, self.sigma_name: self.sigma}
            except Exception:
                continue
        return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--fp32", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--calib_dir", required=True)
    ap.add_argument("--h", type=int, default=544)
    ap.add_argument("--w", type=int, default=960)
    ap.add_argument("--sigma", type=float, default=15.0)
    ap.add_argument("--samples", type=int, default=128)
    ap.add_argument("--dtype", choices=["XINT8", "A8W8", "A16W8"], default="XINT8")
    ap.add_argument("--input_name", default="input")
    ap.add_argument("--sigma_name", default="sigma")
    args = ap.parse_args()

    dr = CalibReader(args.calib_dir, args.input_name, args.sigma_name, args.h, args.w, args.sigma, args.samples)

    quant_config = get_default_config(args.dtype)
    config = Config(global_quant_config=quant_config)

    q = ModelQuantizer(config)
    q.quantize_model(args.fp32, args.out, dr)
    print("[OK] wrote:", args.out)


if __name__ == "__main__":
    main()