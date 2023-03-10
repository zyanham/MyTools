10GigE Vision Camera
クイックスタートの実施

Sony IMX547 SLVS-EC
Framos SLVS-EC IP Core
Sensor-to-Image IP Core ?

1. IMX547 カメラ センサー、5.1 メガ ピクセル/2472 x 2128 ピクセル、最大フレームレート 122 fps。
2. 10 GigE パイプラインを介してライブ ストリーミング データを表示する Sphinx GEV Viewer。
3. MV-Defect-Detect アクセラレーション パイプラインは、入力されたマンゴー画像の欠陥を検出するためのものです。

| ハードウェア コンポーネント | 説明 |  
|-----------------------------|------|  
| AS-K26 | Zynq® UltraScale+™ MPSoC を使用する K26 SOM |  
| キャリアカード | (CC)-KR260	SOM が差し込まれるボードは、キャリアカードと呼ばれます。 |  
| FSM | IMX547 センサー + FSA を搭載した Framos センサー モジュール |  
| なし | 10G NIC カード |  
| 10G SFP+ トランシーバー | 光ファイバーケーブルを接続するためのトランシーバー |  
| 光ファイバーケーブル|	KR260をホストマシンに接続するための光ファイバーケーブル |  
| 1080p モニター | MV-Defect-Detect出力をDPモニターに表示 |  
| DP ケーブル | KR260ボードとDPモニターを接続 |  
  
FSM, SFP+トランシーバー KRIA スターター キットには同梱されていません。  
  
10GigE リファレンス デザインには、次のパイプラインがあります。  
 - キャプチャ パイプライン - ライブ カメラ ソースから画像をキャプチャします。  
 - シンク パイプライン - 10GigE パイプラインを介してビデオ データをストリーミングします。  
  
>sudo snap install xlnx-config --classic --channel=2.x  
>sudo xlnx-config.sysinit  
>sudo add-apt-repository ppa:xilinx-apps  
>sudo add-apt-repository ppa:ubuntu-xilinx/sdk  
>sudo apt update  
>sudo apt upgrade  
>sudo reboot  
  
Dockerが必要になるため、KR260側のUbuntuでDockerをインストールする  
>sudo groupadd docker  
>sudo usermod -a -G docker  $USER  
>id $USER  
  
XRT ZOCLドライバをインストール  
>sudo apt install xrt-dkms  
  
ubuntuユーザーにはroot 権限がありません。  
チュートリアルで使用されるほとんどのコマンドは、sudoを使用して実行する必要があり、パスワードの入力を求められる場合があります。  
セキュリティのため、デフォルトでは root ユーザーは無効になっています。ユーザーが root ユーザーとしてログインする場合は、次の手順を実行します。  
最初のパスワード プロンプトでubuntuユーザーのパスワードを使用してから、root ユーザーの新しいパスワードを設定します。  
ユーザーは、新しく設定した root ユーザーのパスワードを使用して root ユーザーとしてログインできるようになりました。  
  
ubuntu@kria:\~\$ sudo -i  
>sudo password for ubuntu:  
  
必要に応じて、システムのタイムゾーンとロケールを設定するコマンドを次に示します。  
  
タイムゾーンを設定  
sudo timedatectl set-ntp true  
sudo timedatectl set-timezone America/Los_Angeles  
timedatectl  

ロケールを設定  
sudo locale-gen en_US en_US.UTF-8  
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8  
export LANG=en_US.UTF-8  
locale  
  
git clone --branch xlnx_rel_v2022.1 --recursive https://github.com/Xilinx/kria-vitis-platforms.git  
git clone https://github.com/Xilinx/kria-apps-firmware  
  
