# YOLO-Pose for Vitis AI v6.2 / VEK385

This workspace ports the Ultralytics YOLOv8s pose model to AMD Vitis AI v6.2
for Versal AI Edge Gen2 VEK385. It follows the local `SETUP_POLICY.md` layout:

- `src/`: Python source
- `models/`: downloaded PyTorch weights and exported ONNX model
- `original/`: notes and references for upstream/original implementations
- `results/`: host/NPU pose outputs

The default model is:

```text
yolov8s-pose.pt -> models/yolo_pose.onnx
```

Quantization is intentionally not included yet. This workspace exports FP32 ONNX
and compiles it for BF16 device execution.

## Model Source

- Upstream: `https://github.com/ultralytics/ultralytics`
- Model: `yolov8s-pose.pt`
- Task: COCO person pose, 17 keypoints
- Input shape: `1 x 3 x 640 x 640`
- Output: YOLO pose predictions containing box, confidence, and keypoints

## Setup Outside Docker

Use this on WSL2 or native Ubuntu when preparing/exporting the model and running
Host CPU checks:

```bash
cd VAI_v6.2/NN_WS/YOLO-Pose
bash 01_setup.bash
```

On Ubuntu 24.04 without pyenv, make sure the system venv package exists:

```bash
sudo apt-get update
sudo apt-get install -y python3.12-venv
```

`01_setup.bash` uses `pyenv` when available and otherwise falls back to
`python3 -m venv venv`. Host scripts call `venv/bin/python` by default so they
do not depend on the caller's currently activated shell environment.

The setup script installs CPU-only Torch first, then installs Ultralytics. This
keeps export reproducible on ordinary WSL2/native Ubuntu hosts without pulling
large CUDA wheels that are not needed for ONNX export.

Default pinned host versions:

- Python: `3.12.3`
- Torch CPU: `2.12.1+cpu`
- Torchvision CPU: `0.27.1+cpu`
- Ultralytics: `8.4.75`
- ONNX Runtime CPU: `1.27.0`

## Export ONNX

```bash
bash 02_export.bash
```

Outputs:

- `models/yolov8s-pose.pt`
- `models/yolov8s-pose.onnx`
- `models/yolo_pose.onnx`

## Compile In Vitis AI Docker

Inside the Vitis AI v6.2 Docker container:

```bash
cd /nn_ws/YOLO-Pose
bash 03_compile.bash
```

Default cache directory:

```text
my_cache_dir/
```

Cache key:

```text
yolo_pose_fp32_bf16
```

`03_compile.bash` uses `python3` from the Vitis AI runtime by default because
that environment provides `VitisAIExecutionProvider`.

When launching the public Docker image directly, pass `--entrypoint /bin/bash`
so the requested command is executed after the image banner:

```bash
docker run --rm --entrypoint /bin/bash \
  -v /path/to/VAI_v6.2/NN_WS:/nn_ws \
  -w /nn_ws/YOLO-Pose \
  amdih/vitis-ai:versal-2ve-release_v6.2_0612 \
  -lc "bash 03_compile.bash"
```

## Host CPU File2File

Default input is `../Dataset/HumanFaces`.

Directory input:

```bash
bash 04_run_host.bash ../Dataset/HumanFaces results/host_yolo_pose
```

Single-image input:

```bash
bash 04_run_host.bash ../Dataset/HumanFaces/001.jpg results/host_one
```

Outputs:

- annotated `*_pose.jpg` / `*_pose.png`
- `poses.json`

## VEK385 / NPU File2File

After compile:

```bash
bash 05_run_npu.bash ../Dataset/HumanFaces results/npu_yolo_pose
```

The script also accepts a single image path as its first argument. It defaults
to target-side `python3` for the Vitis AI provider.

## Dataset

The shared local test data is expected at:

```text
VAI_v6.2/NN_WS/Dataset/
```

For YOLO-Pose, `Dataset/HumanFaces` is the default smoke-test directory because
it contains person/face images. Pose quality is not guaranteed for tightly
cropped faces, but the File2File pipeline and CPU/NPU comparison are exercised.

## Clean For Git

Dry-run:

```bash
bash clean.bash --dry-run
```

Clean generated ONNX/PT files, compiled caches, outputs, `venv`, and Python
caches:

```bash
bash clean.bash
```

After cleaning, this directory keeps only the files required to rebuild from
scripts.

## Verified Local Result

Verified on WSL2 Ubuntu 24.04 plus the Vitis AI v6.2 Docker image
`amdih/vitis-ai:versal-2ve-release_v6.2_0612`:

- `bash 01_setup.bash`: host venv created with pinned CPU dependencies
- `bash 02_export.bash`: exported `models/yolo_pose.onnx`
- `bash 04_run_host.bash ../Dataset/HumanFaces/matz01.jpg results/host_one_matz01`: 1 pose
- `bash 04_run_host.bash ../Dataset/HumanFaces results/host_humanfaces`: 502 input images, 514 total poses, 503 output files including `poses.json`
- `bash 03_compile.bash` in Docker: 267/267 operators, 32.1285 GOPs, 1 VAIML subgraph
- `bash 05_run_npu.bash ../Dataset/HumanFaces/matz01.jpg results/npu_one_matz01`: 1 pose
- `bash 05_run_npu.bash ../Dataset/HumanFaces results/npu_humanfaces`: 502 input images, 514 total poses, 503 output files including `poses.json`

Re-run the standard scripts after a clean checkout to regenerate current
artifacts under `models/`, `my_cache_dir/`, and `results/`.
