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

