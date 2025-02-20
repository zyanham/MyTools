git clone -b kirkstone https://github.com/yoctoproject/poky.git

## ENV Setting
source poky/oe-init-build-env

## get meta-raspberrypi
bitbake-layers layerindex-fetch meta-raspberrypi

## Raspberry Pi Zero2 W Setting
vim conf/local.conf
  => MACIHNE = "raspberrypi0-2w-64"

bitbake core-image-base
cd tmp/deploy/images/raspberrypi0-2w-64
sudo apt install bmap-tools

