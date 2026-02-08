### Ryzen AI Softwareを試す

Ryzen AI Max+395 GMKtecでお試し  

以下、v1.7.0の操作メモ  
[公式ドキュメント](https://ryzenai.docs.amd.com/en/latest/)  

#### インストール開始  
・Visual Studio Community 2026をインストール    
　C++デスクトップ開発のインストールを実施する

  [Cmake](https://cmake.org/download/)の4.2.3をインストール  
  [miniforge](https://github.com/conda-forge/miniforge/releases/tag/25.11.0-1)の25.11.0-1をインストール。
  　環境変数のPATHパスも通す。  
     - path\to\miniforge3\condabin  
     - path\to\miniforge3\Scripts\  
     - path\to\miniforge3\  
  [Ryzen AI Driver](https://ryzenai.docs.amd.com/en/latest/inst.html)をインストール。NPU Driver (Version 32.0.203.280)  
    タスクマネージャーで NPU driver version: 32.0.203.280の表記があることを確認

  再起動  

  [Ryzen AI Software](https://ryzenai.docs.amd.com/en/latest/inst.html)をインストールする。  
  
#### Miniforge起動  
  > conda activate ryzen-ai-1.7.0  
  > cd Program Files\RyzenAI\1.7.0\quicktest  
  > python quicktest.py  

```  
2026-02-05 17:50:08.3362844 [W:onnxruntime:, RedundantOpReductionPass.cpp:846 RedundantOpReductionPass.cpp] xir::Op{name = (/avgpool/GlobalAveragePool_output_0_Mul_vaip_163), type = qlinear-pool}'s input and output is unchanged, so it will be removed.  
2026-02-05 17:50:08.5243856 [W:onnxruntime:, PartitionPass.cpp:12507 PartitionPass.cpp] xir::Op{name = (output)_replaced_input236, type = dequantize-linear} is partitioned to CPU as :  doesn't supported by target [AMD_AIE2P_4x8_CMC_Overlay].  
INFO: [aiecompiler 77-749] Reading logical device aie2p_8x4_device  
Using TXN FORMAT 0.1  
2026-02-05 17:50:09.7313369 [W:onnxruntime:, pass_main.cpp:250 pass_main.cpp] skip mmap in sg: 2. runner libgraph-engine.so not support mmap
Test Passed  
```  

#### NPUチュートリアル開始  
[チュートリアル](https://ryzenai.docs.amd.com/en/latest/examples.html)お試ししてみよう。  
  
Ryzen AI SWのリポジトリをクローンする必要があるので、[Git for Windows](https://gitforwindows.org/)をインストールしよう  
> git clone https://github.com/amd/RyzenAI-SW.git -b v1.7.0

v2.53.0をインストール  
