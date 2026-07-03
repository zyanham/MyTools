# Official Vitis AI Tutorials Wrapper

This directory contains local copies of the four AMD Vitis AI Versal 2VE tutorials, with thin wrapper scripts added for the NN_WS workflow.

## Layout

- `Resnet18_BF16`: official `resnet18_bf16`
- `Resnet50Cpp`: official `resnet50Cpp`
- `Resnet50_Quark`: official `resnet50_quark`
- `yolov8m`: official `yolov8m`
- `QuickStart`: VEK385-side wrappers for AMD's Vitis AI Gen2 Quick Start Guide

Each tutorial writes wrapper logs under its own `results/` directory. Compile logs are named `compile.log`; NPU logs are named `npu_run_*.log`; Quark logs are named `quark.log`.

Runtime wrapper scripts stay in each tutorial root. Tutorial source files are stored under each tutorial's `src/` directory.

## VEK385 QuickStart

After copying `Deploy` to the VEK385, run the QuickStart Guide wrappers from the Deploy root. These scripts use the pre-installed files under `/etc/vai` on the public Vitis AI SD image and write logs under `QuickStart/Results/`.

```bash
bash QuickStart/00_check_board_env.bash
bash QuickStart/01_verify_vart_resnet50_int8.bash
bash QuickStart/02_benchmark_vart_resnet50_int8.bash
bash QuickStart/03_python_onnxruntime_resnet50_int8.bash
bash QuickStart/04_classification_cpp_vart_resnet50_int8.bash
bash QuickStart/05_classification_python_resnet50_int8.bash
bash QuickStart/06_object_detection_cpp_vart_yolox_m_int8.bash
```

A batch wrapper is also available:

```bash
bash QuickStart/90_run_all_quickstart.bash
```

See `QuickStart/README.md` for details and override options.

## Run Order

Run from each tutorial directory.

### Resnet18_BF16

```bash
bash 01_setup.bash
bash 02_export.bash
bash 03_compile.bash
bash 05_run_npu.bash
bash 06_run_npu_ai_analyzer.bash
```

### Resnet50Cpp

```bash
bash 01_setup.bash
bash 03_compile.bash
bash 04_build_cpp_app.bash
bash 05_run_npu_python.bash
bash 06_run_npu_cpp.bash
bash 07_run_npu_ai_analyzer.bash
```

### Resnet50_Quark

```bash
bash 01_setup.bash
bash 02_quark.bash
bash 03_compile.bash
bash 05_run_npu.bash
bash 06_run_npu_ai_analyzer.bash
```

### yolov8m

```bash
bash 01_setup.bash
bash 02_export.bash
bash 03_quark.bash
bash 04_compile.bash
bash 05_run_npu.bash
bash 06_run_npu_ai_analyzer.bash
```

## Notes

- `PYTHON_BIN` can be set to override Python, for example `PYTHON_BIN=python bash 03_compile.bash`.
- `SKIP_PIP=1` skips package installation in setup wrappers.
- Analyzer wrappers set `AI_ANALYZER=1`. Tutorials that already enable Analyzer keep the official behavior.
- The wrappers report elapsed time as `[PERF] command_total_s=...` at the end of each log.
- `bash clean.bash` removes generated logs, caches, models, and temporary outputs for each tutorial. Use `bash clean.bash --dry-run` to preview.
