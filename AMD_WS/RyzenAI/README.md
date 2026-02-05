### Ryzen AI Softwareを試す

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
