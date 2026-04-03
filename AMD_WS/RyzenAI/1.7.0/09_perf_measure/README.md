#### Ryzen AI SoftwareによるNPUのパフォーマンス測定  
NPUのパフォーマンスを測定するには付属の実行プログラムmodel_performance.exeを使用する  
[ここ](https://ryzenai.docs.amd.com/en/latest/hybrid_oga.html)に詳細の記載がある  

cd RyenAI-SW_1.7.0\TEST_WS  
mkdir perf_measure  
cd perf_measure  
  
xcopy /Y "%RYZEN_AI_INSTALLATION_PATH%\LLM\example\model_benchmark.exe" .  
xcopy /Y "%RYZEN_AI_INSTALLATION_PATH%\LLM\example\amd_genai_prompt.txt" .  
xcopy /Y "%RYZEN_AI_INSTALLATION_PATH%\deployment\." .  
  
************************************************************  
> (base) D:\RyzenWS\RyzenAI-SW_1.7.0\TEST_WS\perf_measure>.\model_benchmark.exe -h  
Usage: .\model_benchmark.exe -i <model path> <other options>  
  Options:  
    -i,--input_folder <path>  
      Path to the ONNX model directory to benchmark, compatible with onnxruntime-genai.  
    -b,--batch_size <number>  
      Number of sequences to generate in parallel. Default: 1  
    -l,--prompt_length <number>  
      List of number of tokens in the prompt (comma separated). Default:  
    -f,--prompt_file <filename>  
      Path to prompt file.  
    -g,--generation_length <number>  
      Number of tokens to generate. Default: 128  
    -r,--repetitions <number>  
      Number of times to repeat the benchmark. Default: 5  
    -w,--warmup <number>  
      Number of warmup runs before benchmarking. Default: 1  
    -v,--verbose  
      Show more informational output.  
    --no_dynamic_max_length  
      Disable dynamic max_length.  
    -o,--output_json <path>  
      Path to save benchmark results in JSON format.  
    -a,--in_memory  
      Load model, external data, header into memory first before calling OGA.  
    -m,--model_file_name  
      required if doing in memory.  
    -e,--external_file_name  
      required if doing in memory.  
    -p,--proto_file_name  
      required if doing in memory.  
    --lora  
      Lora adapter name.  
    -tgi,--tinygsm_input  
      TinyGSM input path.  
    -tgr,--tinygsm_report  
      TinyGSM report path.  
    -h,--help  
      Show this help message and exit.  
	    
************************************************************  
  
##### モデルの取得  
git lfs install  
git clone https://huggingface.co/amd/Llama-2-7b-chat-hf-onnx-ryzenai-1.7-hybrid  

(base) D:\RyzenWS\RyzenAI-SW_1.7.0\TEST_WS\perf_measure>.\model_benchmark.exe -i Llama-2-7b-chat-hf-onnx-ryzenai-1.7-hybrid -f amd_genai_prompt.txt -l "1024"  
  
Prompt Number of Tokens: 1024  
Batch size: 1, prompt tokens: 1024, tokens to generate: 128  
  
Prompt processing (time to first token):   
        avg (us):       1.6062e+06  
        avg (tokens/s): 637.528  
        p50 (us):       1.60803e+06  
        stddev (us):    5102.57  
        n:              5 * 1024 token(s)  
Token generation:  
        avg (us):       27308.3  
        avg (tokens/s): 36.6188  
        p50 (us):       27405.6  
        stddev (us):    621.395  
        n:              635 * 1 token(s)  
Token sampling:  
        avg (us):       63.88  
        avg (tokens/s): 15654.4  
        p50 (us):       53.8  
        stddev (us):    26.2474  
        n:              5 * 1 token(s)  
E2E generation (entire generation loop):  
        avg (ms):       5074.76  
        p50 (ms):       5077.33  
        stddev (ms):    20.6812  
        n:              5  
E2E RAI performance counters (avg in ms):  
        to enable: set RYZENAI_EP_PERFORMANCE_COUNTERS=1  
Peak working set size (bytes): 6291603456  
  
  
Prompt processing (time to first token):  
1024トークンの入力を処理して、最初の出力が出るまで平均 1.606 秒  
  
Token generation:  
生成本体  
生成は 1トークンあたり約27.3msで、TPSは36.6 tokens/sec  
  
Token sampling:  
サンプリングは 0.064ms/token  
  
E2E generation：  
「1024トークン入力＋128トークン生成」の総時間の平均 ≒ 5.10 秒  
  
  
##### NPU Only Design  
  
git clone https://huggingface.co/amd/Llama-2-7b-chat-hf-onnx-ryzenai-npu  
.\model_benchmark.exe -i Llama-2-7b-chat-hf-onnx-ryzenai-npu -f amd_genai_prompt.txt -l "1024" -g 128  
  
DEPRECATED session option was used (config_entries): use 'session_options' directly instead.  
Prompt Number of Tokens: 1024  
Batch size: 1, prompt tokens: 1024, tokens to generate: 128  
Prompt processing (time to first token):  
        avg (us):       1.63071e+06  
        avg (tokens/s): 627.949  
        p50 (us):       1.63719e+06  
        stddev (us):    15467.1  
        n:              5 * 1024 token(s)  
Token generation:  
        avg (us):       116258  
        avg (tokens/s): 8.60159  
        p50 (us):       115269  
        stddev (us):    6895.78  
        n:              635 * 1 token(s)  
Token sampling:  
        avg (us):       51.24  
        avg (tokens/s): 19516  
        p50 (us):       47.5  
        stddev (us):    8.53979  
        n:              5 * 1 token(s)  
E2E generation (entire generation loop):  
        avg (ms):       16395.8  
        p50 (ms):       16393.2  
        stddev (ms):    32.5483  
        n:              5  
Peak working set size (bytes): 9497800704  
  
  
Prompt processing (time to first token):  
1024トークンの入力を処理して、最初の出力が出るまで平均 1.63 秒  
  
Token generation:  
生成本体  
生成は 1トークンあたり約116.3msで、TPSは8.6 tokens/sec  
  
Token sampling:  
サンプリングは 0.05ms/token  
  
E2E generation：  
「1024トークン入力＋128トークン生成」の総時間の平均 ≒ 16.4 秒  