# Lighter_Glue Model for Vitis AI v6.2 / VEK385

This workspace ports the fixed tensor LighterGlue matcher stage extracted from
the official XFeat sparse pipeline.

## Model Boundary

Original host behavior:

```text
keypoints/descriptors -> LighterGlue transformer -> log_assignment -> filter_matches -> variable-length matches
```

NPU model unit:

```text
keypoints0, keypoints1, descriptors0, descriptors1, image_size0, image_size1
  -> LighterGlue transformer + assignment
  -> log_assignment
```

The final match filtering and variable-length match tensors remain CPU
post-processing. The exported model uses fixed `top_k=128` tensors captured by
`../original`.

## Export Wrapper Changes

The wrapper in `src/export_lighterglue_onnx.py` keeps the official learned
weights but makes the traced graph more static:

- disables width pruning
- disables depth early stopping
- disables flash attention
- uses fixed `top_k=128` inputs
- replaces exporter-sensitive tensor operations with fixed-shape reshape,
  permute, and explicit softmax/log-softmax math
- exports `log_assignment` only

## Run

Generate reference vectors first:

```bash
cd ../original
bash 01_setup.bash
bash 03_run_host.bash
```

Then:

```bash
cd ../Lighter_Glue
bash 01_setup.bash
bash 02_export.bash
bash 04_run_host.bash
```

Inside the Vitis AI Docker container, use an unlimited stack:

```bash
cd /nn_ws/XFeat-Sparse/Lighter_Glue
bash 03_compile.bash
bash 05_run_npu.bash
```

Docker launch example:

```bash
docker run --rm --entrypoint /bin/bash --ulimit stack=-1:-1 \
  -v /path/to/VAI_v6.2/NN_WS:/nn_ws \
  -w /nn_ws/XFeat-Sparse/Lighter_Glue \
  amdih/vitis-ai:versal-2ve-release_v6.2_0612 \
  -lc "bash 03_compile.bash && bash 05_run_npu.bash"
```

## Verified Local Result

Verified on WSL2 Ubuntu 24.04 plus
`amdih/vitis-ai:versal-2ve-release_v6.2_0612`:

- `../original/03_run_host.bash`: generated fixed `top_k=128` LighterGlue vectors
- `02_export.bash`: exported `models/lighterglue_model.onnx`
- `04_run_host.bash`: CPU `log_assignment` npy check passed
  - max abs diff: `0.020267486572265625`
- `03_compile.bash`: 1173/1173 VAIML operators, 0.743749 GOPs, 1 VAIML subgraph
- `05_run_npu.bash`: NPU `log_assignment` npy check passed
  - max abs diff: `0.017757415771484375`
