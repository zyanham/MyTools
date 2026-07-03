#Copyright (C) 2026, Advanced Micro Devices, Inc. All rights reserved.
#SPDX-License-Identifier: MIT

import os

import onnxruntime

provider_options_dict = {
    "config_file": 'vitisai_config.json',
    "cache_dir":   'my_cache_dir',
    "cache_key":   'resnet18.a1_in1k',
    "log_level":   "info",
	"target": 'VAIML'
}

if os.environ.get("AI_ANALYZER", "0") == "1":
    provider_options_dict["ai_analyzer_visualization"] = True
    provider_options_dict["ai_analyzer_profiling"] = True
   
print(f"Creating ORT inference session for model models/resnet18.a1_in1k.onnx")
session = onnxruntime.InferenceSession(
    'models/resnet18.a1_in1k.onnx',
    providers=["VitisAIExecutionProvider"],
    provider_options=[provider_options_dict]
)   
 
