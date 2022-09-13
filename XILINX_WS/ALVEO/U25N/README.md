## U25Nセットアップメモ  
U25Nの動作モードはLegacy Mode / Switchdev Modeの２種類  
  
OS Requirement :  
Ubuntu 18.04/Ubuntu 20.04  
20.04.02LTS/Kernel 5.8以上  
  
Kernel Requirement :  
Open vSwitch機能 >= 4.15  
Stateless Firewall機能 >= 5.5  
OSVバージョン：2.12以降  
  
### セットアップメモ   

```bash
# OVS公式ページ  
# https://www.openvswitch.org/  
wget https://www.openvswitch.org/releases/openvswitch-2.17.2.tar.gz  
tar -zxvf openvswitch-2.17.2.tar.gz  
  
# OVSインストールはaptでも可  
# Open vSwitch Install  
sudo apt install openvswitch-switch openvswitch-common  
  
# サーバーが U25N スマート NIC で正常に起動したら、  
# lspci コマンドを使用して U25N スマート NIC が検出されることを確認します。  
  
lspci | grep Solarflare  
  
> 01:00.0 Ethernet controller: Solarflare Communications XtremeScale SFC9250 10/25/40/50/100G Ethernet Controller (rev 01)  
> 01:00.1 Ethernet controller: Solarflare Communications XtremeScale SFC9250 10/25/40/50/100G Ethernet Controller (rev 01)  
  
# ターゲット サーバーでパッケージをダウンロードして解凍します。  
# Alien パッケージは、コマンドを使用してダウンロードする必要があります。  
sudo apt install alien  
  
# rpmからdpkgファイルを作成します  
  
sudo alien sfutils-XXXXXXXXX.x86_64.rpm  
  
# dpkgファイルをインストールします  
sudo dpkg -i sfutils_XXXXXXXXXX_amd64.deb  
  
# dkmsをインストールする  
sudo apt-get install dkms  
  
ethtool -i enp1s0f0np0 | grep version  
> version: X.X  
> firmware-version: X.X.X.XXXX rx0 tx0  
> expansion-rom-version:   
  
# レガシー バージョンの debian パッケージが既に存在する場合は、  
# 最新の debian パッケージをインストールする前に、既存のパッケージを削除します。  
modprobe mtd  
modprobe mdio  
rmmod sfc  
dpkg -r sfc-dkms  
dpkg -i sfc-dkms_x.x.x.x_all.deb  
modprobe sfc  
  
# 次に、debian ドライバー パッケージをインストールします。  
dpkg -i sfc-dkms_X.X.X.XXXX.X_all.deb  
  
# コマンドを使用して U25N ドライバーがロードされていることを確認する  
lsmod | grep sfc  
  
# 次のステップを実行して、ファームウェアを更新します。  
sudo sfboot --list  
  
> Solarflare boot configuration utility [vX.X.X]  
> Copyright 2002-2020 Xilinx, Inc.   
> Adapter list:  
>   enp1s0f0np0  
>   enp1s0f1np1  
  
# sfupdateコマンドを使用してファームウェアのバージョンを確認します。  
# バージョンは 1011 である必要があります。  
sudo sfupdate | grep Bundle  
>     Bundle type:        U25N  
>     Bundle version:     vX.X.XX.1011  
> The Bundle firmware is up to date  
>     Bundle type:        U25N  
>     Bundle version:     vX.X.XX.1011  
> The Bundle firmware is up to date  
  
# U25シェルのバージョンチェック  
ethtool -i enp1s0f0np0 | grep version  
  
> version: X.X.X.XXXX.X  
> firmware-version: X.X.X.XXXX rx0 tx0  
> expansion-rom-version:  
  
ethtool -i enp1s0f1np1 | grep version  
> version: X.X.X.XXXX.X  
> firmware-version: X.X.X.XXXX rx0 tx0  
> expansion-rom-version:  
  
./u25n_update get-version enp1s0f0np0  
  
> [u25n_update] - Image Upgrade/Erase Utility VX.X  
>   
> Reading version from the hardware  
>  
> X2 Firmware Version : X.X.XX.XXXX  
> PS Firmware Version : X.XX  
> Deployment shell Version : 0xXXXXXXXXX  
> Bitstream Version : 0xXXXXXXXXXXXXx  
> No features supported for offload. Just basic NIC functionality  
> Timestamp : 16-08-2021 14:00:00  
>  
>  
> STATUS: SUCCESSFUL  
  
./u25n_update get-version enp1s0f1np1  
  
> [u25n_update] - Image Upgrade/Erase Utility VX.X  
>   
> Reading version from the hardware  
>   
> X2 Firmware Version : X.X.XX.XXXX  
> PS Firmware Version : X.XX  
> Deployment shell Version : 0xXXXXXXXX  
> Bitstream Version : 0xXXXXXXXX  
> No features supported for offload. Just basic NIC functionality  
> Timestamp : 16-08-2021 14:00:00  
>   
>   
> STATUS: SUCCESSFUL  
  
# U25N カードがレガシー モードであることを確認します。以下は、検証するコマンドです。  
# devlink dev eswitch show pci/0000:<pci_id>  
devlink dev eswitch show pci/0000:01:00.0  
devlink dev eswitch show pci/0000:01:00.1  
  
sudo devlink dev eswitch show pci/0000:01:00.0   
> pci/0000:01:00.0: mode legacy  
  
./u25n_update upgrade ../shell/U25N_Shell_XXXX.bin enp1s0f0np0  
  
> [u25n_update] - Image Upgrade/Erase Utility VX.X  
>   
> Verified: OK  
> [File Details]  
> File name: U25N_Shell_XXXX.bin  
> File size: 78.25M  
>   
> [TRANSFER] Status = 100%	------------DONE------------  
> [ERASE]    Status = 100%	------------DONE------------  
> [WRITE]    Status = 100%	------------DONE------------  
> [VERIFY]   Status = 100%	------------DONE------------ Time Elapsed = 07:25  
>   
> STATUS: SUCCESSFUL  
  
./u25n_update reset enp1s0f0np0  
  
> [u25n_update] - Image Upgrade/Erase Utility VX.X  
>   
> Resetting flash to load deployment image  
> Waiting for reset complete  
>   
>   
> STATUS: SUCCESSFUL   
  
# U25N デプロイメント イメージのバージョンの詳細を取得するには、次のコマンドを使用します。  
./u25n_update get-version enp1s0f0np0  
  
> [u25n_update] - Image Upgrade/Erase Utility VX.X  
>   
> Reading version from the hardware  
>   
> X2 Firmware Version : X.X.XX.XXXX  
> PS Firmware Version : X.00  
> Deployment shell Version : 0xXXXXXXXX  
> Bitstream Version : 0xXXXXXXXXX  
> No features supported for offload. Just basic NIC functionality  
> Timestamp : 08-12-2021 16:30:45  
>  
> STATUS: SUCCESSFUL  
  
# U25N カードがレガシー モードであることを確認します。以下は、検証するコマンドです。  
# devlink dev eswitch show pci/0000:<pci_id>  
devlink dev eswitch show pci/0000:01:00.0  
devlink dev eswitch show pci/0000:01:00.1  
  
# カードがまだレガシー モードになっていない場合は、次のコマンドを使用してモードを切り替えます。  
devlink dev eswitch set pci/0000:<PCIe device bus id> mode legacy  
  
# U25N SmartNIC をゴールデン イメージに戻す ※レガシーモードのみ  
./u25n_update factory-reset <PF0_interface>  
  
# 次のコマンドを実行して、U25N PF インターフェイスを switchdev モードにします。  
devlink dev eswitch set pci/0000:<PCIe device bus id> mode switchdev  

