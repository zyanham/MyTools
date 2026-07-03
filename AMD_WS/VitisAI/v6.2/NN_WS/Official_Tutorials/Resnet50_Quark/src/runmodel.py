#Copyright (C) 2026, Advanced Micro Devices, Inc. All rights reserved.
#SPDX-License-Identifier: MIT

import numpy as np
import onnxruntime as ort
import os
import time

onnx_model_vint8 ='models/resnet50-v1-12_quantized.onnx'

provider_options_dict = {
    "config_file": 'vitisai_config.json',
    "cache_dir":   './',
    "cache_key":   'resnet50-v1-12_quantized',
    "log_level":   'info',
        "target": "VAIML"
}

if os.environ.get("AI_ANALYZER", "0") == "1":
    provider_options_dict["ai_analyzer_visualization"] = True
    provider_options_dict["ai_analyzer_profiling"] = True

# NPU session
npu_session = ort.InferenceSession(
    onnx_model_vint8,
    providers=["VitisAIExecutionProvider"],
    provider_options=[provider_options_dict]
)

input_folder="input"
output_folder="output_vek385"
files = sorted([f for f in os.listdir(input_folder) if f.endswith(".npy")])
input_name = npu_session.get_inputs()[0].name
total_npu_time_s = 0.0
for i,f in enumerate(files):
    fp = os.path.join(input_folder, f)
    image = np.load(fp)
    start_time = time.time()
    outputs = npu_session.run(None, {input_name:image})
    end_time = time.time()
    total_npu_time_s += end_time - start_time
    # Create outpu directory if it doesn't exist
    os.makedirs(output_folder, exist_ok=True)
    for idx, out in enumerate(outputs):
        np.save(f"{output_folder}/output_{i}_{idx}.npy", out)
if files:
    avg_time_s = total_npu_time_s / len(files)
    print(f"[PERF] npu_avg_latency_ms={avg_time_s * 1000:.3f}")
    print(f"[PERF] npu_fps={1.0 / avg_time_s:.3f}")
print("Inference done")
