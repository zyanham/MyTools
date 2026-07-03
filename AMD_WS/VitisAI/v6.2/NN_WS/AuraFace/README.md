# AuraFace for Vitis AI v6.2 / VEK385

This workspace ports `fal/AuraFace-v1` face embeddings to AMD Vitis AI v6.2 for
Versal AI Edge Gen2 VEK385. It follows the local `SETUP_POLICY.md` layout:

- `src/`: Python source
- `models/`: downloaded/exported ONNX models
- `original/`: notes and references for the upstream model
- `results/`: host/NPU embedding outputs

The recognition model used here is:

```text
models/glintr100.onnx -> models/auraface.onnx
```

The AuraFace detector model is intentionally not part of this first NPU unit.
The default test input is the already face-centered local dataset:

```text
../Dataset/HumanFaces
```

## Model Source

- Repository: `https://huggingface.co/fal/AuraFace-v1`
- Recognition model: `glintr100.onnx`
- Input shape: `1 x 3 x 112 x 112`
- Output shape: `1 x 512` embedding

Quantization is intentionally not included yet. This workspace compiles the
FP32 ONNX model for BF16 device execution.

## Setup Outside Docker

Use this on WSL2 or native Ubuntu when preparing/downloading the model and
running Host CPU checks:

```bash
cd VAI_v6.2/NN_WS/AuraFace
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
- OpenCV headless: `4.13.0.92`
- NumPy: `2.4.4`
- ONNX: `1.22.0`
- ONNX Runtime CPU: `1.27.0`

## Export / Download ONNX

```bash
bash 02_export.bash
```

Outputs:

- `models/glintr100.onnx`
- `models/auraface.onnx`

## Compile In Vitis AI Docker

Inside the Vitis AI v6.2 Docker container:

```bash
cd /nn_ws/AuraFace
bash 03_compile.bash
```

Default cache directory:

```text
my_cache_dir/
```

Cache key:

```text
auraface_fp32_bf16
```

`03_compile.bash` uses `python3` from the Vitis AI runtime by default because
that environment provides `VitisAIExecutionProvider`.

## Host CPU File2File

Default input is `../Dataset/HumanFaces`.

Directory input:

```bash
bash 04_run_host.bash ../Dataset/HumanFaces results/host_auraface
```

Single-image input:

```bash
bash 04_run_host.bash ../Dataset/HumanFaces/001.jpg results/host_one
```

Outputs are one `.npy` embedding and one `.json` metadata file per input image,
plus `embeddings_manifest.json`.

## VEK385 / NPU File2File

After compile:

```bash
bash 05_run_npu.bash ../Dataset/HumanFaces results/npu_auraface
```

The script also accepts a single image path as its first argument. It defaults
to target-side `python3` for the Vitis AI provider.

## Face Search

Use `matz01.jpg` as a query face and rank images under `Dataset/HumanFaces` by
cosine similarity:

```bash
bash 06_search_host.bash ../Dataset/HumanFaces/matz01.jpg ../Dataset/HumanFaces results/search_host_matz01
```

Inside the Vitis AI Docker container or on VEK385 after compile:

```bash
bash 07_search_npu.bash ../Dataset/HumanFaces/matz01.jpg ../Dataset/HumanFaces results/search_npu_matz01
```

Default search settings:

- `THRESHOLD=0.30`
- `TOP_K=20`

Outputs:

- `search_results.csv`
- `search_results.json`
- `search_summary.txt`

The `matches_above_threshold` section is only a similarity-based report. It is
not a verified identity label.

Compare CPU and NPU search CSVs:

```bash
bash 08_compare_search.bash results/search_host_matz01/search_results.csv results/search_npu_matz01/search_results.csv results/search_compare_matz01
```

## Clean For Git

Dry-run:

```bash
bash clean.bash --dry-run
```

Clean generated ONNX/model files, compiled cache, outputs, `venv`, and Python
caches:

```bash
bash clean.bash
```

After cleaning, this directory keeps only the files required to rebuild from
scripts.

## Verified Smoke Results

Validated on WSL2 `Ubuntu-24.04-Codex` plus Docker Desktop using
`amdih/vitis-ai:versal-2ve-release_v6.2_0612`.

- `01_setup.bash` created the host `venv` and installed pinned dependencies
- `02_export.bash` prepared `models/glintr100.onnx` and `models/auraface.onnx`
- Host CPU File2File passed on `../Dataset/HumanFaces` with 500 images
- Host CPU single-image File2File passed on `../Dataset/HumanFaces/001.jpg`
- Docker VitisAIExecutionProvider File2File passed on the same 500-image directory
- Docker VitisAIExecutionProvider single-image File2File passed on `001.jpg`
- CPU and Docker VitisAIExecutionProvider face search passed with
  `matz01.jpg` as query against 501 gallery images
- Search top result: `matz02.jpg`, cosine similarity `0.311592`
- Search matches above `THRESHOLD=0.30`: `matz02.jpg`, `023.jpg`, `444.jpg`
- Output embedding shape: `1 x 512`
- Compile cache: `my_cache_dir/auraface_fp32_bf16`
- 204/255 operators supported by VAIML
- 24.401/24.446 GOPs supported by VAIML
- 99.816% GOPs supported by VAIML
- 50 VAIML subgraphs

The Docker smoke confirms the Vitis AI execution path and compiled cache usage
on the host PC. Final hardware validation still needs to be run on VEK385.
