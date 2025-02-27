repo init -u https://github.com/Xilinx/yocto-manifests.git -b rel-v2024.2
repo sync
repo start rel-v2024.2 --all
source setupsdk
echo 'IMAGE_FSTYPES:append=" wic"' >> conf/local.conf
echo 'IMAGE_FEATURES += " package-management "' >> conf/local.conf
echo 'PACKAGE_CLASSES ?= " package_rpm "' >> conf/local.conf
MACHINE=vek280-versal bitbake petalinux-image-minimal
