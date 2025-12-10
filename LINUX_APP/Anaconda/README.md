# Anaconda / conda コマンド あんちょこ  
  
## 0. 前提  
  
- 「Anaconda / Miniconda / Miniforge」共通で使える `conda` コマンドのチートシート。  
- `base` 環境ではなく、なるべくプロジェクトごとに仮想環境を作成する前提。  
  
---  
  
## 1. conda 自体の情報  
  
```bash  
# バージョン確認  
conda --version  
  
# 設定の一覧  
conda config --show  
  
# conda 本体のアップデート  
conda update conda  
```  
## 2.環境回り  
```bash
# env_name という名前で Python 3.10 の環境を作成  
conda create -n env_name python=3.10  
  
# パッケージを指定して作成  
conda create -n env_name python=3.10 numpy scipy matplotlib  
  
# 有効化（Unix系: macOS / Linux）  
conda activate env_name  
  
# 有効化（古い書き方：推奨しないが覚えておく）  
source activate env_name  
  
# 無効化（どのOSでも共通）  
conda deactivate  
```  
## 3.パッケージ操作  
```bash  
# 現在の環境に numpy をインストール  
conda install numpy  
  
# 特定バージョンをインストール  
conda install numpy=1.26  
  
# 別のチャネルを使ってインストール（例: conda-forge）  
conda install -c conda-forge opencv  
  
# 特定パッケージを最新版にアップデート  
conda update numpy  
  
# 環境内のすべてのパッケージをアップデート（慎重に）  
conda update --all  
  
# パッケージのアンインストール  
conda remove numpy  
  
# 現在の環境のパッケージ一覧  
conda list  
  
# 名前で検索  
conda search numpy  
```  
## 4.環境のエクスポート/再現  
```bash  
# 現在の環境を environment.yml に書き出し  
conda env export > environment.yml  
  
# 特定の環境をエクスポート  
conda env export -n env_name > env_env_name.yml  
  
# environment.yml から環境作成  
conda env create -f environment.yml  
  
# 既存環境を YAML に合わせて更新  
conda env update -f environment.yml  
```  
