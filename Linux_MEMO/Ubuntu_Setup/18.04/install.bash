
## exFAT INSTALL
sudo add-apt-repository universe
sudo apt update
sudo apt install exfat-fuse exfat-utils

## apt command package update
sudo dpkg --add-architecture i386
sudo add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"
sudo apt update
sudo apt upgrade


## For Convenience Tools
sudo apt-get -y install imagemagick vim git make net-tools wget tar gzip unzip cmake docker docker.io ffmpeg

## For Petalinux
sudo apt-get -y install dos2unix iproute2 gawk libncurses5-dev tftpd zlib1g
sudo apt-get -y install libssl-dev flex bison libselinux1 gnupg diffstat socat xterm autoconf libtool
sudo apt-get -y install texinfo zlib1g-dev gcc-multilib build-essential screen pax zlib1g:i386
sudo apt-get -y install chrpath opencl-headers libeigen3-dev libgtk-3-dev qt5-default freeglut3-dev
sudo apt-get -y install libvtk6-qt-dev libtbb-dev libdc1394-22-dev libavcodec-dev libavformat-dev
sudo apt-get -y install libswscale-dev libjpeg-dev libpng++-dev libtiff5-dev libopenexr-dev libwebp-dev libhdf5-dev
sudo apt-get -y install libpython3.8-dev python3 python3-numpy python3-scipy python3-matplotlib
sudo apt-get -y install libopenblas-dev liblapacke-dev python3-pip python3-dev
sudo apt-get -y install pkg-config python-h5py ipython graphviz python-opencv
sudo apt-get -y install cmake-qt-gui qtbase5-dev libopencv-dev libeigen3-dev python2.7 cython cython3
sudo apt-get -y install libcublas9.1 curl libjasper1 yasm libxine2-dev libv4l-dev swig


## For GStreamer
cd /usr/include/linux
sudo ln -s -f ../libv4l1-videodev.h videodev.h
cd "$cwd"

sudo apt -y install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgtk2.0-dev libtbb-dev qt5-default
sudo apt -y install libatlas-base-dev libfaac-dev libmp3lame-dev libtheora-dev libvorbis-dev libxvidcore-dev
sudo apt -y install libopencore-amrnb-dev libopencore-amrwb-dev libavresample-dev x264 v4l-utils
sudo apt -y install libprotobuf-dev protobuf-compiler libgoogle-glog-dev libgflags-dev libgphoto2-dev libeigen3-dev
sudo apt -y install libhdf5-dev doxygen

## pip Setting
sudo -H pip3 install -U pip
pip3 install opencv-python
pip3 install pydot-ng
pip3 install slidingwindow
pip3 install -U scipy
sudo -H pip3 install -U numpy
sudo apt -y install python3-testresources

## VIM setting
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

## Docker TEX
sudo docker pull paperist/texlive-ja:latest

