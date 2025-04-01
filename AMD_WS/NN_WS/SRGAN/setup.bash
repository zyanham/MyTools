#!/bin/bash

VENV_NAME=venv-srgan-lorna
PYTHON=python3

# 仮想環境作成
$PYTHON -m venv $VENV_NAME
source $VENV_NAME/bin/activate

# 依存インストール
pip install --upgrade pip
pip install torch torchvision pillow gdown

# リポジトリ取得
if [ ! -d "SRGAN-PyTorch" ]; then
  git clone https://github.com/Lornatang/SRGAN-PyTorch.git
fi

cd SRGAN-PyTorch

# 学習済み重みを取得（Generator用）
mkdir -p weights
cd weights
gdown https://huggingface.co/Lornatang/SRGAN/resolve/main/generator.pth -O generator.pth
cd ../..

echo "✅ Setup complete."
echo "Run: source $VENV_NAME/bin/activate"
echo "Then: python SRGAN-PyTorch/inference.py --inputs input/input.png --output output/highres.png --weights <PATH>"

