#### 1.Getting Started Tutorial  
[Getting Started Tutorial for INT8 models](https://ryzenai.docs.amd.com/en/latest/getstartex.html)  
CIFAR-10 datasetを使ったINT8モデル試験  

Miniforgeプロンプトを起動  
Step1. Package Install
> cd RyzenAI-SW/CNN-examples/getting_started_resnet/int8  
> conda create --name resnet_env --clone ryzen-ai-1.7.0  
> conda activate resnet_env  
> python -m pip install -r requirements.txt

[CIFAR-10 データセット]([https://www.cs.toronto.edu/~kriz/cifar.html](https://www.kaggle.com/competitions/cifar-10))をダウンロードするよ  

Step2.Prepare dataset and ONNX model  
> python prepare_model_data.py  
Step3.Quantize  
> python resnet_quantize.py  
Step4.Deploy Model  

##### CPU Deploy  
> python predict.py  

##### Ryzen AI NPU Deploy  
> python predict.py --ep npu

##### Install vcpkg & Eigen3  
> cd $rootdir  
> git clone https://github.com/microsoft/vcpkg.git  
> cd vcpkg  
> bootstrap-vcpkg.bat  
> vcpkg install eigen3:x64-windows
> vcpkg list | findstr eigen3

##### Deploy CPP  
※ チュートリアルがVisual Studio 2022なのに対して現状入手できるのが2026であったり、  
   pythonが3.10-3.12だったりとビルド環境の条件がまちまちなのでC++は後回し  
RyzenWSへ移動してOpenCV環境を実行  
> cd $rootdir  
> git clone https://github.com/opencv/opencv.git -b 4.6.0  
> cd opencv  
> cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DBUILD_SHARED_LIBS=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_CONFIGURATION_TYPES=Release -A x64 -T host=x64 -G "Visual Studio 18 2026" "-DCMAKE_INSTALL_PREFIX=C:\opencv" "-DCMAKE_PREFIX_PATH=C:\opencv" -DCMAKE_BUILD_TYPE=Release -DBUILD_opencv_python2=OFF -DBUILD_opencv_python3=OFF -DBUILD_WITH_STATIC_CRT=OFF -B build  
> cmake --build build --config Release  
> cmake --install build --config Release  

##### Resnet C++サンプルビルド  
> cd getting_started_resnet/int8/cpp  
> cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DBUILD_SHARED_LIBS=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_CONFIGURATION_TYPES=Release -A x64 -T host=x64 -DCMAKE_INSTALL_PREFIX=. -DCMAKE_PREFIX_PATH=. -B build -S resnet_cifar -DOpenCV_DIR="C:/opencv" -G "Visual Studio 18 2026"  

#### BF16版のResnet NPU試験  
cd RyzenAI-SW\CNN-examples\getting_started_resnet\bf16  
conda create --name resnet_bf16 --clone ryzen-ai-1.7.0  
conda activate resnet_bf16  

##### Download Model and Dataset  
python prepare_model_data.py  

##### Model Compilation  
python compile.py --model models\resnet_trained_for_cifar10.onnx  

CPU実行  
```  
(resnet_bf16) C:\Users\Yujiro\Desktop\RyzenWS\RyzenAI-SW\CNN-examples\getting_started_resnet\bf16>python predict.py  
execution started on CPU  
Image 0: Actual Label cat, Predicted Label cat  
Image 1: Actual Label ship, Predicted Label ship  
Image 2: Actual Label ship, Predicted Label ship  
Image 3: Actual Label airplane, Predicted Label airplane  
Image 4: Actual Label frog, Predicted Label frog  
Image 5: Actual Label frog, Predicted Label frog  
Image 6: Actual Label automobile, Predicted Label truck  
Image 7: Actual Label frog, Predicted Label frog  
Image 8: Actual Label cat, Predicted Label cat  
Image 9: Actual Label automobile, Predicted Label automobile  
```  

NPU実行  
```  
(resnet_bf16) C:\Users\Yujiro\Desktop\RyzenWS\RyzenAI-SW\CNN-examples\getting_started_resnet\bf16>python predict.py --ep npu  
execution started on NPU  
Image 0: Actual Label cat, Predicted Label cat  
Image 1: Actual Label ship, Predicted Label ship  
Image 2: Actual Label ship, Predicted Label ship  
Image 3: Actual Label airplane, Predicted Label airplane  
Image 4: Actual Label frog, Predicted Label frog  
Image 5: Actual Label frog, Predicted Label frog  
Image 6: Actual Label automobile, Predicted Label truck  
Image 7: Actual Label frog, Predicted Label frog  
Image 8: Actual Label cat, Predicted Label cat  
Image 9: Actual Label automobile, Predicted Label automobile  
```  
