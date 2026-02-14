### LLMを試す
Ryzen AI Max+395 GMKtecでお試し  
※1.7.0現在、LLMデモが動作しないため、1.5.0で実行する。  

> cd Ryzen AI 1.5.0 Dir\example\llm\oga_api  

##### お試しモデル
Ryzen AI Hybrid Model：[Llama-2-7b-chat-hf-awq-g128-int4-asym-fp16-onnx-hybrid](https://huggingface.co/amd/Llama-2-7b-chat-hf-awq-g128-int4-asym-fp16-onnx-hybrid)  
Ryzen AI NPU Model   ：[Llama2-7b-chat-awq-g128-int4-asym-bf16-onnx-ryzen-strix](https://huggingface.co/amd/Llama2-7b-chat-awq-g128-int4-asym-bf16-onnx-ryzen-strix)  

> conda activate ryzen-ai-1.5.0  

##### HuggingFaceからダウンロードする
> git clone https://huggingface.co/amd/Llama-2-7b-chat-hf-awq-g128-int4-asym-fp16-onnx-hybrid  
> git clone https://huggingface.co/amd/Llama2-7b-chat-awq-g128-int4-asym-bf16-onnx-ryzen-strix  


> git clone https://github.com/amd/RyzenAI-SW -b v1.5.0  
> cd path\to\RyzenAI-SW\example\llm\oga_api  

##### 必要なライブラリやヘッダをコピー  
xcopy /I "%RYZEN_AI_INSTALLATION_PATH%\deployment\*" libs  
xcopy /I "%RYZEN_AI_INSTALLATION_PATH%\LLM\lib\onnxruntime-genai.lib" libs  
xcopy /I "%RYZEN_AI_INSTALLATION_PATH%\LLM\include\*" include  

##### コードをコンパイルする  
> mkdir build  
> cd build  
> cmake .. -A x64  
> cmake --build . --config Release  
> cd bin\Release  

> .\example.exe -m "<path_to_model>"  
> .\example.exe -m "path\to\Llama-2-7b-chat-hf-awq-g128-int4-asym-fp16-onnx-hybrid"  
> .\example.exe -m "path\to\Llama2-7b-chat-awq-g128-int4-asym-bf16-onnx-ryzen-strix"  
