# Vitis AI Gen2 Quick Start for VEK385

These scripts wrap the VEK385-side commands from AMD's Vitis AI Gen2 Quick Start Guide:

https://vitisai.docs.amd.com/projects/gen2/en/latest/docs/getting_started/quick-start-guide.html

They use the pre-installed files under `/etc/vai` on the public Vitis AI SD image. They do not use the local Official Tutorial model directories.

## Logs

All wrapper logs and generated outputs are written under:

```bash
QuickStart/Results/
```

## Run Order

From the copied `Deploy` root on VEK385:

```bash
bash QuickStart/00_check_board_env.bash
bash QuickStart/01_verify_vart_resnet50_int8.bash
bash QuickStart/02_benchmark_vart_resnet50_int8.bash
bash QuickStart/03_python_onnxruntime_resnet50_int8.bash
bash QuickStart/04_classification_cpp_vart_resnet50_int8.bash
bash QuickStart/05_classification_python_resnet50_int8.bash
bash QuickStart/06_object_detection_cpp_vart_yolox_m_int8.bash
```

Or run the whole flow:

```bash
bash QuickStart/90_run_all_quickstart.bash
```

The inference scripts require root access, as noted by the AMD guide. If run as `amd-edf`, they re-execute themselves through `sudo -E`.

## Default Commands Wrapped

```bash
ml_vart --app-config /etc/vai/ml_vart/json_configs/ml_vart_config.json
ml_vart --app-config /etc/vai/ml_vart/json_configs/ml_vart_config.json --benchmark --runs 1000
python3 /etc/vai/python/run_ResNet50_vitisai.py
x_plus_ml_vart --app-config /etc/vai/x_plus_ml_vart/json_configs/x_plus_ml_vart_1model.json --input-file /etc/vai/models/resnet50_int8/data/classification.jpg --log-level 3
python3 /etc/vai/python/run_ResNet50_vitisai.py --postprocess --postprocess-top-k 5 --labels /etc/vai/models/resnet50_int8/data/imagenet-classes-1000.txt
x_plus_ml_vart --app-config /etc/vai/x_plus_ml_vart/json_configs/x_plus_ml_vart_od.json --input-file /etc/vai/models/yolox_m_int8/data/detections.jpg --log-level 3
```

Useful overrides:

```bash
RUNS=100 bash QuickStart/02_benchmark_vart_resnet50_int8.bash
RESULTS_DIR=/tmp/quickstart_results bash QuickStart/90_run_all_quickstart.bash
```

