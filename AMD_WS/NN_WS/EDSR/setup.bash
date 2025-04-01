#!/bin/bash

# 仮想環境の作成と有効化
python3 -m venv edsr_env
source edsr_env/bin/activate

# PyTorchのインストール（必要に応じてCUDA対応版に変更）
pip install --upgrade pip
pip install torch torchvision

# その他必要なライブラリ
pip install pillow matplotlib dict

# EDSRのモデルを取得
mkdir -p models
wget https://cv.snu.ac.kr/research/EDSR/models/edsr_baseline_x4-6b446fab.pt -O models/edsr_baseline_x4.pt

git clone https://github.com/sanghyun-son/EDSR-PyTorch.git
cp -r EDSR-PyTorch/src/model .

echo "環境構築が完了しました。次は source edsr_env/bin/activate で仮想環境を有効にしてください。"

