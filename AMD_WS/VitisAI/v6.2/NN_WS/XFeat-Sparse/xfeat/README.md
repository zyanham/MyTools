# xFeat Model for Vitis AI v6.2 / VEK385

This workspace ports only the CNN tensor part of the official XFeat sparse
pipeline.

## Model Boundary

Original host behavior:

```text
image -> preprocess -> XFeatModel -> heatmap/NMS/top-k/interpolation -> sparse features
```

NPU model unit:

```text
image -> XFeatModel -> feats, keypoints, heatmap
```

The dynamic sparse extraction tail remains CPU post-processing. This keeps the
ONNX interface static and repeatable for Vitis AI compilation.

## Run

Generate reference vectors first:

```bash
cd ../original
bash 01_setup.bash
bash 03_run_host.bash
```

Then:

```bash
cd ../xfeat
bash 01_setup.bash
bash 02_export.bash
bash 04_run_host.bash
```

For the compile-verified ONNX, export with the Vitis AI Docker Python stack
(`torch 2.5.1+cpu`, `onnx 1.16.1`). Host PyTorch 2.12 can export a CPU-valid
ONNX, but that graph was observed to make the Vitis AI compile path extremely
slow.

```bash
cd /nn_ws/XFeat-Sparse/xfeat
PYTHON_BIN=python3 bash 02_export.bash
```

Inside the Vitis AI Docker container:

```bash
cd /nn_ws/XFeat-Sparse/xfeat
bash 03_compile.bash
bash 05_run_npu.bash
```

## Verified Local Result

Verified on WSL2 Ubuntu 24.04 plus
`amdih/vitis-ai:versal-2ve-release_v6.2_0612`:

- `../original/03_run_host.bash`: generated xFeat input/output vectors
- `02_export.bash` with Vitis AI Docker `python3`: exported `models/xfeat_model.onnx`
- `04_run_host.bash`: CPU npy check passed
  - `feats` max abs diff: `0.0030252933502197266`
  - `keypoints` max abs diff: `0.00299072265625`
  - `heatmap` max abs diff: `0.00029781460762023926`
- `03_compile.bash`: 344/344 VAIML operators, 2.66553 GOPs, 1 VAIML subgraph
- `05_run_npu.bash`: NPU npy check passed with the same max abs diffs
