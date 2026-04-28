### Ryzen AI Softwareを試す

Ryzen AI Max+395 GMKtecでお試し  

以下、v1.7.1の操作メモ  
[公式ドキュメント](https://ryzenai.docs.amd.com/en/latest/)  

#### インストール開始  
・Visual Studio Community 2026をインストール    
　「C++デスクトップ開発」「MSVC v143 - VS 2022 C++ x64/x86 build tools」「Windows11 SDK」のインストールを実施する

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
  ryzen-ai-lt-1.7.1.exeをダウンロードする際、AMDアカウントが必要
  問題なければパスはデフォルトでOKC:\Program Files\RyzenAI\1.7.1\
  
  インストール後、Anacondaの環境リストにryzen-ai-1.7.1が追加されているので、仮想環境で下記を実行
  
#### Miniforge起動  
  > conda activate ryzen-ai-1.7.1  
  > cd Program Files\RyzenAI\1.7.1\quicktest  
  > python quicktest.py  


#### NPUチュートリアル開始  
[チュートリアル](https://ryzenai.docs.amd.com/en/latest/examples.html)お試ししてみよう。  
  
Ryzen AI SWのリポジトリをクローンする必要があるので、[Git for Windows](https://gitforwindows.org/)をインストールしよう  

v2.53.0をインストール  

> git clone https://github.com/amd/RyzenAI-SW.git -b v1.7.1

