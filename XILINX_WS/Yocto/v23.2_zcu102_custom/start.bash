repo init -u https://github.com/Xilinx/yocto-manifests.git -b rel-v2023.2
repo sync
repo start rel-v2023.2 --all
source setupsdk

bitbake-layers create-layer $ROOT/sources/meta-example

mkdir -p $ROOT/sources/meta-example/conf/machine
mkdir -p $ROOT/sources/meta-example/recipes-kernel/linux-xlnx
mkdir -p $ROOT/sources/meta-example/recipes-bsp/u-boot/u-boot-xlnx
mkdir -p $ROOT/sources/meta-example/recipes-bsp/device-tree/files

bitbake-layers add-layer $ROOT/sources/meta-example

echo "require conf/machine/zcu102-zynqmp.conf" > $ROOT/sources/meta-example/conf/machine/example-zcu102-zynqmp.conf
echo 'HDF_BASE = "file://"' >> $ROOT/sources/meta-example/conf/machine/example-zcu102-zynqmp.conf
echo 'HDF_PATH = "./zcu102_custom/zcu102_custom.xpr"' >> $ROOT/sources/meta-example/conf/machine/example-zcu102-zynqmp.conf

cat << EOF > ../sources/meta-example/recipes-bsp/device-tree/device-tree.bbappend
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"   
 
SYSTEM_USER_DTSI ?= "system-user.dtsi"
 
SRC_URI:append = " file://${SYSTEM_USER_DTSI}"
 
do_configure:append() {
  cp ${WORKDIR}/${SYSTEM_USER_DTSI} ${B}/device-tree
  echo "/include/ \"${SYSTEM_USER_DTSI}\"" >> ${B}/device-tree/system-top.dts
}
EOF

cat << EOF > ../sources/meta-example/recipes-bsp/device-tree/files/system-user.dtsi
/ {
    chosen {
	bootargs = "earlycon clk_ignore_unused   uio_pdrv_genirq.of_id=generic-uio";
	stdout-path = "serial0:115200n8";
    };
};

&axi_gpio_0 {
    compatible = "generic-uio";　　<<== axi_gpio に対してUIOドライバを指定する
};
EOF

MACHINE=example-zcu102-zynqmp bitbake petalinux-image-minimal


