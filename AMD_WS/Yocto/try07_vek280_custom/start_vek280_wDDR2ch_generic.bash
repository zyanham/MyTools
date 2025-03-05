## v2024.2
repo init -u https://github.com/Xilinx/yocto-manifests.git -b rel-v2024.2
repo sync
repo start rel-v2024.2 -all

source setupsdk vek280_wDDR2ch-generic

sed -i "/MACHINE ??=/c\MACHINE ??= \"versal-generic\"" conf/local.conf
echo 'IMAGE_FSTYPES += "wic"' >>  conf/local.conf
#echo 'require conf/machine/vek280-versal.conf' >> conf/local.conf
echo 'require conf/machine/versal-generic.conf' >> conf/local.conf
echo 'HDF_BASE = "file://"' >> conf/local.conf
echo 'HDF_PATH = "$ROOT/vek280_wDDR2ch/system_wrapper.xsa"' >> conf/local.conf

bitbake petalinux-image-minimal
