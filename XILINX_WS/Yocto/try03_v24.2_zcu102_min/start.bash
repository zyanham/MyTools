repo init -u https://github.com/Xilinx/yocto-manifests.git -b rel-v2024.2
repo sync
repo start rel-v2024.2 --all
source setupsdk
echo 'IMAGE_FSTYPES:append=" wic"' >> conf/local.conf
MACHINE=zcu102-zynqmp bitbake petalinux-image-minimal
