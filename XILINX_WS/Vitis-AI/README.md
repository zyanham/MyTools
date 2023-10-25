# Vitis AI 3.5

[DPUの統合方法について](https://xilinx.github.io/Vitis-AI/3.5/html/docs/workflow-system-integration)  
  
bashを実行する前にUbuntu22.04で下記のセットアップ  
 - [Vitis 2022.2](https://japan.xilinx.com/support/download/index.html/content/xilinx/ja/downloadNav/vivado-design-tools/2022-2.html)  
 - [ZYNQMP common image 2022.2](https://japan.xilinx.com/support/download/index.html/content/xilinx/ja/downloadNav/embedded-platforms/2022-2.html)  
 - [XRT 2022.2](https://github.com/Xilinx/XRT/tree/2022.2)  

ZYNQMP common imageをダウンロード＆解凍してワークディレクトリに置く。  

バッシュを実行する
```  
bash setup_3.5.bash  
```  

このbashで下記を実施。所望出ない場合は適宜変更のこと。  
- XRT 2022.2のインストール  
- XRT/Vitis/Vivado 2022.2のパスを通す  
- VitisAIのGithub v3.5ダウンロード  
- ZYNQMP common imageの階層を展開  
- DPU TRD ZCU102用プラットフォームを構築  
- Vitis AIのpytorch/cpu Docker環境を構築  
- AVNETのシェルcompile_modlzoo.shをmodelzooに配置  
  
このフローはDPU TRDのREADME/Vitis Flowを元にしている。  
model_zoo以下のmodel-listディレクトリに含まれるディレクトリにはmodel-zooに含まれるCNNの元データリンクがある  
docker上でcompile_modelzoo.shを実行するとmodel-listディレクトリに含まれるCNNに対して
arch.jsonにあるDPUの情報を元にコンパイルを実行する。  
arch.jsonにはfingerprintというDPUの構成を示すコードがあり、  
他のTRDに対してもこのコードがあっていれば逆算的にコンパイルをすることもできる  
  
DPU-TRD/prj/Vitis/binary_container_1/sd_card.imgをSDに書き込む  
  
Vitis AIを実行するにはターゲット側にVitis AIランタイムが必要。  
Vitis AI v3.5ではMPSOCのDPUはv3.0からの変更はないのでv3.0の環境を引っ張る。  
[ここ](https://docs.xilinx.com/r/3.0-%E6%97%A5%E6%9C%AC%E8%AA%9E/ug1414-vitis-ai/%E8%A9%95%E4%BE%A1%E3%83%9C%E3%83%BC%E3%83%89%E3%81%AB-Vitis-AI-%E3%83%A9%E3%83%B3%E3%82%BF%E3%82%A4%E3%83%A0%E3%82%92%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB)にVitisAIランタイムのインストールに関して解説がある。  
```  
wget https://japan.xilinx.com/bin/public/openDownload?filename=vitis-ai-runtime-3.0.0.tar.gz -O vitis-ai-runtime-3.0.0.tar.gz  
```  
bashにDownloadに展開するよう記載した  
ターゲット側に接続してDPU-TRD/appとvitis-ai-runtime-3.0.0.tar.gzを転送する。  
```  
scp <local file name> <転送先アドレス>  
scp afile root@192.168.1.11:/home/.  
```  
  
転送するものは  
-appディレクトリ  
-ランタイムデータ  
-コンパイルしたCNNモデルディレクトリ  
-avi形式の動画など  
-Vitis-AI/examplesディレクトリ  
  
```  
#ターゲット側でOptimizeの実行とランタイムのインストールを実施します。  
cd /app/  
tar -xzvf dpu_sw_optimize.tar.gz  
#次にランタイムを展開します  
tar -xzvf vitis-ai-runtime-3.0.x.tar.gz  
cd centos  
bash setup.sh  
#さらにモデル格納用のディレクトリを作成します  
mkdir /usr/share/vitis_ai_library/models  
#コンパイルしたモデルをこのディレクトリに移動します。  
cp <model name> /usr/share/vitis_ai_library/models  
```  
  
