r"""Quantize the color DnCNN ONNX model for Ryzen AI with AMD Quark.

Recommended first trial (matches run_dncnn_camera.py with demo sigma=20):

    python quantize_dncnn_quark_renewed.py ^
      --input_model KAIR\models\dncnn_color_blind_360x640.onnx ^
      --output_model KAIR\models\dncnn_color_blind_sigma20_XINT8.onnx ^
      --calib_dir calib_clean ^
      --sigma_min 20 --sigma_max 20

The calibration directory should normally contain clean images. This script adds
Gaussian noise itself. Use --images_already_noisy only when the files already
contain the desired noise.
"""

import argparse
import os
from pathlib import Path

import cv2
import numpy as np
import onnx
from onnxruntime.quantization import CalibrationDataReader
from quark.onnx import ModelQuantizer
from quark.onnx.quantization.config.config import Config
from quark.onnx.quantization.config.custom_config import get_default_config


IMG_EXTS = (".jpg", ".jpeg", ".png", ".bmp", ".tif", ".tiff")

# Confirmed from dncnn_color_blind_360x640.onnx.
DEFAULT_TAIL_NODES = [
    "/model/model.38/Conv",
    "/Sub",
]


def get_input_info(model_path):
    model = onnx.load(model_path)
    inp = model.graph.input[0]

    dims = []
    for dim in inp.type.tensor_type.shape.dim:
        dims.append(dim.dim_value if dim.dim_value else None)

    node_names = {node.name for node in model.graph.node}
    print(f"ONNX input name : {inp.name}")
    print(f"ONNX input shape: {dims}")
    return inp.name, dims, node_names


class DnCNNCalibrationDataReader(CalibrationDataReader):
    def __init__(
        self,
        image_dir,
        input_name,
        width=640,
        height=360,
        sigma_min=20.0,
        sigma_max=20.0,
        rgb=True,
        clip_input=True,
        images_already_noisy=False,
        samples_per_image=1,
        seed=12345,
    ):
        self.image_dir = image_dir
        self.input_name = input_name
        self.width = width
        self.height = height
        self.sigma_min = sigma_min
        self.sigma_max = sigma_max
        self.rgb = rgb
        self.clip_input = clip_input
        self.images_already_noisy = images_already_noisy
        self.samples_per_image = samples_per_image
        self.seed = seed

        self.files = sorted(
            file_name
            for file_name in os.listdir(image_dir)
            if file_name.lower().endswith(IMG_EXTS)
        )
        if not self.files:
            raise RuntimeError(f"No calibration images found in {image_dir}")

        self.total_samples = len(self.files) * self.samples_per_image
        self.index = 0
        self.rng = np.random.default_rng(self.seed)

        print(f"Calibration images : {len(self.files)}")
        print(f"Samples per image  : {self.samples_per_image}")
        print(f"Calibration samples: {self.total_samples}")
        print(f"Input color order  : {'RGB' if self.rgb else 'BGR'}")
        print(f"Clip to [0, 1]     : {self.clip_input}")
        print(f"Already noisy      : {self.images_already_noisy}")
        if not self.images_already_noisy:
            print(f"Noise sigma range  : {self.sigma_min:g} - {self.sigma_max:g}")

    def _sigma_for_sample(self):
        if self.total_samples <= 1:
            return (self.sigma_min + self.sigma_max) / 2.0
        fraction = self.index / (self.total_samples - 1)
        return self.sigma_min + (self.sigma_max - self.sigma_min) * fraction

    def get_next(self):
        if self.index >= self.total_samples:
            return None

        file_index = self.index // self.samples_per_image
        file_name = self.files[file_index]
        path = os.path.join(self.image_dir, file_name)

        image = cv2.imread(path, cv2.IMREAD_COLOR)
        if image is None:
            raise RuntimeError(f"Failed to load image: {path}")

        image = cv2.resize(
            image,
            (self.width, self.height),
            interpolation=cv2.INTER_AREA,
        )
        if self.rgb:
            image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        image = image.astype(np.float32) / 255.0

        if self.images_already_noisy:
            sigma = None
            model_input = image
        else:
            sigma = self._sigma_for_sample()
            noise = self.rng.normal(
                0.0,
                sigma / 255.0,
                image.shape,
            ).astype(np.float32)
            model_input = image + noise

        # Match run_dncnn_camera.py, where add_demo_noise clips to uint8 range.
        if self.clip_input:
            model_input = np.clip(model_input, 0.0, 1.0)

        tensor = np.ascontiguousarray(
            model_input.transpose(2, 0, 1)[None, ...],
            dtype=np.float32,
        )

        detail = "pre-noised" if sigma is None else f"sigma={sigma:.1f}"
        print(
            f"[{self.index + 1:04d}/{self.total_samples:04d}] "
            f"{file_name} {detail}"
        )
        self.index += 1
        return {self.input_name: tensor}

    def rewind(self):
        self.index = 0
        self.rng = np.random.default_rng(self.seed)


def validate_args(args, input_shape):
    if not Path(args.input_model).is_file():
        raise FileNotFoundError(f"Input model not found: {args.input_model}")
    if not Path(args.calib_dir).is_dir():
        raise NotADirectoryError(f"Calibration directory not found: {args.calib_dir}")
    if Path(args.input_model).resolve() == Path(args.output_model).resolve():
        raise ValueError("--output_model must not overwrite --input_model")
    if args.sigma_min < 0 or args.sigma_max < args.sigma_min:
        raise ValueError("Require 0 <= sigma_min <= sigma_max")
    if args.samples_per_image < 1:
        raise ValueError("--samples_per_image must be at least 1")

    if len(input_shape) == 4:
        model_h, model_w = input_shape[2], input_shape[3]
        if model_h is not None and model_h != args.height:
            raise ValueError(
                f"Model height is {model_h}, but --height is {args.height}"
            )
        if model_w is not None and model_w != args.width:
            raise ValueError(
                f"Model width is {model_w}, but --width is {args.width}"
            )


def make_quant_config(args, node_names):
    config_name = {
        "xint8": "XINT8",
        "adaround": "XINT8_ADAROUND",
        "adaquant": "XINT8_ADAQUANT",
    }[args.method]

    print(f"Quark configuration: {config_name}")
    quant_config = get_default_config(config_name)
    quant_config.enable_npu_cnn = True

    if args.cle:
        quant_config.include_cle = True
        if quant_config.extra_options is None:
            quant_config.extra_options = {}
        quant_config.extra_options.setdefault("CLESteps", args.cle_steps)
        print(f"CLE enabled (steps={args.cle_steps})")

    excluded_nodes = list(args.exclude_node)
    if args.exclude_tail:
        missing = [name for name in DEFAULT_TAIL_NODES if name not in node_names]
        if missing:
            raise ValueError(
                "Tail node names do not match this ONNX model: " + ", ".join(missing)
            )
        excluded_nodes.extend(DEFAULT_TAIL_NODES)

    if excluded_nodes:
        # Preserve order while removing duplicates.
        excluded_nodes = list(dict.fromkeys(excluded_nodes))
        quant_config.nodes_to_exclude = excluded_nodes
        print("Excluded nodes:")
        for node_name in excluded_nodes:
            print(f"  {node_name}")

    return Config(global_quant_config=quant_config)


def parse_args():
    parser = argparse.ArgumentParser(
        description="Quantize color DnCNN for Ryzen AI XINT8 with matched calibration."
    )
    parser.add_argument("--input_model", required=True)
    parser.add_argument("--output_model", required=True)
    parser.add_argument(
        "--calib_dir",
        required=True,
        help="Directory of clean calibration images unless --images_already_noisy is used.",
    )
    parser.add_argument("--width", type=int, default=640)
    parser.add_argument("--height", type=int, default=360)
    parser.add_argument("--sigma_min", type=float, default=20.0)
    parser.add_argument("--sigma_max", type=float, default=20.0)
    parser.add_argument(
        "--samples_per_image",
        type=int,
        default=1,
        help="Generate multiple independently noised calibration samples per clean image.",
    )
    parser.add_argument("--seed", type=int, default=12345)
    parser.add_argument(
        "--bgr",
        action="store_true",
        help="Keep OpenCV BGR ordering. Do not use with the current camera script.",
    )
    parser.add_argument(
        "--no_clip",
        action="store_true",
        help="Do not clip calibration input to [0,1]. The camera-matched default is clipped.",
    )
    parser.add_argument(
        "--images_already_noisy",
        action="store_true",
        help="Do not add noise because calibration files are already noisy.",
    )
    parser.add_argument(
        "--method",
        choices=["xint8", "adaround", "adaquant"],
        default="xint8",
        help="Quark XINT8 configuration (default: xint8).",
    )
    parser.add_argument(
        "--cle",
        action="store_true",
        help="Enable Cross-Layer Equalization.",
    )
    parser.add_argument("--cle_steps", type=int, default=2)
    parser.add_argument(
        "--exclude_tail",
        action="store_true",
        help="Exclude the final RGB Conv and Sub from quantization (diagnostic/mixed precision).",
    )
    parser.add_argument(
        "--exclude_node",
        action="append",
        default=[],
        help="Additional exact ONNX node name to exclude; may be repeated.",
    )
    return parser.parse_args()


def main():
    args = parse_args()
    input_name, input_shape, node_names = get_input_info(args.input_model)
    validate_args(args, input_shape)

    reader = DnCNNCalibrationDataReader(
        args.calib_dir,
        input_name,
        width=args.width,
        height=args.height,
        sigma_min=args.sigma_min,
        sigma_max=args.sigma_max,
        rgb=not args.bgr,
        clip_input=not args.no_clip,
        images_already_noisy=args.images_already_noisy,
        samples_per_image=args.samples_per_image,
        seed=args.seed,
    )
    config = make_quant_config(args, node_names)

    output_path = Path(args.output_model)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    print("Start quantization...")
    quantizer = ModelQuantizer(config)
    quantizer.quantize_model(
        args.input_model,
        args.output_model,
        reader,
    )

    print("\nQuantization completed.")
    print(f"Output: {args.output_model}")


if __name__ == "__main__":
    main()
