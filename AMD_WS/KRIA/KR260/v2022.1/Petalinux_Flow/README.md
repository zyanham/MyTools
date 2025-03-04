KR260 v2022.1 Vivado - Petalinux Flow   

KR260 Setting  

Refer to  
[Getting Started with the Kria KR260 in Vivado 2022.1](https://www.hackster.io/whitney-knitter/getting-started-with-the-kria-kr260-in-vivado-2022-1-33746d)  
[Getting Started with the Kria KR260 in PetaLinux 2022.1](https://www.hackster.io/whitney-knitter/getting-started-with-the-kria-kr260-in-petalinux-2022-1-daec16)  

step1 tuning..  
step2 never  
step3 never  

for Petalinux build  
sudo apt-get remove libtcl8.6  
sudo apt-get update  
sudo apt-get install blt libopencv-contrib-dev libopencv-dev libopencv-viz-dev libopencv-viz4.5d libtcl8.6  

'''
source /opt/PetaLinux_2022.1/settings.sh  

# And upgrade the PetaLinux eSDK with Update1
petalinux-upgrade -u http://petalinux.xilinx.com/sswreleases/rel-v2022/sdkupdate/2022.1_update1/ -p "aarch64" --wget-args "--wait 1 -nH --cut-dirs=4"  

# BSP
petalinux-create --type project -s ./xilinx-kr260-starterkit-v2022.1-05140151.bsp --name linux_os  
  
cd linux_os  
petalinux-config --get-hw-description ../  
  
FPGA Manager --> Fpga Manager[*]  
Image Packaging Configuration --> Root Filesystem Type --> INITRD[*]  
Image Packaging Configuration --> INITRAMFS/INITRD Image name --> petalinux-initramfs-image  
Image Packaging Configuration --> Copy final images to tftpboot[]  
  
petalinux-config -c kernel  
petalinux-config -c rootfs  
Filesystem Packages -> base -> dnf -> dnf  
Filesystem Packages -> x11 -> base -> libdrm -> libdrm  
Filesystem Packages -> x11 -> base -> libdrm -> libdrm-tests  
Filesystem Packages -> x11 -> base -> libdrm -> libdrm-kms  
Filesystem Packages -> libs -> xrt -> xrt  
Filesystem Packages -> libs -> xrt -> xrt-dev  
Filesystem Packages -> libs -> zocl -> zocl  
Filesystem Packages -> libs -> opencl-headers -> opencl-headers  
Filesystem Packages -> libs -> opencl-clhpp -> opencl-clhpp-dev  
Petaliunx Package Groups -> packagegroup-petalinux -> packagegroup-petalinux  
Petaliunx Package Groups -> packagegroup-petalinux-gstreamer -> packagegroup-petalinux-gstreamer  
  
petalinux-build  
petalinux-build --sdk  
  
petalinux-package --boot --u-boot --force  
petalinux-package --wic --images-dir images/linux/ --bootfiles "ramdisk.cpio.gz.u-boot,boot.scr,Image,system.dtb,system-zynqmp-sck-kr-g-revB.dtb" --disk-name "sda"  
  
#petalinux build file remove  
petalinux-build -x mrproper  

'''
