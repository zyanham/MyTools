1.Mediapipe Tutorial

####################
# Mediapipe Install
####################
pip install mediapipe

############################################
# Bazel Install                            #
# https://bazel.build/install/ubuntu?hl=ja #
############################################
sudo apt install apt-transport-https curl gnupg -y
curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor >bazel-archive-keyring.gpg
sudo mv bazel-archive-keyring.gpg /usr/share/keyrings
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/bazel-archive-keyring.gpg] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
sudo apt update && sudo apt install bazel
sudo apt update && sudo apt full-upgrade

###########################
# TensorFlow Lite Install #
###########################
python3 -m pip install tflite-runtime

###########################
# Install Package
###########################
pip install plotly


git clone https://github.com/AlbertaBeef/blaze_app_python
cd blaze_app_python
cd blaze_tflite/models
source ./get_tflite_models.sh
cd ../..

python blaze_detect_live.py --list
python3 blaze_detect_live.py --target=blaze_tflite --blaze=hand


##########################################################################
##########################################################################
##########################################################################

2.Mediapipe Tutorial 2(for Vitis-AI)

git clone --branch 2023.1 --recursive https://github.com/AlbertaBeef/blaze_tutorial
cd blaze_tutorial/vitis-ai
source ./prepare_docker.sh

docker pull xilinx/vitis-ai-pytorch-cpu
./docker_run.sh xilinx/vitis-ai-pytorch-cpu
cd vitis-ai

LINK:https://www.kaggle.com/datasets/ritikagiridhar/2000-hand-gestures
#ダウンロードしたデータセットを使ってキャリブレーションデータを作る

mv <download dir>/archive.zip .
unzip archive.zip
mv images kaggle_hand_gestures_dataset
python3 gen_calib_hand_dataset.py

#これにより、手のひら検出モデルと手のランドマーク モデルの 0.07 バージョンに対して次のキャリブレーション データが作成されます。
#calib_palm_detection_256_dataset.npy: 256x256 RGB 画像のサンプル 1871 個
#calib_hand_landmark_256_dataset.npy: 256x256 RGB 画像のサンプル 1880 個


