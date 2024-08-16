  
https://xilinx.github.io/Vitis-AI/3.0/html/docs/workflow-system-integration.html#vitis-ai-dpu-ip-and-reference-designs  
wget https://www.xilinx.com/bin/public/openDownload?filename=DPUCZDX8G.tar.gz -O DPUCZDX8G.tar.gz  
  
<DTC>  
source /mnt/EXTDSK/Xilinx/Vitis/2022.2/settings64.sh  
xsct  
createdts -hw ../step1_vivado/build/vivado/prj/system_wrapper.xsa -zocl -platform-name prj -git-branch xlnx_rel_v2022.2 -overlay -compile -out prj  
  
dtc -@ -O dtb -o prj.dtbo prj/prj/prj/psu_cortexa53_0/device_tree_domain/bsp/pl.dtsi  
  
<Petalinux>  
petalinux-upgrade -u "http://petalinux.xilinx.com/sswreleases/rel-v2022/sdkupdate/2022.2"  
petalinux-create -t project -s xilinx-kv260-starterkit-v2022.2-10141622.bsp --name dpuOS  
cd dpuOS  
petalinux-config --get-hw-description=../../step1_vivado/build/vivado/prj/  
FPGA Manager-> FPGA Manager -> enable
Image Packaging Configuration -> Copy final images to tftpboot -> disable  
EXIT  
  
petalinux-config -c kernel  
Device Drivers --> Misc devices --> <*> Xilinux Deep learning Processing Unit (DPU) Driver   
EXIT  
  
cd project-spec/meta-user  
  
git clone https://github.com/Xilinx/Vitis-AI.git -b v3.0  
cp ../../../Vitis-AI/src/vai_petalinux_recipes/recipes-vitis-ai . -r  
  
rm resipes-vitis-ai/vart/vart_3.0_vivado.bb  
  
vim conf/user-rootfsconfig  
CONFIG_vitis-ai-library  
CONFIG_vitis-ai-library-dev  
CONFIG_vitis-ai-library-dbg  
  
petalinux-config -c rootfs  
  
vitis-ai-library-*を全選択  
packagegroup -> gstreamer,opencv,pythonmodules,self-hosted,v4lutils,vitis-acceleration,x11  
Filesystem Packages -> misc gcc-runtime  
Filesystem Packages -> libs -> xrt,zocl  
Filesystem Packages -> base -> dnf  
  
petalinux-build  
petalinux-package --boot --u-boot --force  
petalinux-package --wic --images-dir images/linux/ --bootfiles "ramdisk.cpio.gz.u-boot,boot.scr,Image,system.dtb,system-zynqmp-sck-kv-g-revB.dtb" --disk-name "mmcblk1"  
  
petalinux-build --sdk  
cd images/linux  
./sdk.sh  
  
cd ../../  
mkdir step4_pfm  
cd step4_pfm  
mkdir boot sd_dir  
cd ../  
vitis -workspace ./step4_pfm  
  
ls  

