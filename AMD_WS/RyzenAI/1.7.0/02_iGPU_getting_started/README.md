#### iGPU Example  
[チュートリアルはここ](https://github.com/amd/RyzenAI-SW/tree/main/CNN-examples/iGPU/getting_started)  

##### Setup Env  
> cd RyzenAI-SW\CNN-examples\iGPU\getting_started  
> conda create --name igpu_example --clone ryzen-ai-1.7.0  
> conda activate igpu_example  
> set RYZEN_AI_INSTALLATION_PATH=Path to RyzenAI Installation  
> python -m pip install -r requirements.txt  
> pip install onnxruntime-genai  
> python -m olive.workflows.run --config resnet50_config.json --setup  
> python -m olive.workflows.run --config resnet50_config.json  

