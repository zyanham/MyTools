r"""Quantize Ultralytics YOLO11 Pose ONNX to Ryzen AI XINT8 with AMD Quark.

This script is tailored to the inspected yolo11n-pose.onnx graph exported by
Ultralytics 8.4.129 (opset 18, input 1x3x640x640, output 1x56x8400).

By default, numerically sensitive bbox, class-confidence, and pose-keypoint
decode paths are excluded from XINT8 quantization. The backbone, neck, and raw
prediction heads remain quantized.

Baseline command:

    python quantize_yolo11_pose_quark.py ^
      --input_model yolo11n-pose.onnx ^
      --calib_dir calib_images ^
      --output_model yolo11n-pose_XINT8.onnx

Accuracy-improvement variants:

    python quantize_yolo11_pose_quark.py ... --cle
    python quantize_yolo11_pose_quark.py ... --method adaround
    python quantize_yolo11_pose_quark.py ... --method adaquant

Comparison model with the complete graph quantized:

    python quantize_yolo11_pose_quark.py ... --quantize_postprocess
"""

import argparse
import copy
import os
from pathlib import Path

import cv2
import numpy as np
import onnx
from onnxruntime.quantization import CalibrationDataReader
from quark.onnx import ModelQuantizer
from quark.onnx.quantization.config.config import Config
from quark.onnx.quantization.config.custom_config import get_default_config


IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}

# These names were verified in the user's current yolo11n-pose.onnx.
POSE_POSTPROCESS_START_NODES = [
    "/model.23/Concat_3",  # decoded bbox branch
    "/model.23/Sigmoid",   # class-confidence branch
    "/model.23/Reshape_9", # keypoint decode branch
]
POSE_POSTPROCESS_END_NODES = [
    "/model.23/Concat_5",  # final [1, 56, 8400] output
]


def letterbox(image, new_shape=(640, 640), color=(114, 114, 114)):
    """Match the preprocessing used by run_yolo11_pose_image.py."""
    height, width = image.shape[:2]
    new_height, new_width = new_shape

    ratio = min(new_height / height, new_width / width)
    resized_width = int(round(width * ratio))
    resized_height = int(round(height * ratio))

    pad_width = new_width - resized_width
    pad_height = new_height - resized_height
    half_pad_width = pad_width / 2
    half_pad_height = pad_height / 2

    resized = cv2.resize(
        image,
        (resized_width, resized_height),
        interpolation=cv2.INTER_LINEAR,
    )

    top = int(round(half_pad_height - 0.1))
    bottom = int(round(half_pad_height + 0.1))
    left = int(round(half_pad_width - 0.1))
    right = int(round(half_pad_width + 0.1))

    return cv2.copyMakeBorder(
        resized,
        top,
        bottom,
        left,
        right,
        cv2.BORDER_CONSTANT,
        value=color,
    )


def inspect_model(model_path):
    model = onnx.load(model_path)
    onnx.checker.check_model(model)

    if len(model.graph.input) != 1:
        raise ValueError(f"Expected one model input, found {len(model.graph.input)}")

    model_input = model.graph.input[0]
    input_shape = []
    for dim in model_input.type.tensor_type.shape.dim:
        input_shape.append(dim.dim_value if dim.dim_value else None)

    output_shapes = []
    for output in model.graph.output:
        shape = []
        for dim in output.type.tensor_type.shape.dim:
            shape.append(dim.dim_value if dim.dim_value else None)
        output_shapes.append((output.name, shape))

    opsets = [(item.domain, item.version) for item in model.opset_import]
    node_names = {node.name for node in model.graph.node}

    print("ONNX check       : OK")
    print(f"Opsets           : {opsets}")
    print(f"Input            : {model_input.name} {input_shape}")
    print(f"Outputs          : {output_shapes}")
    print(f"Node count       : {len(model.graph.node)}")

    if len(input_shape) != 4:
        raise ValueError(f"Expected NCHW rank-4 input, found {input_shape}")

    channels, height, width = input_shape[1], input_shape[2], input_shape[3]
    if channels != 3 or not height or not width:
        raise ValueError(
            "This script requires a static [1,3,H,W] image input; "
            f"found {input_shape}"
        )

    if output_shapes != [("output0", [1, 56, 8400])]:
        print(
            "WARNING: This differs from the inspected YOLO11n-Pose output "
            "shape [1,56,8400]. Verify post-processing before deployment."
        )

    return model_input.name, int(width), int(height), node_names


def find_images(directory, recursive=False):
    root = Path(directory)
    iterator = root.rglob("*") if recursive else root.iterdir()
    return sorted(
        path
        for path in iterator
        if path.is_file() and path.suffix.lower() in IMAGE_EXTENSIONS
    )


class PoseCalibrationDataReader(CalibrationDataReader):
    def __init__(
        self,
        image_dir,
        input_name,
        width,
        height,
        recursive=False,
        max_samples=0,
    ):
        self.input_name = input_name
        self.width = width
        self.height = height
        self.files = find_images(image_dir, recursive=recursive)
        if max_samples > 0:
            self.files = self.files[:max_samples]
        if not self.files:
            raise RuntimeError(f"No calibration images found in: {image_dir}")

        self.index = 0
        print(f"Calibration images: {len(self.files)}")
        print(f"Preprocessing     : letterbox {width}x{height}, BGR->RGB, /255")

    def get_next(self):
        if self.index >= len(self.files):
            return None

        path = self.files[self.index]
        image = cv2.imread(str(path), cv2.IMREAD_COLOR)
        if image is None:
            raise RuntimeError(f"Failed to read calibration image: {path}")

        image = letterbox(image, (self.height, self.width))
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        tensor = image.astype(np.float32) / 255.0
        tensor = np.transpose(tensor, (2, 0, 1))[None, ...]
        tensor = np.ascontiguousarray(tensor, dtype=np.float32)

        self.index += 1
        print(f"[{self.index:04d}/{len(self.files):04d}] {path.name}")
        return {self.input_name: tensor}

    def rewind(self):
        self.index = 0

    def __len__(self):
        return len(self.files)


def make_fast_finetune_options(args, data_size):
    if args.method == "adaround":
        learning_rate = args.learning_rate if args.learning_rate is not None else 0.1
        num_iterations = args.num_iters if args.num_iters is not None else 3000
        algorithm = "adaround"
    elif args.method == "adaquant":
        learning_rate = args.learning_rate if args.learning_rate is not None else 0.00001
        num_iterations = args.num_iters if args.num_iters is not None else 10000
        algorithm = "adaquant"
    else:
        return None

    return {
        "DataSize": min(args.fast_ft_data_size, data_size),
        "FixedSeed": args.seed,
        "BatchSize": min(args.fast_ft_batch_size, data_size),
        "NumIterations": num_iterations,
        "LearningRate": learning_rate,
        "OptimAlgorithm": algorithm,
        "OptimDevice": "cpu",
        "InferDevice": "cpu",
        "EarlyStop": True,
    }


def validate_exclusion_nodes(node_names):
    required = POSE_POSTPROCESS_START_NODES + POSE_POSTPROCESS_END_NODES
    missing = [name for name in required if name not in node_names]
    if missing:
        raise ValueError(
            "The ONNX graph does not match the inspected YOLO11-Pose export. "
            "Missing exclusion nodes: " + ", ".join(missing)
        )


def build_quantization_config(args, node_names, calibration_count):
    quant_config = copy.deepcopy(get_default_config("XINT8"))
    quant_config.enable_npu_cnn = True
    quant_config.use_external_data_format = args.save_as_external_data

    if quant_config.extra_options is None:
        quant_config.extra_options = {}
    quant_config.extra_options["BF16QDQToCast"] = True

    if not args.quantize_postprocess:
        validate_exclusion_nodes(node_names)
        quant_config.subgraphs_to_exclude = [
            (
                list(POSE_POSTPROCESS_START_NODES),
                list(POSE_POSTPROCESS_END_NODES),
            )
        ]
        print("Pose post-processing exclusion: ENABLED")
        print(f"  start nodes: {POSE_POSTPROCESS_START_NODES}")
        print(f"  end nodes  : {POSE_POSTPROCESS_END_NODES}")
    else:
        print("Pose post-processing exclusion: DISABLED (comparison mode)")

    if args.exclude_node:
        missing = [name for name in args.exclude_node if name not in node_names]
        if missing:
            raise ValueError("Unknown --exclude_node values: " + ", ".join(missing))
        quant_config.nodes_to_exclude = list(dict.fromkeys(args.exclude_node))
        print(f"Additional excluded nodes: {quant_config.nodes_to_exclude}")

    if args.cle:
        quant_config.include_cle = True
        quant_config.extra_options["CLESteps"] = args.cle_steps
        print(f"CLE: ENABLED (steps={args.cle_steps})")

    fast_finetune = make_fast_finetune_options(args, calibration_count)
    if fast_finetune is not None:
        quant_config.include_fast_ft = True
        quant_config.extra_options["FastFinetune"] = fast_finetune
        print(f"Fast fine-tuning: {args.method.upper()}")
        print(f"Fast fine-tuning options: {fast_finetune}")
    else:
        print("Fast fine-tuning: disabled")

    return Config(global_quant_config=quant_config)


def parse_args():
    parser = argparse.ArgumentParser(
        description="Quantize YOLO11n-Pose ONNX to Ryzen AI XINT8 using AMD Quark."
    )
    parser.add_argument("--input_model", required=True, help="FP32 YOLO11-Pose ONNX")
    parser.add_argument("--calib_dir", required=True, help="Calibration image directory")
    parser.add_argument("--output_model", required=True, help="Output XINT8 ONNX")
    parser.add_argument(
        "--method",
        choices=["baseline", "adaround", "adaquant"],
        default="baseline",
    )
    parser.add_argument("--cle", action="store_true")
    parser.add_argument("--cle_steps", type=int, default=2)
    parser.add_argument("--learning_rate", type=float, default=None)
    parser.add_argument("--num_iters", type=int, default=None)
    parser.add_argument("--fast_ft_data_size", type=int, default=1000)
    parser.add_argument("--fast_ft_batch_size", type=int, default=2)
    parser.add_argument("--seed", type=int, default=1705472343)
    parser.add_argument("--recursive", action="store_true")
    parser.add_argument(
        "--max_samples",
        type=int,
        default=0,
        help="Maximum calibration images; 0 uses all images.",
    )
    parser.add_argument(
        "--quantize_postprocess",
        action="store_true",
        help="Quantize the complete decode graph (comparison; may reduce pose accuracy).",
    )
    parser.add_argument(
        "--exclude_node",
        action="append",
        default=[],
        help="Additional exact ONNX node to exclude; may be repeated.",
    )
    parser.add_argument("--save_as_external_data", action="store_true")
    return parser.parse_args()


def main():
    args = parse_args()
    input_path = Path(args.input_model)
    output_path = Path(args.output_model)
    calibration_path = Path(args.calib_dir)

    if not input_path.is_file():
        raise FileNotFoundError(f"Input model not found: {input_path}")
    if not calibration_path.is_dir():
        raise NotADirectoryError(f"Calibration directory not found: {calibration_path}")
    if input_path.resolve() == output_path.resolve():
        raise ValueError("--output_model must not overwrite --input_model")
    if args.fast_ft_batch_size < 1 or args.fast_ft_data_size < 1:
        raise ValueError("Fast fine-tuning batch/data sizes must be positive")

    input_name, width, height, node_names = inspect_model(str(input_path))
    reader = PoseCalibrationDataReader(
        calibration_path,
        input_name,
        width,
        height,
        recursive=args.recursive,
        max_samples=args.max_samples,
    )
    config = build_quantization_config(args, node_names, len(reader))

    output_path.parent.mkdir(parents=True, exist_ok=True)
    print("Start XINT8 quantization...")
    quantizer = ModelQuantizer(config)
    quantizer.quantize_model(str(input_path), str(output_path), reader)

    print("\nQuantization completed.")
    print(f"Output: {output_path}")


if __name__ == "__main__":
    main()
