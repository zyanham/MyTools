### AI Engine AtoZ  
AI Engineを動かすには  
・Vitis2023.1のダウンロード＆インストール  
・Petalinux2023.1のダウンロード＆インストール  
・Vitis2023.1のLisence購入  
・AIE CompilerのLicense入手  
・xpfmファイルの準備

[Github AIE AtoZ for Linux](https://github.com/Xilinx/Vitis-Tutorials/tree/2023.1/AI_Engine_Development/Feature_Tutorials/18-aie_a_to_z_custom_linux_platform)

1. Versal Common Image Download  
[Download](https://japan.xilinx.com/support/download/index.html/content/xilinx/ja/downloadNav/embedded-platforms.html)

Versal共通イメージをリンク先からダウンロードして、任意ディレクトリにおく。
今回はAIE_Tutorial1に
mkdir AIE_Tutorial1
cd AIE_Turorial1


STEP1でまずこれをやるように指示がある  
[05 AIエンジンVersal統合](https://github.com/Xilinx/Vitis-Tutorials/blob/2023.1/AI_Engine_Development/Feature_Tutorials/05-AI-engine-versal-integration/README.md)

Vitis2023.1、Petalinux2023.1のインストールが完了した状態で、
共通イメージを解凍する

> tar -zxvf xilinx-versal-common-v2023.1_05080224.tar.gz
> source <Petalinux Install Dir>/settings.sh
> source <Vitis Install Dir>/settings64.sh
> cd xilinx-versal-common-v2023.1/
> ./sdk.sh

ROOTFS, IMAGE, PLATFORM_REPO_PATHSの環境変数をそれぞれ設定する。

export ROOTFS=<versal common image dir>/xilinx-versal-common-v2023.1/rootfs.ext4  
export IMAGE=<versal common image dir>/xilinx-versal-common-v2023.1/Image  
export PLATFORM_REPO_PATHS=$XILINX_VITIS/base_platforms  
export SYSROOT=<sysroot path>/cortexa72-cortexa53-xilinx-linux

VitisTutorialのGITをクローンする
> cd ../  
> git clone https://github.com/Xilinx/Vitis-Tutorials.git  

AtoZの前にこれをこなす必要があるらしい
cd Vitis-Tutorials/AI_Engine_Development/Feature_Tutorials/05-AI-engine-versal-integration

お試しにコンパイラを走らせるのは
make aie

コンパイル後にVitisAnalyzerで結果を確認することができる
vitisanalyzer ./Work/graph.aiecompile_summaly

* File Watch Errorなるものが出てくる。  
make sim  
make kernels  
make xsa  
make host  