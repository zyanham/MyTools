# Vitis AI 3.5 情報まとめ
Vitis-AI v3.5で使用する流れについて情報をまとめています。  
  
## 1.Vitis-AI LibraryのCNNをターゲットで実行するまで  
DPUをデザインに統合する方法について[ここ](https://xilinx.github.io/Vitis-AI/3.5/html/docs/workflow-system-integration)に記載がある。  
リファレンスデザインとIPが配布されており、DPUの統合方法でVivado Flow/Vitis Flowが紹介されている。  
MPSOC対象のDPU v4.1はVivadoのIPにはデフォルトで含まれていない。ページからダウンロードしてIPのリポジトリを設定して使用する。  
ここではZCU102をターゲットボードにVitis Flowを実行してDPUのリファレンスデザインを構築するところまでばsetup_3.5.bashにまとめています。
  
### bashを実行する前にUbuntu22.04で下記のインストールを実行してください。  
 - [Vitis 2022.2](https://japan.xilinx.com/support/download/index.html/content/xilinx/ja/downloadNav/vivado-design-tools/2022-2.html)  
 - [ZYNQMP common image 2022.2](https://japan.xilinx.com/support/download/index.html/content/xilinx/ja/downloadNav/embedded-platforms/2022-2.html)  
 - [XRT 2022.2](https://github.com/Xilinx/XRT/tree/2022.2)  

ZYNQMP common imageはダウンロード＆解凍してbashのあるワークディレクトリに置いてください。
XRTはbash実行時にインストールするようになっています。

バッシュを実行します。
```  
bash setup_3.5.bash  

# Docker Run Pattern MEMO
./docker_run.sh xilinx/vitis-ai-pytorch-cpu:latest
./docker_run.sh xilinx/vitis-ai-tensorflow2-cpu:latest
./docker_run.sh xilinx/vitis-ai-tensorflow-cpu:latest
```  
このbashで下記を実施します。不要な箇所がある場合は適宜変更して使ってください。  
 - XRT 2022.2のインストール  
 - XRT/Vitis/Vivado 2022.2のパスを通す  
 - VitisAIのGithub v3.5ダウンロード  
 - ZYNQMP common imageの階層を展開  
 - DPU TRD ZCU102用プラットフォームを構築  
 - Vitis AIのpytorch/cpu Docker環境を構築  
 - AVNETのシェルcompile_modlzoo.sh、ZCU102のDPU情報arch.jsonをmodelzooに配置  
このフローはDPU TRDのREADME記載のVitis Flowを元にしています。  
model_zoo以下のmodel-listに含まれるディレクトリ群にはCNNの元データリンクがあります  
docker上でcompile_modelzoo.shを実行するとmodel-listディレクトリに含まれるCNNに対してarch.jsonにあるDPUの情報を元にコンパイルを実行する。  
arch.jsonにはfingerprintというDPUの構成を示すコードがあり、他のTRDに対してもこのコードがあっていれば逆算的にコンパイルをすることもできる  
TRDの構築が終了したら、DPU-TRD/prj/Vitis/binary_container_1/sd_card.imgをSDに書き込んでください。  
  
Vitis AIを実行するにはターゲット側にVitis AIランタイムが必要です。  
Vitis AI v3.5ではMPSOCのDPUはv3.0からの変更はないのでv3.0の環境を引っ張ります。  
[ここ](https://docs.xilinx.com/r/3.0-%E6%97%A5%E6%9C%AC%E8%AA%9E/ug1414-vitis-ai/%E8%A9%95%E4%BE%A1%E3%83%9C%E3%83%BC%E3%83%89%E3%81%AB-Vitis-AI-%E3%83%A9%E3%83%B3%E3%82%BF%E3%82%A4%E3%83%A0%E3%82%92%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB)にVitisAIランタイムのインストールに関して解説があります。  
これもbashでDownloadディレクトリを作成して展開するよう記載しています  
ZCU102をSDカードから起動させたあと、ターゲット側に接続してDPU-TRD/appとvitis-ai-runtime-3.0.0.tar.gzを転送してください。  
```  
#ターゲットへファイル転送例 SCP
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
  
## 2.NVIDIA GPUを使ったVitis-AI Libraryのyoloxをリトレーニングするまで  
まずは、NVIDIA GPUの環境設定が必要に。  
Ubuntu 22.04.3 LTS/RTX3060で構築した環境についてメモを記載する。  
```  
#GPUの所在を確認  
lspci  
> 08:00.0 VGA compatible controller: NVIDIA Corporation GA106 [GeForce RTX 3060] (rev a1)  
  
#デバイスが見つかったら下記コマンドで推奨ドライバを確認する  
#すでに入っているものと差分があれば、アンインストールして入れ直す。
ubuntu-drivers devices  
> == /sys/devices/pci0000:00/0000:00:03.1/0000:08:00.0 ==
> modalias : pci:v000010DEd00002503sv00001043sd000087F3bc03sc00i00
> vendor   : NVIDIA Corporation
> model    : GA106 [GeForce RTX 3060]
> driver   : nvidia-driver-525-open - distro non-free
> driver   : nvidia-driver-470-server - distro non-free
> driver   : nvidia-driver-515 - third-party non-free
> driver   : nvidia-driver-535-server-open - distro non-free
> driver   : nvidia-driver-535 - third-party non-free
> driver   : nvidia-driver-525 - third-party non-free
> driver   : nvidia-driver-535-server - distro non-free
> driver   : nvidia-driver-525-server - distro non-free
> driver   : nvidia-driver-530 - third-party non-free
> driver   : nvidia-driver-545 - third-party non-free
> driver   : nvidia-driver-470 - distro non-free recommended
> driver   : nvidia-driver-520 - third-party non-free
> driver   : nvidia-driver-535-open - distro non-free
> driver   : xserver-xorg-video-nouveau - distro free builtin

nvidia-smi
> Fri Oct 20 09:34:00 2023       
> +---------------------------------------------------------------------------------------+
> | NVIDIA-SMI 535.113.01             Driver Version: 535.113.01   CUDA Version: 12.2     |
> |-----------------------------------------+----------------------+----------------------+
> | GPU  Name                 Persistence-M | Bus-Id        Disp.A | Volatile Uncorr. ECC |
> | Fan  Temp   Perf          Pwr:Usage/Cap |         Memory-Usage | GPU-Util  Compute M. |
> |                                         |                      |               MIG M. |
> |=========================================+======================+======================|
> |   0  NVIDIA GeForce RTX 3060        Off | 00000000:08:00.0  On |                  N/A |
> |ERR!   31C    P0              45W / 170W |    482MiB / 12288MiB |      0%      Default |
> |                                         |                      |                  N/A |
> +-----------------------------------------+----------------------+----------------------+
>                                                                                          
> +---------------------------------------------------------------------------------------+
> | Processes:                                                                            |
> |  GPU   GI   CI        PID   Type   Process name                            GPU Memory |
> |        ID   ID                                                             Usage      |
> |=======================================================================================|
> |    0   N/A  N/A      2088      G   /usr/lib/xorg/Xorg                          271MiB |
> |    0   N/A  N/A      2252      G   /usr/bin/gnome-shell                        102MiB |
> |    0   N/A  N/A      2891      G   ...13649781,9920179312950581114,262144      100MiB |
> +---------------------------------------------------------------------------------------+
# Ubuntu22.04インストール時に3rd Partyのグラフィックドライバも入れたので、デフォルトでnvidia-smiが実行できた。
# ここに記載あるCUDAバージョンはインストールされているものではなくて推奨なので別途CUDAもインストールする
```  
CUDAは[ここ](https://developer.nvidia.com/cuda-toolkit)から、あわせてCuDNNも[ここ](https://developer.nvidia.com/cudnn)からインストールする。  
インストールが完了したら、動作確認を実施する。  
```
# CUDAコンパイラのバージョン確認
nvcc --version
> nvcc: NVIDIA (R) Cuda compiler driver
> Copyright (c) 2005-2023 NVIDIA Corporation
> Built on Fri_Sep__8_19:17:24_PDT_2023
> Cuda compilation tools, release 12.3, V12.3.52
> Build cuda_12.3.r12.3/compiler.33281558_0

# CuDNN動作確認
cp -r /usr/src/cudnn_samples_v8 .
cd cudnn_samples_v8/
ls
> conv_sample  mnistCUDNN  multiHeadAttention  NVIDIA_SLA_cuDNN_Support.txt  RNN  RNN_v8.0  samples_common.mk
cd RNN
make
> CUDA_VERSION is 12030
> Linking agains cublasLt = true
> CUDA VERSION: 12030
> TARGET ARCH: x86_64
> TARGET OS: linux
> SMS: 50 53 60 61 62 70 72 75 80 86 87 90
> ...
./RNN
> Executing: RNN
> seqLength  = 20
> numLayers  = 2
> hiddenSize = 512
> inputSize  = 512
> miniBatch  = 64
> dropout    = 0.000000
> direction  = CUDNN_UNIDIRECTIONAL
> mode       = CUDNN_RNN_RELU
> algo       = CUDNN_RNN_ALGO_STANDARD
> precision  = CUDNN_DATA_FLOAT
>
> Forward:   2 GFLOPS
> Backward:   7 GFLOPS, (  7 GFLOPS), (  7 GFLOPS)
> y checksum 1.315793E+06     hy checksum 1.315212E+05
> dx checksum 6.676001E+01    dhx checksum 6.425049E+01
> dw checksum 1.453738E+09
> Output saved to result.txt
#動いた。
```

[ここ](https://xilinx.github.io/Vitis-AI/3.5/html/docs/install/install.html#option-2-build-the-docker-container-from-xilinx-recipes)によると、
Vitis−AI v3.5ではNVIDIA GPU環境は自分でDockerビルドしないといけない様子。  
```  
#GPUとpytorchターゲットでdockerbuildを実行する  
cd docker  
./docker_build.sh -t gpu -f pytorch  
  
#ビルドが終了したらワークディレクトリからDockerを呼び出す。  
./docker_run_gpu.sh  
#DockerのイメージIDがベタ書きになっているので、適宜直すこと  

# Docker上でGPUを叩くには[nvidia-container-runtime](https://github.com/NVIDIA/nvidia-container-runtime)を入れる必要がある？  
curl -s -L https://nvidia.github.io/nvidia-container-runtime/gpgkey | \  
sudo apt-key add -　distribution=$(. /etc/os-release;echo $ID$VERSION_ID)  
curl -s -L https://nvidia.github.io/nvidia-container-runtime/$distribution/nvidia-container-runtime.list | \  
sudo tee /etc/apt/sources.list.d/nvidia-container-runtime.list  
sudo apt-get update  
sudo apt-get install nvidia-container-runtime  
#次に下記Dockerリポジトリから任意のドライバイメージを持ってきてDocker RUNするとか  
docker run --gpus all nvidia/cuda:11.3.1-cudnn8-runtime-ubuntu20.04 nvidia-smi  
#nvidia-smiは実行できたが、DockerからGPUにアクセスできなかったので、まだなにか足りない？
```  
Docker上からGPUにアクセスできなかったので、通常の環境でVitis-AI Libraryを回す方針に変更。  

[ここ](https://www.anaconda.com/download)からAnaconda3をインストールする。  
ダウンロードできるのはシェルのみ。  
```
#Anacondaでダウンロードしたシェルを実行して、インストールする
./Anaconda3-2023.09-0-Linux-x86_64.sh
#Anacondaをインストールすると自動的に環境が立ち上がるようになる。

conda activate <(Option) Enviroment Name>   #Anacondaのベース環境有効化
conda deactivate                            #Anacondaのベース環境無効化
conda config --set auto_activate_base true  #Anacondaの自動起動ON
conda config --set auto_activate_base false #Anacondaの自動起動ON
anaconda-navigator                          #AnacondaのGUIツール起動(仮想環境上で実行可能)
conda install <app name>                    #Anaconda環境にインストールする

```
Anacondaを有効化して、anaconda-navigatorで”"pytorch-test"などの名前で生成する。  
このとき、Pythonのバージョンを決定できるのでv3.8で生成。  
  
Vitis-AI_v3.5/model_zooで、model-listに含まれるpt_yolox-nano_3.5を残す。  
compile_modelzoo.shを実行すると、もmodel.b4096ディレクトリにZCU102向けにコンパイルされた  
DPU向けのモデルが生成される。  
cacheディレクトリにpt_yolox-nano_3.5.zipが格納されており、そこにVitis AI Libraryの環境がある。  
リトレーニング、量子化、評価などのスクリプトが含まれている。基本的にREADMEにそのネットワークの環境について記載がある  
yolox-nanoをリトレーニングするにはCoCoDatasetというオープンデータのトレーニング用ファイル群が必要。  
このトレーニングファイルを任意のものにすればユーザーのカスタムも可能だが、手順確認のためデフォルトのデータを使用する。  
COCODATASETの[ダウンロードページ](https://cocodataset.org/#download)でダウンロードする。  
ワークディレクトリにあるシェルを実行すると必要なファイルをDownloadディレクトリにダウンロードする。  
```
./coco_download.sh
```
これらをpt_yolox-nano_3.5/data/COCO以下に配置するとデータのセッティングは完了。  
  
以下の環境設定も追加  
```
#protobuf、numpyが新しすぎたのでインストールし直し。
pip uninstall protobuf
pip install protobuf==3.20.1
pip uninstall numpy
pip install numpy==1.20

```

VitisAIのpytorch環境向け量子化ツール[vai_q_pytorch](https://docs.xilinx.com/r/ja-JP/ug1414-vitis-ai/Pytorch-%E3%83%90%E3%83%BC%E3%82%B8%E3%83%A7%E3%83%B3-vai_q_pytorch)をインストールする。  
項目「ソースコードからインストール」を実施する。  
```
#.bashrcに下記を記載する
export CUDA_HOME=/usr/local/cuda
cd Vitis-AI_v3.5/src/vai_quantizer/vai_q_pytorch
pip install -r requirements.txt
cd ./pytorch_binding 
python setup.py install
#インストールを検証する
python -c "import pytorch_nndct"

#pt_yolox-nano_3.5のルートディレクトリに移動して、環境設定を続ける。
pip install --user -r requirements.txt 
cd code
pip install --user -v -e .
cd ..
#リトレーニングを実行する。
bash code/run_train.sh

```

## 3.Vitis AI Optimizerを使うには
v3.5でオープンソースとなり、ライセンスも不要となった。(ハズ)  
メモを記載していく  
★[ここ](https://docs.xilinx.com/r/en-US/ug1333-ai-optimizer/Vitis-AI-Optimizer-Overview)には運営にメールするか、ラウンジに入るように記載がある。  
  
[VAI Optimizerの解説ページ](https://github.com/Xilinx/Vitis-AI/tree/master/src/vai_optimizer)  
[VAI Optimizer Pytorch版の解説ページ](https://github.com/Xilinx/Vitis-AI/blob/master/src/vai_optimizer/pytorch_binding/pytorch_nndct/pruning/README.md)  
  
Vitis-AI Optimizerのチュートリアルは[ここ](https://github.com/Xilinx/Vitis-AI-Tutorials/tree/3.5/Tutorials/TF2-Vitis-AI-Optimizer/)にある  
VAI Optimizerの説明書は[ここ](https://github.com/Xilinx/Vitis-AI/tree/v3.5/src/vai_optimizer)  
VAI Optimizerはフレームワークごとにインストール方法が違う。このチュートリアルはTensorFlow2  
- [VAI Optimizer Pytorch](https://github.com/Xilinx/Vitis-AI/blob/v3.5/src/vai_optimizer/pytorch_binding/pytorch_nndct/pruning/README.md)  
- [VAI Optimizer TensorFlow](https://github.com/Xilinx/Vitis-AI/blob/v3.5/src/vai_optimizer/tensorflow_v1/README.md)  
- [VAI Optimizer TensorFlow2](https://github.com/Xilinx/Vitis-AI/blob/v3.5/src/vai_optimizer/tensorflow/README.md)  
  
TensorFlow2のフローを踏襲  
Anaconda環境(Python3.8)で環境構築を実施。  
cd <work dir>/Vitis-AI/src/vai_optimizer/tensorflow  
pip install -r requirements.txt  
pip install tensorflow==2.12.0  
export CUDA_HOME=/usr/local/cuda  
python setup.py install  
python setup.py develop  
python -c "from tf_nndct import IterativePruningRunner"  
  
チュートリアルを開始  
git clone -b 3.5 https://github.com/Xilinx/Vitis-AI-Tutorials.git  
cd Vitis-AI-Tutorials/Tutorials/TF2-Vitis-AI-Optimizer  
ここのREADMEに手順が記載されている。  
  
Vitis-AI以下にtutorialsディレクトリを作成してTF2-Vitis-AI-Optimizerディレクトリをコピーする  
cd Vitis-AI  
mkdir tutorials  
cp -r <work dir>/TF2-Vitis-AI-Optimizer tutorials/  
cd tutorials/TF2-Vitis-AI-Optimizer  
  
[Kaggleのデータセットをダウンロードする](https://www.kaggle.com/c/dogs-vs-cats/data)  
アカウント登録、規約確認等実施してデータセットdogs-vs-cats.zipをダウンロードしたら、  
アーカイブのままTF2-Vitis-AI-Optimizer/files/dogs-vs-cats_mobilenetv2に配置する。  
  
Step1.環境設定  
cd scripts/  
bash setup_env.sh  
  
export BUILD=./build_pr  
export LOG=${BUILD}/logs  
mkdir -p ${LOG}  
export  TF_CPP_MIN_LOG_LEVEL=3  
  
Step.2 Kaggle データセットを TFRecord に変換する  
python -u images_to_tfrec.py 2>&1 | tee ${LOG}/tfrec.log  
  
Step.3 初期トレーニング  
python -u implement.py --mode train --build_dir ${BUILD} 2>&1 | tee ${LOG}/train.log  

## 4.tiny-yolo3をBDD100KでトレーニングしてTF2に移植し、ZUBに移植するなど  
基本的なtiny-YOLOv3をBDD100Kでトレーニングするフローはここを参照した。  
[YOLOv3をBDD100Kでトレーニングする](https://github.com/yogeshgajjar/BDD100k-YOLOV3-tiny)  

DarknetでBDD100Kを用いてリトレーニングを実施する。  
BDD100Kのデータセット入手はサイトへの登録が必要。  
BDDのサイトは[ここ](https://bdd-data.berkeley.edu/)  
  
道路上の想定の検知ターゲットが含まれている。  
 1:car  
 2:bus  
 3:person  
 4:bike  
 5:truck  
 6:motorcycle  
 7:train  
 8:rider  
 9:traffic sign  
10:traffic light  
  
RTX3060を1台用いて、Darknetのmaxbatch=500000はトレーニング期間は約5日間となった。  
トレーニング回数の目安は1class x 2000batchらしいので  
maxbatchは10class x 2000batch = 200000batchでいいらしい。  

続いて、DarknetをTF2に移植する手順は下記を参考にした  
[Vitis™ AIを用いて、オープンソースのYOLOをKria™ KV260上で動かしてみた](https://www.paltek.co.jp/techblog/techinfo/230215_01)  
keras-yolo3を用いてVitis-AI v2.5へのYOLOv3移植について解説している。  

このフローでは下記のGithubのコンテンツを利用している。
[keras-yolo3 YOLOv3をTensorflow2へ変換する試み](https://github.com/qqwweee/keras-yolo3)  
  
> git clone https://github.com/qqwweee/keras-yolo3.git  
  
weightをダウンロードする  
> cd keras-yolo3  
> wget https://pjreddie.com/media/files/yolov3-tiny.weights  
  
anaconda環境を作成する(anacondaは要事前インストール)  
> conda create -n yolo python=3.7  
> conda activate yolo  
> conda install tensorflow-gpu==1.13.1 keras==2.2.4 pillow matplotlib  
> pip install opencv-python  
> conda install h5py==2.10.0  
> python convert.py yolov3-tiny.cfg yolov3-tiny.weights model_data/yolov3-tiny.h5  
  
紆余曲折ありコンパイルできた  
コンパイル時にはcfgファイルに含まれる"Training"をコメントアウトする。  
  
引き続きkerasへの移植を実施して無事にコンパイル完了  
この手順では評価用のスクリプトを実行する。これは量子化後に一部の画像データで  
精度を測定する機構が入っているが、量子化が実行されれば特にここは気にせずにすすめてOK  
  
####  
bash 候補フロー  
> git clone -b v3.5 https://github.com/Xilinx/Vitis-AI.git  
  
  
## 5.Vitis AIでKR260にDPUを統合する方法？  
調査中  
[Kria KR260-DPU-TRD-VIVADO flow Vitis AI 3.0 Tutorial](https://www.hackster.io/LogicTronix/kria-kr260-dpu-trd-vivado-flow-vitis-ai-3-0-tutorial-0085fd)  
  
## 6.Darknetのアノテーションを半自動化する方法？  
調査中  
[darknetでyoloのデータセット作成を半自動化する](https://qiita.com/k65c1/items/7e8034c05829e701d120)  
  

