#### Windows ML Probe Flow  

conda deactivate  
python -m venv venv_winml  

venv_winml\Scripts\activate

python -m pip install --upgrade pip  
##### Install Windows ML  
python -m pip install wasdk-Microsoft.Windows.AI.MachineLearning[all] wasdk-Microsoft.Windows.ApplicationModel.DynamicDependency.Bootstrap onnxruntime-windowsml  

python -m pip install huggingface_hub
python -c "from huggingface_hub import hf_hub_download; print(hf_hub_download(repo_id='amd/resnet50', filename='ResNet_int.onnx', local_dir='.'))"

set MODEL_ONNX=ResNet_int.onnx
python 01_run_with_vitisai.py

'''  
(venv_winml) D:\RyzenWS\RyzenAI-SW_1.7.0\TEST_WS\WinML_probe>python 01_run_with_vitisai.py  
== ep_devices ==  
[0] ep_name=CPUExecutionProvider vendor=Microsoft device=<onnxruntime.capi.onnxruntime_pybind11_state.OrtHardwareDevice object at 0x00000248D4E852F0>  
[1] ep_name=DmlExecutionProvider vendor=Microsoft device=<onnxruntime.capi.onnxruntime_pybind11_state.OrtHardwareDevice object at 0x00000248D4E852F0>  
[2] ep_name=VitisAIExecutionProvider vendor=AMD device=<onnxruntime.capi.onnxruntime_pybind11_state.OrtHardwareDevice object at 0x00000248D4E7CC30>  
2026-03-13 10:17:21.8400985 [W:onnxruntime:, PartitionPass.cpp:12504 PartitionPass.cpp] xir::Op{name = (1327)_replaced_input271, type = dequantize-linear} is partitioned to CPU as :  doesn't supported by target [AMD_AIE2P_4x8_CMC_Overlay].  
INFO: [aiecompiler 77-749] Reading logical device aie2p_8x4_device  
Using TXN FORMAT 0.1  
2026-03-13 10:17:23.2114434 [W:onnxruntime:, pass_main.cpp:250 pass_main.cpp] skip mmap in sg: 2. runner libgraph-engine.so not support mmap  
session providers: ['VitisAIExecutionProvider', 'CPUExecutionProvider']  
input: name=ResNet::input_0, type=tensor(float), shape=[1, 224, 224, 3], dtype=<class 'numpy.float32'>  
== outputs ==  
[0] shape=(1, 1000) dtype=float32  
'''  

[Windows MLでサポートされている実行プロバイダー](https://learn.microsoft.com/ja-jp/windows/ai/new-windows-ml/supported-execution-providers?utm_source=chatgpt.com)  
