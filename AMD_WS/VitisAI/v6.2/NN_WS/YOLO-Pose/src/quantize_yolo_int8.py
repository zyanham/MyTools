#!/usr/bin/env python3

import argparse
import os
import re
from pathlib import Path
from typing import Iterator, List, Tuple

import cv2
import numpy as np
import onnx
from onnxruntime.quantization import CalibrationDataReader


def get_model_input_name(model_path: str) -> str:
    model = onnx.load(model_path)
    return model.graph.input[0].name


def list_images(path: Path) -> List[Path]:
    if path.is_file():
        return [path]
    suffixes = {".jpg", ".jpeg", ".png", ".bmp"}
    return sorted(p for p in path.rglob("*") if p.is_file() and p.suffix.lower() in suffixes)


def letterbox(image: np.ndarray, size: int) -> np.ndarray:
    height, width = image.shape[:2]
    scale = min(size / width, size / height)
    resized_w, resized_h = int(round(width * scale)), int(round(height * scale))
    resized = cv2.resize(image, (resized_w, resized_h), interpolation=cv2.INTER_LINEAR)
    pad_w, pad_h = size - resized_w, size - resized_h
    left, top = pad_w // 2, pad_h // 2
    right, bottom = pad_w - left, pad_h - top
    return cv2.copyMakeBorder(
        resized,
        top,
        bottom,
        left,
        right,
        cv2.BORDER_CONSTANT,
        value=(114, 114, 114),
    )


def preprocess_image(path: Path, size: int) -> np.ndarray:
    image = cv2.imread(str(path), cv2.IMREAD_COLOR)
    if image is None:
        raise ValueError(f"Failed to read calibration image: {path}")
    image = letterbox(image, size)
    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    image = image.astype(np.float32) / 255.0
    image = np.transpose(image, (2, 0, 1))[None, :, :, :]
    return image


class ImageDataReader(CalibrationDataReader):
    def __init__(self, image_dir: str, input_name: str, image_size: int, limit: int):
        self.input_name = input_name
        images = list_images(Path(image_dir))
        if limit > 0:
            images = images[:limit]
        if not images:
            raise FileNotFoundError(f"No calibration images found under: {image_dir}")
        self.data_list = [preprocess_image(path, image_size) for path in images]
        self._iterator: Iterator[dict] | None = None
        print(f"Calibration images: {len(self.data_list)} from {image_dir}")

    def get_next(self):
        if self._iterator is None:
            self._iterator = iter([{self.input_name: data} for data in self.data_list])
        return next(self._iterator, None)

    def rewind(self):
        self._iterator = None


def parse_excluded_subgraphs(spec: str) -> List[Tuple[List[str], List[str]]]:
    if not spec.strip():
        return []
    result = []
    for item in spec.split(";"):
        matches = re.findall(r"\[(.*?)\]", item)
        if len(matches) != 2:
            raise ValueError(f"Invalid exclude subgraph spec: {item}")
        start_nodes = [node.strip() for node in matches[0].split(",") if node.strip()]
        end_nodes = [node.strip() for node in matches[1].split(",") if node.strip()]
        result.append((start_nodes, end_nodes))
    return result


def main() -> None:
    parser = argparse.ArgumentParser(description="Quantize YOLO-Pose ONNX model to Quark VINT8 for VEK385 NPU.")
    parser.add_argument("--model", required=True, help="Input FP32 ONNX model.")
    parser.add_argument("--output", required=True, help="Output VINT8 ONNX model.")
    parser.add_argument("--calib_dir", default="calib_data", help="Calibration image directory.")
    parser.add_argument("--img_size", type=int, default=640)
    parser.add_argument("--calib_limit", type=int, default=0, help="Maximum calibration images; 0 means all.")
    parser.add_argument(
        "--exclude_subgraphs",
        default="",
        help="Semicolon separated [start_nodes]:[end_nodes] specs. Empty string disables excludes.",
    )
    args = parser.parse_args()

    if not os.path.exists(args.model):
        raise FileNotFoundError(f"Model not found: {args.model}")

    from quark.onnx import ModelQuantizer
    from quark.onnx.quantization.config import Config, get_default_config

    input_name = get_model_input_name(args.model)
    calibration_reader = ImageDataReader(args.calib_dir, input_name, args.img_size, args.calib_limit)

    quant_config = get_default_config("VINT8")
    quant_config.extra_options["Int32Bias"] = False
    quant_config.extra_options["DedicatedQDQPair"] = True
    quant_config.extra_options["QuantizeAllOpTypes"] = True
    quant_config.enable_npu_cnn = True
    excluded = parse_excluded_subgraphs(args.exclude_subgraphs)
    if excluded:
        quant_config.subgraphs_to_exclude = excluded
        print(f"Excluded subgraphs: {excluded}")

    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)

    print(f"Input model:  {os.path.abspath(args.model)}")
    print(f"Output model: {output.resolve()}")
    quantizer = ModelQuantizer(Config(global_quant_config=quant_config))
    quantizer.quantize_model(args.model, str(output), calibration_data_reader=calibration_reader)
    print(f"Quark VINT8 model written: {output}")


if __name__ == "__main__":
    main()
