#! /bin/bash

## setup exFAT
sudo add-apt-repository universe
sudo apt update
sudo apt install exfat-fuse exfatprogs

## apt command Package update
sudo dpkg --add-architecture i386  
sudo dpkg-reconfigure dash
sudo add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"  

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-keys 40976EAF437D05B5
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32

sudo apt-get update
sudo apt-get upgrade  

## For Petalinux etc..
sudo apt-get -y install autoconf automake bison build-essential chrpath cmake cmake-qt-gui cpio curl cython3
sudo apt-get -y install debianutils diffstat docker docker.io dos2unix dpkg-dev:i386 ffmpeg flex freeglut3-dev
sudo apt-get -y install g++ gawk gcc gcc-multilib git gnupg google-perftools graphviz gzip haveged imagemagick
sudo apt-get -y install iproute2 iputils-ping ipython3 lib32stdc++6 libavcodec-dev libavformat-dev libcublas11
sudo apt-get -y install libdc1394-22-dev libegl1-mesa libeigen3-dev liberror-perl libfontconfig1:i386
sudo apt-get -y install libgtk2.0-0:i386 libgtk-3-dev libhdf5-dev libjpeg-dev liblapacke-dev libncurses5
sudo apt-get -y install libncurses5-dev libncurses5:i386 libncursesw5-dev libopenblas-dev libopencv-dev
sudo apt-get -y install libopenexr-dev libpng++-dev libpython3.8-dev libsdl1.2-dev libselinux1 libsm6:i386
sudo apt-get -y install libssl-dev libstdc++6:i386 libswscale-dev libtbb-dev libtiff5-dev libtinfo5 libtinfo6
sudo apt-get -y install libtool libv4l-dev libvtk6-qt-dev libwebp-dev libx11-6:i386 libxcb-randr0-dev
sudo apt-get -y install libxcb-shape0-dev libxcb-xinerama0-dev libxcb-xkb-dev libxcb-xtest0-dev libxext6:i386
sudo apt-get -y install libxine2-dev libxrender1:i386 make mtd-utils ncurses-dev net-tools ocl-icd-libopencl1
sudo apt-get -y install ocl-icd-opencl-dev opencl-headers openssh-server openssl pax perl pkg-config putty
sudo apt-get -y install pylint python2.7 python3 python3-dev python3-git python3-h5py python3-jinja2 python3-matplotlib
sudo apt-get -y install python3-numpy python3-opencv python3-pexpect python3-pip python3-scipy qt5-default qtbase5-dev
sudo apt-get -y install screen socat swig sysvinit-utils tar texinfo tftpd tofrodos unzip util-linux vim wget xinetd
sudo apt-get -y install xterm xtrans-dev xz-utils yasm zlib1g zlib1g-dev zlib1g:i386

## For Gstreamer
sudo apt -y install doxygen gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-libav
sudo apt -y install gstreamer1.0-plugins-bad gstreamer1.0-plugins-base gstreamer1.0-plugins-good
sudo apt -y install gstreamer1.0-plugins-ugly gstreamer1.0-pulseaudio gstreamer1.0-qt5 gstreamer1.0-tools
sudo apt -y install gstreamer1.0-x libatlas-base-dev libeigen3-dev libfaac-dev libgflags-dev
sudo apt -y install libgoogle-glog-dev libgphoto2-dev libgstreamer1.0-dev libgstreamer-plugins-base1dsf.0-dev
sudo apt -y install libgtk2.0-dev libhdf5-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev
sudo apt -y install libprotobuf-dev libtbb-dev libtheora-dev libvorbis-dev libxvidcore-dev protobuf-compiler
sudo apt -y install v4l-utils x264 


## For Cmake
sudo apt-get -y install libidn11 libidn11-dev

## For Network Env.
sudo apt-get -y install iperf3 alien netperf dkms ethtool

## For Etc.
sudo apt-get -y install gtkterm retext

## Install Chrome
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
cat << 'EOF' > ~/.vimrc
set number
set title
set tabstop=4
set cursorline
syntax on

highlight Comment ctermfg=Green
highlight Constant ctermfg=Red
highlight Identifier ctermfg=Cyan
highlight Statement ctermfg=Yellow
highlight Title ctermfg=Magenta
highlight Special ctermfg=Magenta
highlight PreProc ctermfg=Magenta
EOF

## Camera Library Setup
cd /usr/include/linux
sudo ln -s -f ../libv4l1-videodev.h videodev.h
cd ~

## Terminal Color Setup
cat << 'EOF' > ~/.colorrc
RESET 0
DIR 01;36
LINK 04;36
EOF

echo "" >> ~/.bashrc
echo "eval \`dircolors ~/.colorrc\`" >> ~/.bashrc

mv ~/.bashrc ~/.bashrc_org
sed -e 's/34m/36m/' ~/.bashrc_org > ~/.bashrc
source ~/.bashrc
