## Real-ESRGAN-1024x1024-tiles-amdnpu  

[この](https://huggingface.co/amd/realesrgan-1024x1024-tiles-amdnpu)モデルを実行する  

> conda create --name resrgan_env --clone ryzen-ai-1.7.0  
> git clone https://huggingface.co/amd/realesrgan-1024x1024-tiles-amdnpu  

> pip install -r requirements.txt  

> python onnx_inference.py --onnx onnx-models\realesrgan_nchw_1024x1024_u8s8.onnx --input .\INPUT\test01.JPG --out-dir \outputs --device npu  

