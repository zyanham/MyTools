### Ryzen AI Softwareを試す

Ryzen AI Max+395 GMKtecでお試し  

以下、v1.3.1の操作メモ  
[公式ドキュメント](https://ryzenai.docs.amd.com/en/1.3/)  

#### インストール開始  
・Visual Studio Community 2026をインストール    
　「C++デスクトップ開発」「MSVC v143 - VS 2022 C++ x64/x86 build tools」「Windows11 SDK」のインストールを実施する

  [Cmake](https://cmake.org/download/)の4.2.3をインストール  
  [miniforge](https://github.com/conda-forge/miniforge/releases/tag/25.11.0-1)の25.11.0-1をインストール。
  　環境変数のPATHパスも通す。  
     - path\to\miniforge3\condabin  
     - path\to\miniforge3\Scripts\  hi2
     - path\to\miniforge3\  
  [Ryzen AI Driver](https://ryzenai.docs.amd.com/en/latest/inst.html)をインストール。NPU Driver (Version 32.0.203.280)  
    タスクマネージャーで NPU driver version: 32.0.203.280の表記があることを確認

  再起動  

  [Ryzen AI Software](https://account.amd.com/en/forms/downloads/amd-end-user-license-xef.html?filename=ryzen-ai-1.3.1.msi)をインストールする。  
  ryzen-ai-lt-1.3.1.exeをダウンロードする際、AMDアカウントが必要
  問題なければパスはデフォルトでOKC:\Program Files\RyzenAI\1.3.1\
  
  インストール後、Anacondaの環境リストにryzen-ai-1.3.1が追加されているので、仮想環境で下記を実行
  
#### Miniforge起動  
> set RYZEN_AI_INSTALLATION_PATH=C:\Program Files\RyzenAI\1.3.1
> conda activate ryzen-ai-1.3.1  
> cd Program Files\RyzenAI\1.3.1\tutorial\hello_world  
> python hello_world.py  

```
CPU Execution Time: 0.04318559999956051
NPU Execution Time: 0.037466599998879246
```

#### NPUチュートリアル開始  
[チュートリアル](https://ryzenai.docs.amd.com/en/1.3.1/examples.html)お試ししてみよう。  
  
Ryzen AI SWのリポジトリをクローンする必要があるので、[Git for Windows](https://gitforwindows.org/)をインストールしよう  

v2.53.0をインストール  

> git clone https://github.com/amd/RyzenAI-SW.git -b v1.3.1

> cd RyzenAI-SW_1.3.1\tutorial\yolov8\yolov8_cpp  
> pip install cmake  
> cd RyzenAI-SW_1.3.1
> git clone https://github.com/opencv/opencv.git -b 4.6.0
> cd opencv
> mkdir mybuild
> cd mybuild

# 下記コマンドの-DCMAKE_INSTALL_PREFIX=を現行OpenCVパスに変更する

> cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DBUILD_SHARED_LIBS=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_CONFIGURATION_TYPES=Release -A x64 -T host=x64 -G "Visual Studio 18 2026" '-DCMAKE_INSTALL_PREFIX=D:\RyzenWS\opencv' '-DCMAKE_PREFIX_PATH=.\opencv' -DCMAKE_BUILD_TYPE=Release -DBUILD_opencv_python2=OFF -DBUILD_opencv_python3=OFF -DBUILD_WITH_STATIC_CRT=OFF -B build -S ../
> cmake --build build --config Release
> cmake --install build --config Release
> cd ../..

> cd RyzenAI-SW_1.3.1\tutorial\yolov8\yolov8_cpp\imprement
> conda activate ryzen-ai-1.3.1

build.batを編集する
RYZEN_AI_INSTALLATION_PATHを正しいパスになおす
OpenCV_DIRを正しいパスになおす
Visual Studioバージョンを直す"Visual Studio 18 2026"

###### glogない問題。これが原因でbuild.batが停止する。glogを入れる。
D:\RyzenWS\vcpkg\vcpkg.exe install glog:x64-windows-static
D:\RyzenWS\vcpkg\vcpkg.exe install eigen3:x64-windows-static-md glog:x64-windows-static-md

##### VS2026用に新しいビルドフォルダーを構成
cmake -S . -B build-vs2026-md -G "Visual Studio 18 2026" -A x64 -T host=x64 -DBUILD_SHARED_LIBS=OFF "-DCMAKE_INSTALL_PREFIX=D:/RyzenWS/RyzenAI-SW_1.3.1/tutorial/yolov8/yolov8_cpp" "-DONNXRUNTIME_ROOTDIR=C:/Program Files/RyzenAI/1.3.1/onnxruntime" "-DOpenCV_DIR=D:/RyzenWS/opencv/mybuild/build" "-DCMAKE_TOOLCHAIN_FILE=D:/RyzenWS/vcpkg/scripts/buildsystems/vcpkg.cmake" -DVCPKG_TARGET_TRIPLET=x64-windows-static-md

##### ビルドとインストール
cmake --build build-vs2026-md --config Release --parallel
cmake --install build-vs2026-md --config Release

##### Ryzen AI 1.3.1付属のランタイムDLLをEXEと同じ bin にコピー
copy /Y "C:\Program Files\RyzenAI\1.3.1\onnxruntime\bin\*.dll" "..\bin\"

コピーは次の5個
DirectML.dll
onnxruntime.dll
onnxruntime_providers_shared.dll
onnxruntime_providers_vitisai.dll
onnxruntime_vitisai_ep.dll

##### Vitis AI設定ファイルを配置
copy /Y "C:\Program Files\RyzenAI\1.3.1\voe-4.0-win_amd64\vaip_config.json" "..\bin\vaip_config.json"

##### implement フォルダーから実行
set "ONNXRUNTIME_ROOTDIR=C:\Program Files\RyzenAI\1.3.1\onnxruntime"
call .\run_jpeg.bat

call .\camera.bat

%cd%\..\bin\camera_yolov8_nx1x4.exe -c 5 -x 1 -y 1 -s 0 -D -R 1280x720 -r 1280x720