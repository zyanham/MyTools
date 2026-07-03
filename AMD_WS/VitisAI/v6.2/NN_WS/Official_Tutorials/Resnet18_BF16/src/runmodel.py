#Copyright (C) 2026, Advanced Micro Devices, Inc. All rights reserved.
#SPDX-License-Identifier: MIT

import os
import sys
import time

import numpy as np
import onnxruntime as ort

provider_options_dict = {
    "config_file": 'vitisai_config.json',
    "cache_dir":   'my_cache_dir',
    "cache_key":   'resnet18.a1_in1k',
    "log_level":   'info',
	"target": 'VAIML'
}

if os.environ.get("AI_ANALYZER", "0") == "1":
    provider_options_dict["ai_analyzer_visualization"] = True
    provider_options_dict["ai_analyzer_profiling"] = True

print(f"Creating ORT inference session for model models/resnet18.a1_in1k.onnx")

onnx_model="models/resnet18.a1_in1k.onnx"
# CPU session to compute reference values
cpu_session = ort.InferenceSession(
    onnx_model,
) 
# NPU session
npu_session = ort.InferenceSession(
    onnx_model,
    providers=["VitisAIExecutionProvider"],
    provider_options=[provider_options_dict]
) 

num_iter = 4
total_npu_time_s = 0.0
print(f"Running {num_iter} inferences, comparing CPU and NPU outputs")
for i in range(num_iter):
    # Generate random data
    input_data = {}
    for input in npu_session.get_inputs():
        fixed_shape = [1 if isinstance(dim, str) else dim for dim in input.shape]
        input_data[input.name] = np.random.rand(*fixed_shape).astype(np.float32)

    # Compute CPU results (reference values)
    cpu_outputs = cpu_session.run(None, input_data)
    # Compute NPU results
    try:
        start_time = time.time()
        npu_outputs = npu_session.run(None, input_data)
        end_time = time.time()
        total_npu_time_s += end_time - start_time
    except Exception as e:
        print(f"Failed to run on NPU: {e}")
        sys.exit(1) 

    # Compare CPU and NPU results
    max_diff = np.max(np.abs(cpu_outputs[0] - npu_outputs[0]))
    rmse = np.sqrt(np.mean((cpu_outputs[0] - npu_outputs[0]) ** 2))
    print(f'Iteration {i+1:3d}: Max absolute difference = {max_diff:.6f}, Root mean squared error = {rmse:.6f}')

avg_time_s = total_npu_time_s / num_iter
print(f"[PERF] npu_avg_latency_ms={avg_time_s * 1000:.3f}")
print(f"[PERF] npu_fps={1.0 / avg_time_s:.3f}")
print("Inference Done!")
