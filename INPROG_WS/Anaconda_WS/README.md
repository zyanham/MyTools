# Anacondaいろいろ  
[ダウンロードページ](https://www.anaconda.com/download)よりダウンロードしてください  

```
# Create
conda create -n [name] python=[version] [library]

# list
conda info -e

# 仮想環境有効化
conda activate [name]	

# 仮想環境無効化
conda deactivate [name]

# Update
conda update conda

# インストール
conda install [name]	

# インストール (バージョン指定)
conda install [name]==x.x.x	

# アンインストール
conda uninstall [library]	

# インストール済み一覧
conda list

# Conda環境の自動起動(active)
conda config --set auto_activate_base true

# Conda環境の自動起動(deactive)
conda config --set auto_activate_base false

```
