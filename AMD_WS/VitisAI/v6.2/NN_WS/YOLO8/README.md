# YOLO8 s/m for Vitis AI v6.2 / VEK385

This workspace ports Ultralytics YOLO8 detection models to AMD Vitis AI v6.2 for
Versal AI Edge Gen2 VEK385. It follows the local `SETUP_POLICY.md` layout:

- `src/`: Python source
- `models/`: exported ONNX models
- `original/`: notes and references for upstream/original implementations
- `results/`: host/NPU inference outputs

The workspace supports:

- YOLO8s: `yolov8s.onnx`
- YOLO8m: `yolov8m.onnx`

The YOLO8m flow references the official AMD Vitis-AI v6.2 tutorial under:

```text
Vitis-AI/versal_2ve/examples/tutorials/yolov8m
```

Quantization is intentionally not included yet. This workspace exports FP32 ONNX
and compiles it for BF16 device execution.

## Setup Outside Docker

Use this on WSL2 or native Ubuntu when preparing/exporting models:

```bash
cd VAI_v6.2/NN_WS/YOLO8
bash 01_setup.bash
```

`01_setup.bash` uses `pyenv` when available and otherwise falls back to
`python3 -m venv venv`.

On Ubuntu 24.04 without pyenv, make sure the system venv package exists:

```bash
sudo apt-get update
sudo apt-get install -y python3.12-venv
```

The setup script installs CPU-only Torch first, then installs Ultralytics. This
keeps export reproducible on ordinary WSL2/native Ubuntu hosts without pulling
large CUDA wheels that are not needed for ONNX export.

Default pinned host versions:

- Python: `3.12.3`
- Torch CPU: `2.12.1+cpu`
- Torchvision CPU: `0.27.1+cpu`
- Ultralytics: `8.4.75`
- ONNX Runtime CPU: `1.27.0`

The export and host CPU scripts call `venv/bin/python` by default so they do
not depend on the caller's currently activated shell environment. Override with
`PYTHON_BIN=/path/to/python` only when intentionally using another Python.

## Export ONNX

```bash
bash 02_export.bash s
bash 02_export.bash m
```

Or export both:

```bash
bash 02_export.bash all
```

Outputs:

- `models/yolov8s.onnx`
- `models/yolov8m.onnx`

## Compile In Vitis AI Docker

Inside the Vitis AI v6.2 Docker container:

```bash
cd /workspace
bash 03_compile.bash s
bash 03_compile.bash m
```

`03_compile.bash` uses `python3` from the Vitis AI runtime by default because
that environment provides `VitisAIExecutionProvider`.

Default cache directory:

```text
my_cache_dir/
```

Cache keys:

- `yolov8s_fp32_bf16`
- `yolov8m_fp32_bf16`

## Host CPU File2File

Default input is `../Dataset/Pixabay`.

Directory input:

```bash
VARIANT=s bash 04_run_host.bash ../Dataset/Pixabay results/host_yolov8s
VARIANT=m bash 04_run_host.bash ../Dataset/Pixabay results/host_yolov8m
```

Single-image input:

```bash
VARIANT=s bash 04_run_host.bash ../Dataset/Pixabay/example.jpg results/host_one_s
```

## VEK385 / NPU File2File

After compile:

```bash
VARIANT=s bash 05_run_npu.bash ../Dataset/Pixabay results/npu_yolov8s
VARIANT=m bash 05_run_npu.bash ../Dataset/Pixabay results/npu_yolov8m
```

`05_run_npu.bash` also defaults to the target-side `python3` for the same
reason.

The script also accepts a single image path as its first argument.

## Verified Smoke Results

Validated on WSL2 `Ubuntu-24.04-Codex` plus Docker Desktop using
`amdih/vitis-ai:versal-2ve-release_v6.2_0612`.

- Exported `models/yolov8s.onnx` and `models/yolov8m.onnx`
- Host CPU File2File passed on `../Dataset/Pixabay` with 5 car images
- Docker VitisAIExecutionProvider File2File smoke passed on the same 5 images
- YOLO8s compile summary: 233/233 operators, 30.518 GOPs, 1 VAIML subgraph
- YOLO8m compile summary: 299/299 operators, 82.299 GOPs, 1 VAIML subgraph

The Docker smoke confirms the Vitis AI execution path and compiled cache usage
on the host PC. Final hardware validation still needs to be run on VEK385.

## Dataset

The shared local test data is expected at:

```text
VAI_v6.2/NN_WS/Dataset/
```

For YOLO8 detection, `Dataset/Pixabay` is the default smoke-test directory.

## Clean For Git

Dry-run:

```bash
bash clean.bash --dry-run
```

Clean generated ONNX/PT files, caches, outputs, `venv`, and Python caches:

```bash
bash clean.bash
```

After cleaning, this directory keeps only the files required to rebuild from
scripts.
