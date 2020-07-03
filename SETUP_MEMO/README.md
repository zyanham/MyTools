### Ubuntu18.04LTS設定メモ  
##### ■ スクリーンのブランク設定を外しておくと良い。  
設定→電源管理→ブランクスクリーン→しない  
  
##### ■デスクトップのディレクトリ類がが日本語だった場合英語に戻すコマンド。  
LANG=en_US.utf8 xdg-user-dirs-gtk-update  
sudo reboot  
  
##### ■ターミナルにフルパスではなくカレントディレクトリのみ表示するには  
.bashrcのPS1に表記されている\Wを大文字Wにする。  
  
##### ■apt-getのアップデート  
パッケージインストールツールapt-getのパッケージ一覧のアップデートを実施。  
sudo add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"  
sudo apt-get update  
  
##### インストール済みパッケージのインストールを実施する  
sudo apt-get upgrade  
  
##### ■ いろいろインストールしておく  
sudo apt-get -y install imagemagick vim git dos2unix iproute2 gawk make net-tools libncurses5-dev tftpd zlib1g libssl-dev flex bison libselinux1 gnupg wget diffstat socat xterm autoconf libtool tar unzip texinfo zlib1g-dev gcc-multilib build-essential screen pax gzip python2.7 zlib1g:i386 chrpath opencl-headers cmake libeigen3-dev libgtk-3-dev qt5-default freeglut3-dev libvtk6-qt-dev libtbb-dev ffmpeg libdc1394-22-dev libavcodec-dev libavformat-dev libswscale-dev libjpeg-dev libpng++-dev libtiff5-dev libopenexr-dev libwebp-dev libhdf5-dev libpython3.8-dev python3 python3-numpy python3-scipy python3-matplotlib libopenblas-dev liblapacke-dev python3-pip python3-dev pkg-config python-h5py ipython graphviz python-opencv cmake-qt-gui qtbase5-dev libopencv-dev docker docker.io libeigen3-dev cython cython3 libcublas9.1 curl  
  
sudo apt -y install libjasper1 yasm libxine2-dev libv4l-dev swig  
cd /usr/include/linux  
sudo ln -s -f ../libv4l1-videodev.h videodev.h  
cd "$cwd"  
  
sudo apt -y install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgtk2.0-dev libtbb-dev qt5-default libatlas-base-dev libfaac-dev libmp3lame-dev libtheora-dev libvorbis-dev libxvidcore-dev libopencore-amrnb-dev libopencore-amrwb-dev libavresample-dev x264 v4l-utils  
  
sudo apt -y install libprotobuf-dev protobuf-compiler libgoogle-glog-dev libgflags-dev libgphoto2-dev libeigen3-dev libhdf5-dev doxygen  
  
pip3 install opencv-python  
pip3 install pydot-ng  
pip3 install slidingwindow  
pip3 install -U scipy  
sudo -H pip3 install -U pip numpy  
sudo apt -y install python3-testresources  
  
##### vimは .vimrcを編集したほうがいいよ。  
　　set number  
　　set cusorline  
  
##### emacsの場合はVerilog-modeも構築してくれると嬉しい。  
  
##### ■ コーデックを入れるためGstreamerをインストールしよう  
https://gstreamer.freedesktop.org/documentation/installing/on-linux.html?gi-language=c  

### Ubuntu18 基本設定メモ
##### ユーザーを作成する
```
adduser <user name>
```

##### sudoグループにユーザを追加する
```
gpasswd -a <user name> sudo
```

##### ユーザーを削除する
```
userdel -r <user name>
```
##### ユーザーを確認する
```
cat /etc/passwd
```
