## ■ DPUTRDを構築する(VAI3.0 VivadoFlow＋ZCU102)  
Vivado 2022.2  
Petalinux 2022.2  

基本的にはDPUのリファレンスをダウンロードしてビルド実行するだけ  
> bash setup_3.0.bash  
これで、DPU_TRDディレクトリが作成され、Vivadoが立ち上がってimpl15を実行するだけで  
HW構成は構築可能  
  
## ■ DPUTRDを構築する(VAI3.0 VivadoFlow＋KV260)  
Vivado 2022.2  
Petalinux 2022.2  

基本的にはZCU102のDPUのリファレンスをダウンロードしてビルド実行するだけだが少しカスタムが必要  
> bash setup_3.0.bash KV260  
これで、DPU_TRD_KV260ディレクトリが作成される。tclを実行する前にカスタムが必要。  
下記に示す  

[これを参考に](https://www.hackster.io/shreyasnr/kv260-dpu-trd-petalinux-2022-1-vivado-flow-000c0b)構築  

> cd DPU_TRD_KV260/prj/Vivado/hw/scripts/  
> vim trd_prj.tcl
###trd_prj.tcl, base/tcl_bd.tclを編集する  
DPU ARCH ... B512, B800, B1024, B1152, B1600, B2304, B3136, B4096  
[参考](https://docs.xilinx.com/r/en-US/pg338-dpu?tocId=3xsG16y_QFTWvAJKHbisEw)  

```  
dict set dict_prj dict_sys prj_name                  {KV260}  
dict set dict_prj dict_sys prj_part                  {xck26-sfvc784-2LV-c}  
dict set dict_prj dict_sys prj_board                 {KV260}  
dict set dict_prj dict_param  DPU_CLK_MHz            {275}  
dict set dict_prj dict_param  DPU_NUM                {1}  
dict set dict_prj dict_param  DPU_ARCH               {1024}  
dict set dict_prj dict_param  DPU_SFM_NUM            {0}  
dict set dict_prj dict_param  DPU_URAM_PER_DPU       {50}  
```  
  
> vim base/trd_bd.tcl  

```  
dict set dict_prj dict_param HP_CLK_MHz        {274}  
```  
  
> vivado -source trd_prj.tcl  
  
Settingsを開いて、Project Device->Vision AI Starter Kit選択  
Bitstreamタブの-bin_fileチェックする  
Report IP Statusを開いて、IPをアップデートする  
Generate Bitstreamでビットストリームを生成  
Export HardwareでXSAファイルを作成  
  
> cd ../../sw  
  
bspをダウンロードして配置  
> petalinux-create -t project -s ./xilinx-kv260-starterkit-v2022.2-10141622.bsp --name dpuOS  
> cd dpuOS  
> petalinux-config --get-hw-description=../../hw/prj/  4. In the configuration screen 
  
FPGA Manager-> FPGA Manager [enable]  
Image Packaging Configuration -> Copy final images to tftpboot [disable]  
EXIT  
  
> petalinux-config -c kernel  
Device Drivers --> Misc devices --> <*> Xilinux Deep learning Processing Unit (DPU) Driver  
EXIT  
  
cd project-spec/meta-user  
cp -r ../../../../../../../meta-user/* .  
  
vim conf/user-rootfsconfig  
  
```  
CONFIG_vitis-ai-library  
CONFIG_vitis-ai-library-dev  
CONFIG_vitis-ai-library-dbg  
```  
  
> vim conf/petalinuxbsp.conf  
  
```  
IMAGE_INSTALL:append = " vitis-ai-library "  
IMAGE_INSTALL:append = " vitis-ai-library-dev "  
IMAGE_INSTALL:append = " resnet50 "  
```  
  
> petalinux-config -c rootfs  

vitis-ai-library-dbgは選択しない
  
> cd ../../  
> petalinux-build  
  
> petalinux-package --wic --images-dir images/linux/ --bootfiles "ramdisk.cpio.gz.u-boot,boot.scr,Image,system.dtb,system-zynqmp-sck-kv-g-revB.dtb" --disk-name "mmcblk1" --wic-extra-args "-c gzip"  
  
> cd ../../  
> mkdir kv260_prj  
> cd kv260_prj  
> xsct  
> createdts -hw ../hw/prj/top_wrapper.xsa -zocl -platform-name KV260 -git-branch  xlnx_rel_v2022.2 -overlay -compile -out ./kv260_dt  
> exit  
> mkdir kv260_b1024  
> dtc -@ -O dtb -o ./kv260_b1024/kv260.dtbo ./kv260_dt/kv260_dt/KV260/psu_cortexa53_0/device_tree_domain/bsp/pl.dtsi  
> echo '{ "shell_type" : "XRT_FLAT", "num_slots": "1" }' > kv260_b1024/shell.json  
> cp ../hw/prj/top_wrapper.bit kv260_b1024/kv260.bit.bin  
  
