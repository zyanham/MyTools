Vitis 2020.2でボードファイルを設定する  
  
■ Create Projectを選択  
■ Nextを押す  
■ Project name : U96V2_2020.2_PFM -> Next ->  
■ RTL Project  
[Do not specify sources at this time]にチェックを入れる  
[Project is an extensible Vitis Platform]にチェックを入れる  
Nextを押す  
  
■ ボード選択  
[Boards]タブを選択し、ボードファイルがなかったら[Refresh]ボタンを押して、  
ボードファイルをインストールする  
[Ultra96-V2 Single Board Computer]を選択する  
Nextを押す  
Finishを押す  
  
■ Create Block Designを押す  
Design nameをsystemに変更  
  
Add IPでMPSoCを呼び出す  
[Run Block Automation]を実行してpresetを選択。  
  
Add IPでClocking Wizardを呼び出す  
ダブルクリックでカスタマイズを開く  
[Output Clock]タブを設定  
CLK_OUT1 100MHz  
CLK_OUT2 150MHz  
CLK_OUT3 300MHzを設定。  
リセットタイプをActive Lowにする  
  
Add IPでprocessor system resetを３つ呼び出して  
proc_sys_reset_1  
proc_sys_reset_2  
proc_sys_reset_3  
でそれぞれ設定する。  
  
MPSoC:pl_clk0 -> clk_wiz0:clk_in1  
MPSoC:pl_resetn0 -> clk_wiz0:resetn, proc_sys_reset_1:ext_reset_in, proc_sys_reset_2:ext_reset_in, proc_sys_reset_3:ext_reset_in  
clk_wiz_0:clk_out1 -> proc_sys_reset_1:slowert_sync_clk  
clk_wiz_0:clk_out2 -> proc_sys_reset_2:slowert_sync_clk  
clk_wiz_0:clk_out3 -> proc_sys_reset_3:slowert_sync_clk  
clk_wiz_0:locked -> proc_sys_reset_1:dcm_locked, proc_sys_reset_2:dcm_locked, proc_sys_reset_3:dcm_locked  
  
■Platform Setupタブに移動  
clockタブを設定する  
clk_wiz_0のclk_out1,clk_out2,clk_out3をenableにチェックを入れ、is Defaultをclk_out2で選択する。  
clk_out1,clk_out2,clk_out3のIDを0,1,2で設定する  
  
■割り込みを追加する  
ブロック図で、Zynq UltraScale + MPSoCブロックをダブルクリックします。  
[ PS-PL構成]> [PS-PLインターフェイス]> [マスターインターフェイス]を選択します。  
AXI HPM0LPDオプションを有効にします。  
AXI HPM0LPDの前の矢印を展開します。AXI HPM0 LPDデータ幅の設定を確認し、デフォルトとして32のままにします。  
AXI HPM0 FPDとAXI HPM1 FPDを無効にする。  
[ OK]をクリックして構成を完了します。  
  
AXI割り込みコントローラ  
AXI interrupt controller  
AXI interruptをダブルクリックして設定を開く  
Interrupt Output Connectionをsingleに設定  
  
Run Connection Automationでclk_out2でaxi_intc_0を接続する  
axi_intc_0:irqをMPSoC:pl_ps_irqを接続する  
  
■Platform Setupタブに移動  
[プラットフォーム設定]タブに移動します  
[割り込み]タブに移動します  
axi_intc_0でintrを有効にする  
  
[プラットフォーム設定]タブに移動します  
プラットフォーム設定の[AXIポート]タブに移動します  
zynq_ultra_ps_e_0で、M_AXI_HPM0_FPDおよびM_AXI_HPM1_FPDを有効にします。  
MemportとsptagのデフォルトをM_AXI_GPに設定し、空のままにします。  
  
ps8_0_axi_periphで、M01_AXIをクリックし、Shiftキーを押しながらM07_AXIをクリックして、  
M01_AXIからM07_AXIまでのマスターインターフェイスを複数選択します。  
選択範囲を右クリックして、[有効にする]をクリックします。  
MemportとsptagのデフォルトをM_AXI_GPに設定し、空のままにします。  
  
zynq_ultra_ps_e_0の下では、すべてのAXIスレーブインタフェース、  
マルチ選択：プレスCtrlキーをクリックしS_AXI_HPC0_FPD、S_AXI_HPC1_FPD、S_AXI_HP0_FPD、S_AXI_HP1_FPD、S_AXI_HP2_FPD、S_AXI_HP3_FPDを。  
選択範囲を右クリックして、[有効にする]を選択します。  
変更Memport S_AXI_HPC0_FPDとS_AXI_HPC1_FPDにS_AXI_HP  
我々は、これらのインタフェースのための任意のコヒーレント機能を  
使用することはありませんので。  
これらのインターフェイスの単純なsptag名を入力して、リンクフェーズ中にv ++構成で選択できるようにします。HPC0、HPC1、HP0、HP1、HP2、HP3。  
  
■エミュレーション設定  
ブロックダイアグラムでPSインスタンスzynq_ultra_ps_e_0を選択します  
[ブロックのプロパティ]ウィンドウを確認してください。  
で[プロパティ]タブで、それが示してALLOWED_SIM_MODELS=tlm,rtl。これは、このコンポーネントが2種類のシミュレーションモデルをサポートしていることを意味します。  
SELECTED_SIM_MODELプロパティまで下にスクロールします。これをrtlからtlmに変更して、TLMモデルを使用するように選択します。  
  
Varidate Designを実施して、  
Create HDL Wrapperを実施  
  
FlowNavigatorからGenerateBlockDesignを選択します  
[合成オプション]を[グローバル]に選択します。生成中にIP合成をスキップします。  
[生成]をクリックします。  
  
■プラットフォームを生成する  
メニューの[ファイル] -> [エクスポート] -> [プラットフォームのエクスポート]をクリックして、ハードウェアプラットフォームのエクスポートウィザードを起動します。このウィザードは、FlowNavigatorまたはPlatformSetupウィンドウのExportPlatformボタンからも起動できます。  
最初の情報ページで[次へ]をクリックします。  
[プラットフォームタイプ：ハードウェアおよびハードウェアエミュレーション]を選択し、[次へ]をクリックします。以前にエミュレーション設定をスキップした場合は、ここで[ハードウェア]を選択します。  
[プラットフォームの状態：合成前]を選択し、[次へ]をクリックします  
プラットフォームのプロパティを入力し、[次へ]をクリックします。例えば、  
名前：u96v2_custom_platform  
ベンダー：ザイリンクス  
ボード：u96v2  
バージョン：0.0  
説明：このプラットフォームは、高いPS DDR帯域幅と、100MHz、200MHz、および400MHzの3つのクロックを提供します。  
XSAファイル名：u96v2_custom_platformを入力し、エクスポートディレクトリをデフォルトのままにします。  
[完了]をクリックします。  
u96v2_custom_platform.xsaが生成されます。エクスポートパスはTclコンソールに報告されます。  
  
  
Ultra96V2にpetalinuxを適用してデバイスドライバで何かを動かす  
  
このGITHUBをもとにビルドしていく。  
https://github.com/Xilinx/Vitis-Tutorials/blob/master/Vitis_Platform_Creation/Introduction/02-Edge-AI-ZCU104/README.md  
  
STEP1が完了  
ルートディレクトリにTCLを書き出したので、要テスト。  
  
petalinux-create --type project --template zynqMP --name u96v2_custom_plnx  
cd u96v2_cultom_plnx  
petalinux-config --get-hw-description=<vivado_design_dir>  
  
→petalinux-configが開いたら設定をする。  
***********************************************************  
  
Image Packaging Configuration -> Root filesystem type で EXT (SD/eMMC/QSPI/SATA/USB) を選択した。  
＜ Exit ＞を選択して上の階層に行く。  
  
Subsystem AUTO Hardware Settings -> Serial Settings は項目が増えていた。  
PMUFW Serial stdin/stdout, FSBL Serial stdin/stdout, ATF Serial stdin/stdout, DTG Serial stdin/stdout を psu_uart_1 に変更した。  
  
DTG Settings->MACINE_NAMEをavnet-ultra96-rev1に変更する  
Exit->Exit->Yes  
  
***********************************************************  
  
petalinux-config -c kernel  
  
***********************************************************  
10- In the “Linux/arm64 4.19.0 Kernel Configuration” window, go to “Library routines->Size in Mega bytes” and change 256 to 1024  
vim   
Ensure the following items are TURNED OFF by entering 'n' in the [ ] menu selection:  
  
CPU Power Mangement > CPU Idle > CPU idle PM support  
  
CPU Power Management > CPU Frequency scaling > CPU Frequency scaling  
  
Exit and Save.  
  
  
***********************************************************  
  
vim project-spec/meta-user/conf/user-rootfsconfig  
  
CONFIG_gpio-demo  
CONFIG_peekpoke  
CONFIG_packagegroup-petalinux-xrt  
CONFIG_dnf  
CONFIG_e2fsprogs-resize2fs  
CONFIG_parted  
CONFIG_resize-part  
CONFIG_packagegroup-petalinux-vitisai  
CONFIG_packagegroup-petalinux-self-hosted  
CONFIG_cmake  
CONFIG_packagegroup-petalinux-vitisai-dev  
CONFIG_zocl  
CONFIG_xrt  
CONFIG_xrt-dev  
CONFIG_opencl-clhpp-dev  
CONFIG_opencl-headers-dev  
CONFIG_packagegroup-petalinux-opencv  
CONFIG_packagegroup-petalinux-opencv-dev  
CONFIG_mesa-megadriver  
CONFIG_packagegroup-petalinux-x11  
CONFIG_packagegroup-petalinux-v4lutils  
CONFIG_packagegroup-petalinux-matchbox  
  
  
*****************************************************  
vim project-spec/meta-user/conf/petalinuxbsp.conf  
  
IMAGE_INSTALL_append="netperf"  
LICENSE_FLAGS_WHITELIST_append="non-commercial_netperf"  
  
*****************************************************  
  
*****************************************************  
vim project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi  
  
/include/ "systemconf.dtsi"  
/ {  
};  
&amba {  
    zyxclmm_drm {  
        compatible = "xlnx,zocl";  
        status = "okay";  
        interrupt-parent = <&axi_intc_0>;  
        interrupts = <0  4>, <1  4>, <2  4>, <3  4>,  
                 <4  4>, <5  4>, <6  4>, <7  4>,  
                 <8  4>, <9  4>, <10 4>, <11 4>,  
                 <12 4>, <13 4>, <14 4>, <15 4>,  
                 <16 4>, <17 4>, <18 4>, <19 4>,  
                 <20 4>, <21 4>, <22 4>, <23 4>,  
                 <24 4>, <25 4>, <26 4>, <27 4>,  
                 <28 4>, <29 4>, <30 4>, <31 4>;  
    };  
};  
  
&axi_intc_0 {  
      xlnx,kind-of-intr = <0x0>;  
      xlnx,num-intr-inputs = <0x20>;  
      interrupt-parent = <&gic>;  
      interrupts = <0 89 4>;  
};  
  
&sdhci1 {  
      no-1-8-v;  
      disable-wp;  
};  
  
*****************************************************  
  
// vim ./components/yocto/workspace/sources/linux-xlnx/drivers/tty/serial/xilinx_uartps.c  
  
petalinux-config -c rootfs  
  
User Packages=>すべてチェックを入れる  
Exit->Image Features  
ssh-server-dropbearを無効にし、ssh-server-opensshを有効にして、[Exit]をクリックします。  
  
Go to Filesystem Packages-> misc->packagegroup-core-ssh-dropbear and disable packagegroup-core-ssh-dropbear.  
Go to Filesystem Packages level by Exit twice.  
Go to console -> network -> openssh and enable openssh, openssh-sftp-server, openssh-sshd, openssh-scp.  
Go to root level by Exit four times.  
  
Filesystem Packages -> misc -> gcc-runtime -> libstdc++ (ON)  
  
  
In rootfs config go to Image Features and enable package-management and debug_tweaks option  
Click OK, Exit twice and select Yes to save the changes.  
  
*****************************************************  
  
Run petalinux-config  
Change DTG settings -> Kernel Bootargs -> generate boot args automatically to NO and update User Set Kernel Bootargs to earlycon console=ttyPS0,115200 clk_ignore_unused root=/dev/mmcblk0p2 rw rootwait cma=512M. Click OK, Exit thrice and Save.  
  
  
Update in system-user.dtsi  
Add chosen node in root in addition to the previous changes to this file.  
/include/ "system-conf.dtsi"  
/ {  
    chosen {  
    	bootargs = "earlycon console=ttyPS0,115200 clk_ignore_unused root=/dev/mmcblk0p2 rw rootwait cma=512M";  
    };  
};  
  
  
petalinux-build  
cd images/linux/  
  
petalinux-build --sdk  
  
./sdk.sh  
  
BOOT.BINをつくる  
petalinux-package --boot --uboot  
  
*************************************************************  
STEP3  
  
mkdir u96v2_pkg  
cd u96v2_pkg  
mkdir pfm  
cd pfm  
mkdir boot image qemu
  
cd boot  
vim linux.bif  
  
*************************************************************  
/* linux */  
the_ROM_image:  
{  
   [fsbl_config] a53_x64  
   [bootloader] <fsbl.elf>  
   [pmufw_image] <pmufw.elf>  
   [destination_device=pl] <bitstream>  
   [destination_cpu=a53-0, exception_level=el-3, trustzone] <bl31.elf>  
   [destination_cpu=a53-0, exception_level=el-2] <u-boot.elf>  
}  
*************************************************************  
  
petalinux-package --boot --format BIN --fsbl zynqmp_fsbl.elf --u-boot u-boot.elf --pmufw pmufw.elf --fpga system.bit --force  
  
<your_petalinux_dir>/images/linux directoryからbootディレクトリにコピー  
zynqmp_fsbl.elf：Vitisの既知の問題の回避策として、名前をfsbl.elfに変更します  
pmufw.elf  
bl31.elf  
u-boot.elf  
  
cp ../../../petalinux/u96v2_cultom_plnx/images/linux/zynqmp_fsbl.elf ./fsbl.elf  
cp ../../../petalinux/u96v2_cultom_plnx/images/linux/pmufw.elf .  
cp ../../../petalinux/u96v2_cultom_plnx/images/linux/bl31.elf .  
cp ../../../petalinux/u96v2_cultom_plnx/images/linux/u-boot.elf .  
  
  
cd ../image/  
cp ../../../petalinux/u96v2_cultom_plnx/images/linux/boot.scr .  
cp ../../../petalinux/u96v2_cultom_plnx/images/linux/system.dtb .  
  
※Vitis 2020.1では、環境変数を設定するために、XRTでイメージディレクトリのinit.shとplatform_desc.txtが必要です。  
　XRT2020.2では必要ありません  
  
  
*********************************************************  
vim linux.bif　　
　　
/* linux */　　
 the_ROM_image:　　
 {　　
 	[fsbl_config] a53_x64　　
 	[bootloader] <fsbl.elf>　　
 	[pmufw_image] <pmufw.elf>　　
 	[destination_device=pl] <bitstream>　　
 	[destination_cpu=a53-0, exception_level=el-3, trustzone] <bl31.elf>　　
 	[destination_cpu=a53-0, exception_level=el-2] <u-boot.elf>　　
 }　　
*********************************************************  


■エミュレーションを有効にする  
  
cd ../qemu  
  
*********************************************************  
vim qemu_args.txt
  
-M  
arm-generic-fdt  
-serial  
mon:stdio  
-global  
xlnx,zynqmp-boot.cpu-num=0  
-global  
xlnx,zynqmp-boot.use-pmufw=true  
-net  
nic  
-net  
nic  
-net  
nic  
-net  
nic  
-net  
user  
-m  
4G  
-device  
loader,file=<xrt/qemu/bl31.elf>,cpu-num=0  
-device  
loader,file=<xrt/qemu/u-boot.elf>  
-boot  
mode=5  
  
  
*********************************************************  
vim pmu_args.txt
  
-M  
microblaze-fdt  
-device  
loader,file=<xrt/qemu/pmufw.elf>  
-machine-path  
.  
-display  
none  
  
*********************************************************  
  

Qemu Data : Bootディレクトリを再利用できる
Qemu Arg : qemu_args.txtを使用
Pmu Arg : pmu_args.txtを使用
