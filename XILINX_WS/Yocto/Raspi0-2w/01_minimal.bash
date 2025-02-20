## Install For Yocto Project
sudo apt install -y gawk wget git diffstat unzip texinfo gcc build-essential chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev pylint xterm python3-subunit mesa-common-dev zstd liblz4-tool make python3-pip

sudo pip3 install sphinx sphinx_rtd_theme pyyaml

git clone -b kirkstone https://github.com/yoctoproject/poky.git

## ENV Setting
source poky/oe-init-build-env

## get meta-raspberrypi
bitbake-layers layerindex-fetch meta-raspberrypi

## Raspberry Pi Zero2 W Setting
vim conf/local.conf
  => MACIHNE = "raspberrypi0-2w-64"

bitbake core-image-minimal
cd tmp/deploy/images/raspberrypi0-2w-64
sudo apt install bmap-tools


