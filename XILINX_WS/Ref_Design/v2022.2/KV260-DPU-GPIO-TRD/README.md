# KV260 DPU + GPIOデザイン
GPIOをKV260 DPUデザインから出す方法について。  
VIVADO/Vitis 2022.2 Petalinux 2022.2  
  
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
  
Petalinux  
ここからBSPをダウンロードする。  
  
プロジェクトを作成する。  
  
  
petalinux-create --type project -s --name  
petalinux-create --type project -s ./xilinx-kr260-starterkit-v2022.2-10141622.bsp --name kr260_test  
petalinux-config --get-hw-description=../../step1_vivado/project_1/  
  
Enable FPGA Manager under FPGA Manager.  
Change Root filesystem type to INITRD  
Change INITRAMFS/INITRD Image name to petalinux-initramfs-image  
Disable Copy final images to tftpboot  
  
セーブを実施。  
  
petalinux-config -c kernel  
Under Device Drivers > I2C support > I2C Hardware Bus support, enable  
　Cadence I2C Controller  
　Xilinx I2C Controller  
　 petalinux-config -c rootfs  
Under Filesystem Packages > base > i2c-tools, enable  
i2c-tools  
i2c-tools-dev  
  
petalinux-build  
petalinux-package --wic --images-dir images/linux/ --bootfiles "ramdisk.cpio.gz.u-boot, boot.scr, Image, system.dtb, system-zynqmp-sck-kr-g-revB.dtb" --disk-name "sda"  
  
WicをSDカードに書き込む  
  
mkdir step3_dtc  
cd step3_dtc  
xsct  
createdts -hw ../step1_vivado/project_1/system_wrapper.xsa -zocl -platform-name kr260 -git-branch xlnx_rel_v2022.2 -overlay -compile -out ./kr260_dt  
exit  
dtc -@ -O dtb -o ./kr260.dtbo ./kr260_dt/kr260_dt/kr260/psu_cortexa53_0/device_tree_domain/bsp/pl.dtsi  
  
cd ../  
mkdir step4_package  
cd step4_package  
cp ../step3_dtc/kr260.dtbo .  
echo '{ "shell_type" : "XRT_FLAT", "num_slots": "1" }' > shell.json  
cp ../step1_vivado/project_1/system_wrapper.bit kr260.bit.bin  
  
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