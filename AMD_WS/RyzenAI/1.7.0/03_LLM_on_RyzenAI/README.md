### LLMs on RyzenAI with ONNX Runtime GenAI API(Llama)  
[チュートリアル](https://github.com/amd/RyzenAI-SW/tree/main/LLM-examples/oga_api)  

[Llama sample Hyblid](https://huggingface.co/amd/Llama-2-7b-chat-hf-awq-g128-int4-asym-fp16-onnx-hybrid)  
[Llama sample npu only](https://huggingface.co/amd/Llama2-7b-chat-awq-g128-int4-asym-bf16-onnx-ryzen-strix)  

> cd RyzenAI-SW\LLM-examples\oga_api  
> conda create --name llm_env --clone ryzen-ai-1.7.0  
> conda activate llm_env  
> git clone https://huggingface.co/amd/Llama-2-7b-chat-hf-awq-g128-int4-asym-fp16-onnx-hybrid  
> git clone https://huggingface.co/amd/Llama2-7b-chat-awq-g128-int4-asym-bf16-onnx-ryzen-strix  

Copy necessary DLLs and header files:  
> xcopy /I "C:\Program Files\RyzenAI\1.7.0\deployment\*" libs  
> xcopy /I "C:\Program Files\RyzenAI\1.7.0\LLM\lib\onnxruntime-genai.lib" libs  
> xcopy /I "C:\Program Files\RyzenAI\1.7.0\LLM\include\*" include  

Compile and build the code:  
> mkdir build  
> cd build  
> cmake .. -A x64  
> cmake --build . --config Release  
> cd bin\Release  
> .\example.exe -m "..\Llama-2-7b-chat-hf-awq-g128-int4-asym-fp16-onnx-hybrid"  
※[Issue 332](https://github.com/amd/RyzenAI-SW/issues/332)で報告されている RyzenAI 1.7.0+Hybridモデルでスタックバッファオーバーランでプロセス終了する。  

### 

