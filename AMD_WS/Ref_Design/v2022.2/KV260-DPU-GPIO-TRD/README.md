# KV260 DPU + GPIOデザイン
GPIOをKV260 DPUデザインから出す方法について。  
VIVADO/Vitis 2022.2 Petalinux 2022.2  
  
  
## 1.VivadoProjectを作成する  
```  
> mkdir step1_vivado  
```  
Create Projcet : prj  
Board : kv260 connector  
  
Create Block Designを押して、IPインテグレータを開始  
Add IPでMPSOCを呼び出してrun block automationでプリセットを呼び出す。  
  
MPSOCのウィザードを開いてAXI MasterをLPDのみチェックする。  
I/O configuration -> Low Speed I/O peripherals -> Under Processing Unit -> TTCでWaveoutをEMIOに設定する。  
他はデフォルト  
  
Add IPでClocking Wizardを呼び出して、100Mhz, 200MHz, 400MHz 25MHz、ResetType:ActiveLowを設定する  
Clocking Wizardのクロック、リセットをMPSOCと接続する。  
  
Add IPでProcessor System Reset_0を呼び出してslowest_sync_clockにclk_out1を、ext_reset_inにpl_reset0を接続する。  
Add IPでProcessor System Reset_1を呼び出してslowest_sync_clockにclk_out2を、ext_reset_inにpl_reset0を接続する。  
Add IPでProcessor System Reset_2を呼び出してslowest_sync_clockにclk_out3を、ext_reset_inにpl_reset0を接続する。  
Add IPでProcessor System Reset_3を呼び出してslowest_sync_clockにclk_out4を、ext_reset_inにpl_reset0を接続する。  
  
Add IPでAXI Interruptを呼び出して、Interrupt Output ConnectionをBusからSingleにする。 　
AXI Interruptをconnection automationを使って100Mhzのclk_out1に接続する。  
AXI Interruptのirq出力をpl-ps-irqに接続する。  
  
Platform Setup画面に移動して、AXI Portタブで下記をイネーブルにしてSPTAGを変更する。  
・M_AXI_HPM0_FPD,SPTAG変更なし  
・M_AXI_HPM1_FPD,SPTAG変更なし  
・S_AXI_HPC0_FPD,SPTAG HPC0  
・S_AXI_HPC1_FPD,SPTAG HPC1  
・S_AXI_HP0_FPD,SPTAG HP0  
・S_AXI_HP1_FPD,SPTAG HP1  
・S_AXI_HP2_FPD,SPTAG HP2  
・S_AXI_HP3_FPD,SPTAG HP3  
  
次に同じくAXI Portタブにて下記をイネーブルにする  
・M01_AXI 〜 M08_AXI  
  
Clockタブにてclk_out0~3にEnabledにチェックを入れてそれぞれIDを0123とし、clk_out2にisDefaultにチェックを入れる。  
InterruptタブにてintrにEnabledのチェックを入れる。  
Platform Setupは終了。  
  
Design FlowのSettingsを押して、  
Synthesisの項目でIncremental CompileをOFFする。  
Bitstreamの項目でbin_fileをチェック入れる。  
  
AXI GPIOブロックを呼び出して、GPIO Widthの数を8ビットにして、  
clk_out3系統にrun connection automationで接続する。  
  
GPIOの出力を外部端子として出して、端子名をpmodにする。  
  
Validate Designでチェックして問題なければ、HDL Wpapperを実施する。  
  
XDCファイルでピンを定義する。  
set_property PACKAGE_PIN H12 [get_ports pmod_tri_io[0]] ;# pmod_tri_io pin 1  
set_property PACKAGE_PIN B10 [get_ports pmod_tri_io[1]] ;# pmod_tri_io pin 2  
set_property PACKAGE_PIN E10 [get_ports pmod_tri_io[2]] ;# pmod_tri_io pin 3  
set_property PACKAGE_PIN E12 [get_ports pmod_tri_io[3]] ;# pmod_tri_io pin 4  
set_property PACKAGE_PIN D10 [get_ports pmod_tri_io[4]] ;# pmod_tri_io pin 5  
set_property PACKAGE_PIN D11 [get_ports pmod_tri_io[5]] ;# pmod_tri_io pin 6  
set_property PACKAGE_PIN C11 [get_ports pmod_tri_io[6]] ;# pmod_tri_io pin 7  
set_property PACKAGE_PIN B11 [get_ports pmod_tri_io[7]] ;# pmod_tri_io pin 8  
  
set_property IOSTANDARD  LVCMOS33 [get_ports "pmod_tri_io[0]"];  
set_property IOSTANDARD  LVCMOS33 [get_ports "pmod_tri_io[1]"];  
set_property IOSTANDARD  LVCMOS33 [get_ports "pmod_tri_io[2]"];  
set_property IOSTANDARD  LVCMOS33 [get_ports "pmod_tri_io[3]"];  
set_property IOSTANDARD  LVCMOS33 [get_ports "pmod_tri_io[4]"];  
set_property IOSTANDARD  LVCMOS33 [get_ports "pmod_tri_io[5]"];  
set_property IOSTANDARD  LVCMOS33 [get_ports "pmod_tri_io[6]"];  
set_property IOSTANDARD  LVCMOS33 [get_ports "pmod_tri_io[7]"];  
  
ビットストリームを作成し、Export Hardwareを実施してXSAファイルを作成する。  
  

## 2.DTC環境構築  
デバイスツリーを作成する  
ワークディレクトリを作成してそこでファイル生成を実施する。  
```  
mkdir step2_dtc  
cd step2_dtc  
source /mnt/EXTDSK/Xilinx/Vitis/2022.2/settings64.sh  
xsct #XSCTを起動する。  
createdts -hw ../step1_vivado/build/vivado/prj/system_wrapper.xsa -zocl -platform-name prj -git-branch xlnx_rel_v2022.2 -overlay -compile -out prj  
exit #XSCTを終了する。  
dtc -@ -O dtb -o prj.dtbo prj/prj/prj/psu_cortexa53_0/device_tree_domain/bsp/pl.dtsi  
```  
  

## 3.Petalinux環境構築  
[ここから](https://www.xilinx.com/member/forms/download/xef.html?filename=xilinx-kr260-starterkit-v2022.2-10141622.bsp)BSPをダウンロードする。  
  
プロジェクトを作成する。  
  
後ほど使用するのでワークスペースのルートディレクトリにVitisAIとDPU IPをダウンロードしておく。  
```  
git clone https://github.com/Xilinx/Vitis-AI.git -b v3.0  
  wget https://www.xilinx.com/bin/public/openDownload?filename=DPUCZDX8G.tar.gz -O DPUCZDX8G.tar.gz  
  
```
次にPetalinuxのワークディレクトリを作成して、ビルドを実施する。  
```  
mkdir step3_petalinux  
cd step3_petalinux  
petalinux-upgrade -u "http://petalinux.xilinx.com/sswreleases/rel-v2022/sdkupdate/2022.2"  
petalinux-create -t project -s xilinx-kv260-starterkit-v2022.2-10141622.bsp --name dpuOS  
cd dpuOS  
petalinux-config --get-hw-description=../../step1_vivado/project_1/  
```  
  
Petalinux-conigで下記を設定する  
・Enable FPGA Manager under FPGA Manager.  
・Disable Copy final images to tftpboot  
終了したらセーブを実施。  
  
```  
petalinux-config -c kernel  
```
Kernel設定では下記を設定する  
Device Drivers --> Misc devices --> <*> Xilinux Deep learning Processing Unit (DPU) Driver  
終了したらセーブを実施。  
  
次にRootfsの準備を実施する。  
先ほどダウンロードしたVitis-AIのディレクトリから必要なファイルをコピーする。(下記は例)  
```  
cd project-spec/meta-user  
cp ../../../Vitis-AI/src/vai_petalinux_recipes/recipes-vitis-ai . -r  
rm resipes-vitis-ai/vart/vart_3.0_vivado.bb  
  
```  
user-rootfsconfigを編集してVitis AI Libraryのインストール準備を実施する。  
```  
vim conf/user-rootfsconfig  
```  
このファイルの末尾に下記を追加する  
```  
CONFIG_vitis-ai-library  
CONFIG_vitis-ai-library-dev  
CONFIG_vitis-ai-library-dbg  
```  
rootfsの設定を実施する。  
```  
petalinux-config -c rootfs  
```  
rootfsの設定は下記。  
vitis-ai-libraryを選択  
packagegroup -> gstreamer,opencv,pythonmodules,self-hosted,v4lutils,vitis-acceleration,x11  
Filesystem Packages -> misc gcc-runtime  
Filesystem Packages -> libs -> xrt,zocl  
Filesystem Packages -> base -> dnf  
  
PetalinuxのビルドとSDカードイメージの作成  
```
petalinux-build  

petalinux-package --wic --images-dir images/linux/ --bootfiles "ramdisk.cpio.gz.u-boot,boot.scr,Image,system.dtb,system-zynqmp-sck-kv-g-revB.dtb" --disk-name "mmcblk1"
  
```
WicをSDカードに書き込む  
Petalinux SDKを展開する。  
```  
petalinux-build --sdk  
cd images/linux  
./sdk.sh  
```  
  
## 4.VitisによるDPU構築  
cd ../../  
mkdir step4_pfm  
cd step4_pfm  
mkdir boot sd_dir  
cd ../  
vitis -workspace ./step4_pfm  
  
## 5.Package  
cd ../  
mkdir step5_package  
cd step5_package  
cp ../step2_dtc/kr260.dtbo .  
echo '{ "shell_type" : "XRT_FLAT", "num_slots": "1" }' > shell.json  
  
## 6.Run  
cd ../  
scp -r ./step4_package petalinux@192.168.11.44:~/.  
  
KR260側で  
mv step4_package kr260  
sudo mv kr260 /lib/firmware/xilinx/.  
sudo xmutil listapps  
sudo xmutil unloadapp  
sudo xmutil loadapp kr260  
  
システムで使用可能な GPIOを確認  
cd /sys/class/gpio/  
ls  
  
gppi​​ochip のラベルを印刷して、それが何に関連しているのかを確認します。  
cat .//label  
  
出力は、Vivado ブロック デザイン アドレス エディターからの AXI GPIO のアドレスに関連している必要があります。  
たとえば、gpiochip492 のラベル80010000は、この設計で GPIO ブロックに割り当てられたアドレスです。  
最初のピンの方向をエクスポートして設定します  
  
echo 492 | sudo tee ./export  
echo out | sudo tee ./gpio492/direction  
○ 必要に応じて他のピンについても同じ操作を行い、次のピンごとに番号を 1 ずつ増やします。  
GPIO制御: ピンへの書き込み  
○ 次のコマンドを実行してピンをHIGHに設定します  
echo 1 | sudo tee ./gpio492/value  
以下のコマンドを実行してピンをLOWに設定します  
echo 0 | sudo tee ./gpio492/value  
  
echo 493 | sudo tee ./export  
echo out | sudo tee ./gpio493/direction  