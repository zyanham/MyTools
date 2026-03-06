#### Gemma3  

conda activate ryzen-ai-1.7.0  
git clone https://github.com/amd/RyzenAI-SW.git  
cd RyzenAI-SW\LLM-examples\VLM  
git clone https://huggingface.co/amd/Gemma-3-4b-it-mm-onnx-ryzenai-npu  
  
mkdir Gemma-3-4b-it-mm-onnx-ryzenai-npu  
mv model.pb.bin Gemma-3-4b-it-mm-onnx-ryzenai-npu/.  
mv gemma-3-vision-npu.pb.bin Gemma-3-4b-it-mm-onnx-ryzenai-npu/.  

python run_vision.py -m ./Gemma-3-4b-it-mm-onnx-ryzenai-npu  

