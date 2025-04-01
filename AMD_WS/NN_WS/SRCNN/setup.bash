#!/bin/bash
python3 -m venv srcnn_env
source srcnn_env/bin/activate
pip install --upgrade pip
pip install torch torchvision matplotlib opencv-python
git clone https://github.com/Lornatang/SRCNN-PyTorch.git
cp inference.py SRCNN-PyTorch/.
cd SRCNN-PyTorch
echo "Setup complete. To start inference:"
echo "source srcnn_env/bin/activate"
echo "python ./inference.py --inputs_path ./figure/butterfly_lr.png --output_path ./figure/butterfly_sr.png --weights_path ./results/pretrained_models/srcnn_x2-T91-7d6e0623.pth.tar"

