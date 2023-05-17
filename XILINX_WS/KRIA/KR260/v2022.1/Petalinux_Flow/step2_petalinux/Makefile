# Copyright 2020 Xilinx Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ROOT_DIR=$(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ABS_BUILD_PATH=$(ROOT_DIR)/build
PETALINUX_PROJ_NAME=petalinux
ABS_SW_PATH=$(ABS_BUILD_PATH)/$(PETALINUX_PROJ_NAME)
PETALINUX_DIR=$(ABS_SW_PATH)
BD_TCL=system_step0.tcl
ABS_BD_TCL=$(ROOT_DIR)/$(BD_TCL)
PETALINUX_CONFIG=$(PETALINUX_DIR)/project-spec/configs/config
PETALINUX_ROOTFS_CONFIG=$(PETALINUX_DIR)/project-spec/configs/rootfs_config
PETALINUX_KERNEL_CONFIG=$(PETALINUX_DIR)/project-spec/meta-user/recipes-kernel/linux/linux-xlnx/bsp.cfg
DEVICE_TREE_PATCH_PATH=$(PETALINUX_DIR)/project-spec/meta-user/recipes-bsp/device-tree/device-tree.bbappend

.PHONY: all get_xsa petalinux clean main

all: get_xsa petalinux_proj petalinux_build petalinux_build_sdk
main: get_xsa petalinux_proj petalinux_build

get_xsa:
	cd $(ROOT_DIR); cp ../step1_vivado/build/vivado/*.xsa .


update_dtsi:
	@cp -f system-user.dtsi $(PETALINUX_DIR)/project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi

update_config:
## ORIGINAL
#	# PetaLinux Config: Use EXT4 as rootfs format
#	echo "CONFIG_SUBSYSTEM_ROOTFS_EXT4=y" >> $(PETALINUX_CONFIG)
#	# PetaLinux Config: Use ZCU104 device tree
#	echo 'CONFIG_SUBSYSTEM_MACHINE_NAME="zcu104-revc"' >> $(PETALINUX_CONFIG)
#	echo 'CONFIG_YOCTO_MACHINE_NAME="zcu104-zynqmp"' >> $(PETALINUX_CONFIG)
#	# For GCC < 6.0, enable prebuilt build tools
#	echo "CONFIG_YOCTO_BUILDTOOLS_EXTENDED=y" >> $(PETALINUX_CONFIG)

## FOR U96V2
	echo "CONFIG_SUBSYSTEM_PMUFW_SERIAL_PSU_UART_1_SELECT=y" >> $(PETALINUX_CONFIG)
	echo "CONFIG_SUBSYSTEM_FSBL_SERIAL_PSU_UART_1_SELECT=y" >> $(PETALINUX_CONFIG)
	echo "CONFIG_SUBSYSTEM_ATF_SERIAL_PSU_UART_1_SELECT=y" >> $(PETALINUX_CONFIG)
	echo "CONFIG_SUBSYSTEM_SERIAL_PSU_UART_1_SELECT=y" >> $(PETALINUX_CONFIG)
	echo 'CONFIG_SUBSYSTEM_SERIAL_PMUFW_IP_NAME="psu_uart_1"' >> $(PETALINUX_CONFIG)
	echo 'CONFIG_SUBSYSTEM_SERIAL_FSBL_IP_NAME="psu_uart_1"' >> $(PETALINUX_CONFIG)
	echo 'CONFIG_SUBSYSTEM_SERIAL_ATF_IP_NAME="cadence1"' >> $(PETALINUX_CONFIG)
	echo 'CONFIG_SUBSYSTEM_SERIAL_IP_NAME="psu_uart_1"' >> $(PETALINUX_CONFIG)
	echo 'CONFIG_SUBSYSTEM_MACHINE_NAME="avnet-ultra96-rev1"' >> $(PETALINUX_CONFIG)
	echo 'CONFIG_SUBSYSTEM_HOSTNAME="u96v2_custom_plnx"' >> $(PETALINUX_CONFIG)
	echo 'CONFIG_SUBSYSTEM_PRODUCT="u96v2_custom_plnx"' >> $(PETALINUX_CONFIG)
	echo 'CONFIG_YOCTO_MACHINE_NAME="zynqmp-generic"' >> $(PETALINUX_CONFIG)
	sed -i -e "s/CONFIG_SUBSYSTEM_BOOTARGS_AUTO=y/\# CONFIG_SUBSYSTEM_BOOTARGS_AUTO is not set/" $(PETALINUX_CONFIG)
	sed -i -e "s/CONFIG_SUBSYSTEM_BOOTARGS_EARLYPRINTK=y/\# CONFIG_SUBSYSTEM_BOOTARGS_EARLYPRINTK is not set /" $(PETALINUX_CONFIG)
	echo 'CONFIG_SUBSYSTEM_USER_CMDLINE="earlycon console=ttyPS0,115200 clk_ignore_unused root=/dev/mmcblk0p2 rw rootwait cma=512M"' >> $(PETALINUX_CONFIG)
	sed -i -e "s/CONFIG_SUBSYSTEM_ROOTFS_INITRD=y/\# CONFIG_SUBSYSTEM_ROOTFS_INITRD is not set/" $(PETALINUX_CONFIG)
	echo "CONFIG_SUBSYSTEM_ROOTFS_EXT4=y" >> $(PETALINUX_CONFIG) 
	sed -i -e "s/CONFIG_SUBSYSTEM_INITRD_RAMDISK_LOADADDR=0x0/\# CONFIG_SUBSYSTEM_INITRD_RAMDISK_LOADADDR is not set/" $(PETALINUX_CONFIG)
	sed -i -e 's/CONFIG_SUBSYSTEM_INITRAMFS_IMAGE_NAME="petalinux-initramfs-image"/\#CONFIG_SUBSYSTEM_INITRAMFS_IMAGE_NAME= is not set/' $(PETALINUX_CONFIG)
	echo 'CONFIG_SUBSYSTEM_SDROOT_DEV="/dev/mmcblk0p2"' >> $(PETALINUX_CONFIG)
	sed -i -e 's/CONFIG_SUBSYSTEM_BOOTARGS_GENERATED=" earlycon console=ttyPS0,115200 clk_ignore_unused init_fatal_sh=1"//' $(PETALINUX_CONFIG)


update_rootfs_config:
## ORIGINAL
#	# PetaLinux Rootfs: Enable XRT
#	echo 'CONFIG_xrt=y' >> $(PETALINUX_ROOTFS_CONFIG)
#	# echo 'CONFIG_xrt-dev=y' >> $(PETALINUX_ROOTFS_CONFIG)
#	# PetaLinux Rootfs: Enable DNF
#	echo 'CONFIG_dnf=y' >> $(PETALINUX_ROOTFS_CONFIG)
#	echo 'CONFIG_imagefeature-package-management=y' >> $(PETALINUX_ROOTFS_CONFIG)
#	# PetaLinux Rootfs: Enable packages for EoU
#	echo 'CONFIG_e2fsprogs-resize2fs=y' >> $(PETALINUX_ROOTFS_CONFIG)
#	echo 'CONFIG_parted=y' >> $(PETALINUX_ROOTFS_CONFIG)
#	echo 'CONFIG_resize-part=y' >> $(PETALINUX_ROOTFS_CONFIG)
#	# PetaLinux Rootfs: Enable Vitis AI demo dependencies
#	echo 'CONFIG_packagegroup-petalinux-opencv=y' >> $(PETALINUX_ROOTFS_CONFIG)
#	echo 'CONFIG_mesa-megadriver=y' >> $(PETALINUX_ROOTFS_CONFIG)
#	echo 'CONFIG_packagegroup-petalinux-x11=y' >> $(PETALINUX_ROOTFS_CONFIG)
#	echo 'CONFIG_packagegroup-petalinux-v4lutils=y' >> $(PETALINUX_ROOTFS_CONFIG)
#	echo 'CONFIG_packagegroup-petalinux-matchbox=y' >> $(PETALINUX_ROOTFS_CONFIG)

## FOR U96V2
	echo "CONFIG_dnf=y" >> $(PETALINUX_ROOTFS_CONFIG)
	echo "CONFIG_e2fsprogs-resize2fs=y" >> $(PETALINUX_ROOTFS_CONFIG)
	echo "CONFIG_openssh=y" >> $(PETALINUX_ROOTFS_CONFIG)
	echo "CONFIG_openssh-sshd=y" >> $(PETALINUX_ROOTFS_CONFIG)
	echo "CONFIG_openssh-scp=y" >> $(PETALINUX_ROOTFS_CONFIG)
	echo "CONFIG_parted=y" >> $(PETALINUX_ROOTFS_CONFIG)
	echo "CONFIG_xrt=y" >> $(PETALINUX_ROOTFS_CONFIG)
	echo "CONFIG_xrt-dev=y" >> $(PETALINUX_ROOTFS_CONFIG)
	echo "CONFIG_zocl=y" >> $(PETALINUX_ROOTFS_CONFIG)
	echo "CONFIG_mesa-megadriver=y" >> $(PETALINUX_ROOTFS_CONFIG)
	echo "CONFIG_resize-part=y" >> $(PETALINUX_ROOTFS_CONFIG)
	echo "CONFIG_packagegroup-petalinux-matchbox=y" >> $(PETALINUX_ROOTFS_CONFIG)
	echo "CONFIG_packagegroup-petalinux-opencv=y" >> $(PETALINUX_ROOTFS_CONFIG)
	echo "CONFIG_packagegroup-petalinux-opencv-dev=y" >> $(PETALINUX_ROOTFS_CONFIG)
	echo "CONFIG_packagegroup-petalinux-self-hosted=y" >> $(PETALINUX_ROOTFS_CONFIG)
	echo "CONFIG_packagegroup-petalinux-v4lutils=y" >> $(PETALINUX_ROOTFS_CONFIG)
	echo "CONFIG_packagegroup-petalinux-x11=y" >> $(PETALINUX_ROOTFS_CONFIG)
	echo "CONFIG_imagefeature-ssh-server-openssh=y" >> $(PETALINUX_ROOTFS_CONFIG)
	echo "CONFIG_imagefeature-package-management=y" >> $(PETALINUX_ROOTFS_CONFIG)
	echo "CONFIG_opencl-clhpp-dev=y" >> $(PETALINUX_ROOTFS_CONFIG)
	
	sed -i -e 's/CONFIG_packagegroup-core-ssh-dropbear=y/\# CONFIG_packagegroup-core-ssh-dropbear is not set/' $(PETALINUX_ROOTFS_CONFIG)
	sed -i -e 's/CONFIG_imagefeature-ssh-server-dropbear=y/\# CONFIG_imagefeature-ssh-server-dropbear in not set/' $(PETALINUX_ROOTFS_CONFIG)

update_kernel_config:

	echo "# CONFIG_CPU_IDLE is not set" >> $(PETALINUX_KERNEL_CONFIG)
	echo "# CONFIG_CPU_FREQ is not set" >> $(PETALINUX_KERNEL_CONFIG)
	echo "CONFIG_EDAC_CORTEX_ARM64=y" >> $(PETALINUX_KERNEL_CONFIG)
	echo "CONFIG_CMA_SIZE_MBYTES=1024" >> $(PETALINUX_KERNEL_CONFIG)

update_kernel_define:

#	echo 'SRC_URI += "file://bsp.cfg"' >> $(PETALINUX_KERNEL_DEFINE)
#	echo 'KERNEL_FEATURES_append = " bsp.cfg"' >> $(PETALINUX_KERNEL_DEFINE)
#	echo 'FILESEXTRAPATHS_prepend := "\${THISDIR}/\${PN}:"' >> $(PETALINUX_KERNEL_DEFINE)
	cp $(ROOT_DIR)/linux-xlnx_\%.bbappend $(PETALINUX_DIR)/project-spec/meta-user/recipes-kernel/linux


petalinux_proj:
	mkdir -p $(ABS_BUILD_PATH);cd $(ABS_BUILD_PATH); petalinux-create -t project --template zynqMP --force -n $(PETALINUX_PROJ_NAME)
	$(MAKE) -f $(lastword $(MAKEFILE_LIST)) update_config
	petalinux-config -p $(PETALINUX_DIR) --get-hw-description=$(ROOT_DIR) --silentconfig
	mkdir -p $(PETALINUX_DIR)/project-spec/meta-user/recipes-kernel/linux/linux-xlnx

	#################
	# v2021.1 PATCH #
	#################
	cp $(ROOT_DIR)/0001-kernel-v2021.1-Sync-the-psgtr-node-from-U-boot.patch $(PETALINUX_DIR)/project-spec/meta-user/recipes-bsp/device-tree/files
	sed -i -e 's/SRC_URI_append = " file:\/\/config file:\/\/system-user.dtsi"/SRC_URI_append = " file:\/\/config file:\/\/system-user.dtsi file:\/\/0001-kernel-v2021.1-Sync-the-psgtr-node-from-U-boot.patch"/' $(DEVICE_TREE_PATCH_PATH)

	$(MAKE) -f $(lastword $(MAKEFILE_LIST)) update_kernel_config
	$(MAKE) -f $(lastword $(MAKEFILE_LIST)) update_kernel_define
	$(MAKE) -f $(lastword $(MAKEFILE_LIST)) update_rootfs_config
	$(MAKE) -f $(lastword $(MAKEFILE_LIST)) update_dtsi
	petalinux-config -p $(PETALINUX_DIR) --silentconfig

petalinux_build:
	petalinux-build -p $(PETALINUX_DIR)
	cd $(PETALINUX_DIR) && petalinux-package --boot --u-boot

petalinux_build_sdk:
	petalinux-build -p $(PETALINUX_DIR) --sdk
	cd $(PETALINUX_DIR) && petalinux-package --sysroot

clean:
	$(RM) -r $(ABS_BUILD_PATH) vivado*.log vivado*.jou *.xsa
