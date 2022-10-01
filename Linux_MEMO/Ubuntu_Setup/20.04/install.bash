#! /bin/bash

## setup exFAT
sudo add-apt-repository universe
sudo apt update
sudo apt install exfat-fuse exfat-utils

## apt command Package update
sudo dpkg --add-architecture i386  
sudo add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"  
sudo apt-get update
sudo apt-get upgrade  

## For Petalinux etc..
sudo apt-get -y install imagemagick vim git dos2unix iproute2 gawk make net-tools libncurses5-dev tftpd zlib1g  
sudo apt-get -y install libssl-dev flex bison libselinux1 gnupg wget diffstat socat xterm autoconf libtool tar
sudo apt-get -y install unzip texinfo zlib1g-dev gcc-multilib build-essential screen pax gzip python2.7 zlib1g:i386
sudo apt-get -y install chrpath opencl-headers cmake libeigen3-dev libgtk-3-dev qt5-default freeglut3-dev
sudo apt-get -y install libvtk6-qt-dev libtbb-dev ffmpeg libdc1394-22-dev libavcodec-dev libavformat-dev
sudo apt-get -y install libswscale-dev libjpeg-dev libpng++-dev libtiff5-dev libopenexr-dev libwebp-dev libhdf5-dev
sudo apt-get -y install libpython3.8-dev python3 python3-numpy python3-scipy python3-matplotlib libopenblas-dev
sudo apt-get -y install liblapacke-dev python3-pip python3-dev pkg-config python3-h5py ipython3 graphviz python3-opencv
sudo apt-get -y install cmake-qt-gui qtbase5-dev libopencv-dev docker docker.io libeigen3-dev cython cython3
sudo apt-get -y install libcublas10 curl libjasper1 yasm libxine2-dev libv4l-dev swig libtinfo5

## For Gstreamer
sudo apt -y install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgtk2.0-dev libtbb-dev qt5-default
sudo apt -y install libatlas-base-dev libfaac-dev libmp3lame-dev libtheora-dev libvorbis-dev libxvidcore-dev
sudo apt -y install libopencore-amrnb-dev libopencore-amrwb-dev libavresample-dev x264 v4l-utils
sudo apt -y install libprotobuf-dev protobuf-compiler libgoogle-glog-dev libgflags-dev libgphoto2-dev libeigen3-dev
sudo apt -y install libhdf5-dev doxygen

# For Network Env.
sudo apt-get -y install iperf3 alien netperf dkms ethtool

# For Etc.
sudo apt-get -y install gtkterm

# Install Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb  
sudo dpkg -i google-chrome-stable_current_amd64.deb

## Python Pip setup
sudo -H pip3 install -U pip
pip3 install opencv-python
pip3 install pydot-ng
pip3 install slidingwindow
pip3 install -U scipy
sudo -H pip3 install -U numpy
sudo apt -y install python3-testresources

## Generate vimrc
echo "set number" > ~/.vimrc
echo "set title" >> ~/.vimrc
echo "set tabstop=4" >> ~/.vimrc
echo "set cursorline" >> ~/.vimrc
echo "syntax on" >> ~/.vimrc
echo "" >> ~/.vimrc
echo "highlight Comment ctermfg=Green" >> ~/.vimrc
echo "highlight Constant ctermfg=Red" >> ~/.vimrc
echo "highlight Identifier ctermfg=Cyan" >> ~/.vimrc
echo "highlight Statement ctermfg=Yellow" >> ~/.vimrc
echo "highlight Title ctermfg=Magenta" >> ~/.vimrc
echo "highlight Special ctermfg=Magenta" >> ~/.vimrc
echo "highlight PreProc ctermfg=Magenta" >> ~/.vimrc

## Camera Library Setup
cd /usr/include/linux
sudo ln -s -f ../libv4l1-videodev.h videodev.h
cd ~

## Japanese Emv Setup
sudo apt install language-pack-ja-base language-pack-ja ibus-mozc
sudo update-locale LANG=ja_JP.UTF8
ibus restart
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'jp'), ('ibus', 'mozc-jp')]"

## OpenCV Install
#cd
#mkdir OpenCV_Build
#cd OpenCV_Build
#git clone https://github.com/opencv/opencv.git -b 4.4.0
#git clone https://github.com/opencv/opencv_contrib.git -b 4.4.0
#mkdir opencv/build
#cd opencv/build

#cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_C_COMPILER=/usr/bin/gcc -D CMAKE_INSTALL_PREFIX=/usr/local -D INSTALL_PYTHON_EXAMPLES=ON -D INSTALL_C_EXAMPLES=OFF -D WITH_TBB=ON -D WITH_CUDA=OFF -D BUILD_opencv_cudacodec=OFF -D ENABLE_FAST_MATH=1 -D CUDA_FAST_MATH=1 -D WITH_CUBLAS=1 -D WITH_V4L=ON -D WITH_QT=OFF -D WITH_OPENGL=ON -D WITH_GSTREAMER=ON -D OPENCV_GENERATE_PKGCONFIG=ON -D OPENCV_PC_FILE_NAME=opencv.pc -D OPENCV_ENABLE_NONFREE=ON -D OPENCV_PYTHON3_INSTALL_PATH=~/.virtualenvs/cv/lib/python3.8/site-packages -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-4.2.0/modules -D PYTHON_EXECUTABLE=~/.virtualenvs/cv/bin/python -D BUILD_EXAMPLES=ON ..

#sudo make -j7
#sudo make install
#sudo echo /usr/local/lib > /etc/ld.so.conf.d/opencv.conf
#ldconfig -v
#opencv_version

## Github Clone
cd
mkdir Third_Party_GIT
mv Third_Party_GIT
git clone https://github.com/Digilent/vivado-library.git
git clone https://github.com/Digilent/vivado-boards.git
git clone https://github.com/Avnet/bdf.git
mv vivado-libary Digilent_IP
mv vivado-boards Digilent_bdf
mv bdf AVNET_bdf


## Vitis AI Setup
##cd ~/Desktop
##git clone -b v2.0 https://github.com/Xilinx/Vitis-AI.git
##mv Vitis-AI Vitis-AI_v2.0
##cd Vitis-AI_v2.0/setup/alveo
##source ./install.sh
##cd ../mpsoc/VART
##./host_cross_compiler_setup.sh


## Docker TEX
sudo docker pull paperist/texlive-ja:latest

