# Carvana U-Net for Vitis AI v6.2 / VEK385

This workspace ports the Carvana car-segmentation example from
`yakhyo/unet-pytorch` to AMD Vitis AI v6.2 for Versal AI Edge Gen2 VEK385. It
follows the local `SETUP_POLICY.md` layout:

- `src/`: Python source
- `models/`: exported ONNX model
- `original/`: notes and references for the upstream implementation
- `results/`: host/NPU segmentation outputs

This is the real Carvana example, not the earlier dummy U-Net. It uses the
upstream U-Net architecture and upstream `weights/last.pt` checkpoint.

## Model Source

- Repository: `https://github.com/yakhyo/unet-pytorch`
- Task: Carvana car segmentation
- Weight used: `weights/last.pt`
- Upstream note: weights are stored in f16 and are converted to float32 before
  ONNX export.

## Model Interface

- Input: `image`, shape `1 x 3 x 640 x 959`, FP32
- Output: `logits`, shape `1 x 2 x 640 x 959`, FP32
- Preprocess:
  - resize input image to `959 x 640`
  - RGB
  - scale to `[0, 1]`
  - normalize with ImageNet mean/std
- Postprocess:
  - `argmax` over 2-class logits
  - class `0`: background
  - class `1`: car

Quantization is intentionally not included yet. This workspace exports FP32 ONNX
and compiles it for BF16 device execution.

## Setup Outside Docker

Use this on WSL2 or native Ubuntu when preparing/exporting the model and running
Host CPU checks:

```bash
cd VAI_v6.2/NN_WS/U-Net
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

Default pinned host versions:

- Python: `3.12.3`
- Torch CPU: `2.12.1+cpu`
- OpenCV headless: `4.13.0.92`
- NumPy: `2.4.4`
- ONNX: `1.22.0`
- ONNX Runtime CPU: `1.27.0`

## Export ONNX

```bash
bash 02_export.bash
```

`02_export.bash` fetches the official repository into `third_party/` and exports:

```text
models/carvana_unet.onnx
```

The export uses the Carvana example input size `959 x 640`, derived from the
upstream example image at `scale=0.5`.

## Compile In Vitis AI Docker

Inside the Vitis AI v6.2 Docker container:

```bash
cd /nn_ws/U-Net
bash 03_compile.bash
```

Default cache directory:

```text
my_cache_dir/
```

Cache key:

```text
carvana_unet_fp32_bf16
```

`03_compile.bash` uses `python3` from the Vitis AI runtime by default because
that environment provides `VitisAIExecutionProvider`.

## Host CPU File2File

Default input is `../Dataset/Web`.

Directory input:

```bash
bash 04_run_host.bash ../Dataset/Web results/host_carvana_unet
```

Single-image input:

```bash
bash 04_run_host.bash ../Dataset/Web/car01.png results/host_one
```

Outputs per input image:

- `*_logits.npy`
- `*_mask.png`
- `*_mask_color.png`
- `*_overlay.png`
- `segmentation_manifest.json`

## VEK385 / NPU File2File

After compile:

```bash
bash 05_run_npu.bash ../Dataset/Web results/npu_carvana_unet
```

The script also accepts a single image path as its first argument. It defaults
to target-side `python3` for the Vitis AI provider.

Run NPU jobs that share the same `CACHE_DIR` sequentially. Parallel runs can
make the Vitis AI HDF5 cache writer fight over `constants.h5`.

## Dataset

The shared local test data is expected at:

```text
VAI_v6.2/NN_WS/Dataset/
```

For Carvana U-Net, `Dataset/Web` is the default smoke-test directory.

## Clean For Git

Dry-run:

```bash
bash clean.bash --dry-run
```

Clean generated official checkout, ONNX/model files, compiled caches, outputs,
`venv`, and Python caches:

```bash
bash clean.bash
```

After cleaning, this directory keeps only the files required to rebuild from
scripts.

## Verified Smoke Results

Validated on WSL2 `Ubuntu-24.04-Codex` plus Docker Desktop using
`amdih/vitis-ai:versal-2ve-release_v6.2_0612`.

- `01_setup.bash` created the host `venv` and installed pinned dependencies
- `02_export.bash` exported `models/carvana_unet.onnx`
- Host CPU File2File passed on `../Dataset/Web` with `car01.png`
- Host CPU single-image File2File passed on `../Dataset/Web/car01.png`
- Docker VitisAIExecutionProvider File2File passed on the same directory
- Docker VitisAIExecutionProvider single-image File2File passed on `car01.png`
- Output logits shape: `2 x 640 x 959`
- Observed car pixel ratio on `car01.png`: `0.1959169708029197`
- Compile summary: 53/53 operators, 940.197 GOPs, 1 VAIML subgraph

The Docker smoke confirms the Vitis AI execution path and compiled cache usage
on the host PC. Final hardware validation still needs to be run on VEK385.
