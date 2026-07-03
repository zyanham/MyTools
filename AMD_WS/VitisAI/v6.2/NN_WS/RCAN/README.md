# RCAN for Vitis AI v6.2 / VEK385

This workspace ports RCAN, "Image Super-Resolution Using Very Deep Residual
Channel Attention Networks", to AMD Vitis AI v6.2 for Versal AI Edge Gen2
VEK385. It follows the local `SETUP_POLICY.md` layout:

- `src/`: Python source
- `models/`: exported ONNX model and optional official `.pt` checkpoint
- `original/`: notes and fetched upstream metadata
- `results/`: host/NPU super-resolution outputs

## Model Source

- Paper: `https://arxiv.org/abs/1807.02758`
- Official repository: `https://github.com/yulunzhang/RCAN`
- Default target: BI degradation, x2 super-resolution
- Default checkpoint name: `RCAN_BIX2.pt`

The official repository separates `RCAN_TestCode` and `RCAN_TrainCode`. Its
README points to external pretrained model downloads; this workspace can try
the official Dropbox zip, but also supports manual checkpoint placement.

## NPU-Oriented Shape

RCAN is naturally image-size flexible, but Vitis AI compilation is more
predictable with fixed input shapes. The default target is:

- Input: `lr`, shape `1 x 3 x 128 x 128`, FP32 RGB in `0..255`
- Output: `sr`, shape `1 x 3 x 256 x 256`, FP32 RGB in `0..255`
- Cache key: `rcan_bix2_x2_128x128_fp32_bf16`

Input images from `Dataset/SR_IMG` are resized to this LR shape before
inference. The script writes:

- fixed LR image
- bicubic x2 reference
- RCAN x2 result
- raw `sr.npy`
- `super_resolution_manifest.json`

Quantization is intentionally not included yet. This workspace exports FP32
ONNX and compiles it for BF16 device execution.

## Setup Outside Docker

Use this on WSL2 or native Ubuntu when preparing/exporting the model and running
Host CPU checks:

```bash
cd VAI_v6.2/NN_WS/RCAN
bash 01_setup.bash
```

On Ubuntu 24.04 without pyenv:

```bash
sudo apt-get update
sudo apt-get install -y python3.12-venv
```

`01_setup.bash` uses `pyenv` when available and otherwise falls back to
`python3 -m venv venv`.

## Export ONNX

Recommended official-weight flow:

```bash
DOWNLOAD_WEIGHTS=1 bash 02_export.bash
```

If the external checkpoint download is unavailable, place the official file at:

```text
models/RCAN_BIX2.pt
```

Then run:

```bash
bash 02_export.bash
```

For compile-path testing only, a random-weight ONNX can be generated:

```bash
ALLOW_RANDOM_WEIGHTS=1 bash 02_export.bash
```

Default output:

```text
models/rcan_bix2_x2_128x128.onnx
```

Other scales/shapes can be tried with environment variables:

```bash
SCALE=4 HEIGHT=96 WIDTH=96 bash 02_export.bash
```

For faster compile smoke tests, x2 with `64 x 64` LR input is recommended:

```bash
HEIGHT=64 WIDTH=64 bash 02_export.bash
HEIGHT=64 WIDTH=64 bash 03_compile.bash
HEIGHT=64 WIDTH=64 bash 04_run_host.bash ../Dataset/SR_IMG/IMG10.jpg results/host_smoke64
```

## Compile In Vitis AI Docker

Inside the Vitis AI v6.2 Docker container:

```bash
cd /nn_ws/RCAN
bash 03_compile.bash
```

Default cache directory:

```text
my_cache_dir/
```

Default cache key:

```text
rcan_bix2_x2_128x128_fp32_bf16
```

RCAN is much deeper than the other CNN examples. The compile script disables AI
analyzer visualization/profiling by default to keep compile completion
practical. Enable it explicitly only when needed:

```bash
python3 src/compile.py ... --enable_ai_analyzer
```

## Host CPU File2File

Default input is `../Dataset/SR_IMG`.

Directory input:

```bash
bash 04_run_host.bash ../Dataset/SR_IMG results/host_rcan_bix2
```

Single-image input:

```bash
bash 04_run_host.bash ../Dataset/SR_IMG/IMG01.jpg results/host_one
```

## VEK385 / NPU File2File

After compile:

```bash
bash 05_run_npu.bash ../Dataset/SR_IMG results/npu_rcan_bix2
```

Strict NPU preflight:

```bash
unset XLNX_ENABLE_CACHE
STRICT_NPU=1 bash 05_run_npu.bash ../Dataset/SR_IMG results/npu_rcan_bix2
```

The NPU script includes the shared `[NPU-RUNTIME-CHECK]` logging. Check that the
log has `VitisAIExecutionProvider` in `session_providers`, a valid compiled
cache directory, and no deployment-only compile error.

## Dataset

The shared local test data is expected at:

```text
VAI_v6.2/NN_WS/Dataset/
```

For RCAN super-resolution, `Dataset/SR_IMG` is the default smoke-test directory.

## Porting Notes

Changes made from the official RCAN test flow:

- Removed training/test framework dependencies and kept a self-contained RCAN
  module in `src/rcan_model.py`.
- Kept the official RCAN topology: MeanShift, residual groups, RCAB channel
  attention, global average pooling, PixelShuffle upsampling.
- Fixed the ONNX input shape for Vitis AI compilation.
- Disabled `--chop` and self-ensemble paths for NPU export because they are
  inference-time tiling/control-flow features, not model graph features.
- File2File inference resizes arbitrary images to the fixed LR tensor and emits
  bicubic reference images for quick visual comparison.

## Clean For Git

Dry-run:

```bash
bash clean.bash --dry-run
```

Clean generated official checkout, downloaded weights, ONNX files, compiled
caches, outputs, `venv`, and Python caches:

```bash
bash clean.bash
```

After cleaning, this directory keeps only the files required to rebuild from
scripts.

## Current Status

The official `RCAN_BIX2.pt` checkpoint has been tested with the export and host
CPU flow. The full `128 x 128` LR compile produced strong cache evidence, but
the Docker process did not return within the first long timeout and was stopped
manually after the cache evidence below had been written:

- VAIML support: `2028/2028` operators
- GOPs supported by VAIML: `504.163/504.163`
- Subgraphs: `1`
- `fail_safe_summary.json`: `AIE=100`, `CPU=0`
- `partition-info.json`: `runner_type=hw`, `status=completed`

A Docker VitisAIExecutionProvider inference smoke using this cache reached the
shared `[NPU-RUNTIME-CHECK]` preflight and confirmed the same cache evidence,
but did not reach `session_providers` before the timeout. A `64 x 64` compile
attempt was also still running before preliminary summary generation and was
stopped; that incomplete cache was removed.

Current interpretation: RCAN is graph-compatible with VAIML/AIE, but the full
official network is much heavier for Vitis AI compile/session initialization
than the other CNN examples in this workspace. VEK385 hardware validation should
start from the completed `128 x 128` cache and capture the full target-side log
with the shared `[NPU-RUNTIME-CHECK]` logging.
