### Ryzen AI Softwareを試す

Ryzen AI Max+395 GMKtecでお試し  

以下、v1.6.1の操作メモ  
[公式ドキュメント](https://ryzenai.docs.amd.com/en/1.6.1/)  

#### インストール開始  
・Visual Studio Community 2026をインストール    
　「C++デスクトップ開発」「MSVC v143 - VS 2022 C++ x64/x86 build tools」「Windows11 SDK」のインストールを実施する

  [Cmake](https://cmake.org/download/)の4.2.3をインストール  
  [miniforge](https://github.com/conda-forge/miniforge/releases/tag/25.11.0-1)の25.11.0-1をインストール。
  　環境変数のPATHパスも通す。  
     - path\to\miniforge3\condabin  
     - path\to\miniforge3\Scripts\  
     - path\to\miniforge3\  
  [Ryzen AI Driver](https://ryzenai.docs.amd.com/en/1.6.1/inst.html)をインストール。NPU Driver (Version 32.0.203.280)  
    タスクマネージャーで NPU driver version: 32.0.203.280の表記があることを確認

  再起動  

  [Ryzen AI Software](https://ryzenai.docs.amd.com/en/1.6.1/inst.html)をインストールする。  
  
#### Miniforge起動  
  > conda activate ryzen-ai-1.6.1  
  > cd Program Files\RyzenAI\1.6.1\quicktest  
  > python quicktest.py  

```
(ryzen-ai-1.6.1) C:\Program Files\RyzenAI\1.6.1\quicktest>python quicktest.py
WARNING: Logging before InitGoogleLogging() is written to STDERR
I20260213 20:44:18.854471 10696 register_ssmlp.cpp:124] Registering Custom Operator: com.amd:SSMLP
I20260213 20:44:18.855470 10696 register_matmulnbits.cpp:110] Registering Custom Operator: com.amd:MatMulNBits
I20260213 20:44:18.881469 10696 vitisai_compile_model.cpp:1263] Vitis AI EP Load ONNX Model Success
I20260213 20:44:18.881469 10696 vitisai_compile_model.cpp:1264] Graph Input Node Name/Shape (1)
I20260213 20:44:18.881469 10696 vitisai_compile_model.cpp:1268]          input : [-1x3x32x32]
I20260213 20:44:18.881469 10696 vitisai_compile_model.cpp:1274] Graph Output Node Name/Shape (1)
I20260213 20:44:18.881469 10696 vitisai_compile_model.cpp:1278]          output : [-1x10]
Using TXN FORMAT 0.1
[Vitis AI EP] No. of Operators :   NPU   398 VITIS_EP_CPU     2
[Vitis AI EP] No. of Subgraphs :   NPU     1 Actually running on NPU      1
Test Passed
```

