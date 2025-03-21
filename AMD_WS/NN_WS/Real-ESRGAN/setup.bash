## インストール
sudo apt-get install libcudart11.0
python3 -m venv real-esrgan-env2
source real-esrgan-env2/bin/activate
pip install -r req.txt

git clone https://github.com/xinntao/Real-ESRGAN.git
cd Real-ESRGAN
pip install -r requirements.txt

## 事前学習済みモデルのダウンロード
wget https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth -P weights

sed -i 's/^from \.version/#&/' realesrgan/__init__.py

python3 ../genimg.py
python3 inference_realesrgan.py -n RealESRGAN_x4plus -i input.jpg --outscale 4

