## Smartcam  
[Link](https://xilinx.github.io/kria-apps-docs/kv260/2022.1/build/html/docs/smartcamera/smartcamera_landing.html)  
  
#### UbuntuのSDカードを作成する  
[CanonicalのHP](https://ubuntu.com/download/amd)よりK26向けのUbuntu22.04のインストールを実施する。  
カードにイメージを書き込んだら、DISKスペースを最大にリサイズする。  
Ubuntuの機能(DISKアプリ)で実行可能->32gb程度が最適。  
  
#### 基本的な環境を設定する  
> sudo snap install xlnx-config --classic --channel=2.x  
> xlnx-config.sysinit  
> sudo apt-get install update  
> sudo apt-get install upgrade  
> sudo apt-get install xlnx-firmware-kv260*  
  
> sudo apt-get install libglu1-mesa-dev  
> sudo apt-get install libjson-c*  
> sudo apt-get install libopencv-*  
  
#### OpenCVインストール(DPU使用しなければ特に不要)  
> mkdir opencv  
> wget https://github.com/opencv/opencv/archive/3.4.16.zip  
> mv 3.4.16.zip opencv-3.4.16.zip  
> wget https://github.com/opencv/opencv_contrib/archive/3.4.16.zip  
> mv 3.4.16.zip opencv_contrib-3.4.16.zip  
> unzip -q opencv-3.4.16.zip  
> ln -s opencv-3.4.16 opencv  
> unzip -q opencv_contrib-3.4.16.zip  
> ln -s opencv_contrib-3.4.16 opencv_contrib  
> mkdir build  
> cd build  
> export CC=gcc  
> export CXX=g++  
> cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D OPENCV_EXTRA_MODULES_PATH=~/opencv/opencv_contrib/modules -D BUILD_NEW_PYTHON_SUPPORT=ON -D WITH_V4L=ON -D WITH_VTK=ON -D INSTALL_C_EXAMPLES=ON -D PYTHON3_EXECUTABLE=/usr/bin/python3.8 -D PYTHON_INCLUDE_DIR=/usr/include/python3.8 -D INSTALL_PYTHON_EXAMPLES=ON -D BUILD_EXAMPLES=ON -D ENABLE_FAST_MATH=1 -D WITH_CUDA=OFF  
> make -j4  
> sudo make install  
  
#### Docker環境を構築する  
> sudo apt-get install docker docker.io  
> sudo gpasswd -a <User> docker  
> id <ユーザー名>  
> sudo reboot  
  
#### DESKTOP環境をOFFする  
> sudo xmutil desktop_disable  
  
#### SmartCamera(回路)を呼び出す  
> sudo xmutil unloadapp  
> sudo xmutil loadapp kv260-smartcam  
  
#### SmartCamera(アプリ)を呼び出す  
> docker pull xilinx/smartcam:2022.1  
> bash docker_run.bash  
> cd /opt/xilinx/kv260-smartcam/bin  
> bash 02.mipi-dp.sh  
> smartcam --mipi -W 1920 -H 1080 --target file  

