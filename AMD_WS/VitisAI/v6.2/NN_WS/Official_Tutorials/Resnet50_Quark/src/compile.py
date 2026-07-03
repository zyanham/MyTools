#Copyright (C) 2026, Advanced Micro Devices, Inc. All rights reserved.
#SPDX-License-Identifier: MIT

import os

import onnxruntime

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

session = onnxruntime.InferenceSession(
        'models/resnet50-v1-12_quantized.onnx',
        providers=["VitisAIExecutionProvider"],
        provider_options=[provider_options_dict]
)
