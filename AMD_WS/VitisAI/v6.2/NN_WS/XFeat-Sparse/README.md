# XFeat-Sparse for Vitis AI v6.2 / VEK385

This directory is split into three smaller workspaces because the official
XFeat sparse matcher contains two neural network stages.

```text
XFeat-Sparse/
  original/      official CPU pipeline and captured npy vectors
  xfeat/         XFeatModel ONNX export, CPU check, Vitis AI compile, NPU check
  Lighter_Glue/  LighterGlue ONNX export, CPU check, Vitis AI compile, NPU check
```

The original host pipeline is not ported to NPU as one monolithic graph. It is
used to generate stable input/output `.npy` vectors, then each neural network
stage is tested independently.

## Order

First generate the official reference data:

```bash
cd original
bash 01_setup.bash
bash 03_run_host.bash
```

Then run xFeat:

```bash
cd ../xfeat
bash 01_setup.bash
bash 02_export.bash
bash 04_run_host.bash
```

Inside the Vitis AI v6.2 Docker container:

```bash
cd /nn_ws/XFeat-Sparse/xfeat
bash 03_compile.bash
bash 05_run_npu.bash
```

Then run Lighter_Glue:

```bash
cd ../Lighter_Glue
bash 01_setup.bash
bash 02_export.bash
bash 04_run_host.bash
```

Inside the Vitis AI v6.2 Docker container:

```bash
cd /nn_ws/XFeat-Sparse/Lighter_Glue
bash 03_compile.bash
bash 05_run_npu.bash
```

When launching the public Docker image directly, use `--entrypoint /bin/bash`
so the requested command runs after the image banner.

## Clean

Each sub-workspace has its own `clean.bash`. To clean everything:

```bash
bash clean.bash
```
