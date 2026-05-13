#### YOLOX s(FP16)/m(INT8)のお試し  
> cd RyzenAI-SW_1.7.1\TEST_WS\YOLOX  
> conda create --name yolox_env --clone ryzen-ai-1.7.1  
> conda activate yolox_env  
  
> git clone https://github.com/Megvii-BaseDetection/YOLOX.git original_yolox  
> cd .\original_yolox  

> pip install loguru thop tensorboard pycocotools  
> pip install torchvision==0.19.1  
> pip install -e . --no-deps  

## 本家から重みをダウンロード  
[ここから](https://github.com/megvii-basedetection/yolox)  
ディレクトリweights, modelsを掘って、重みデータを置く。yolox-s&yolox-m  

#### 公式ツールでPytorch->ONNXへ重みをExportする  
> set PYTHONPATH=%CD%;%PYTHONPATH%
> python .\tools\export_onnx.py --output-name .\models\yolox_s_op17.onnx -n yolox-s -c .\weights\yolox_s.pth -o 17 --no-onnxsim  
> python .\tools\export_onnx.py --output-name .\models\yolox_m_op17.onnx -n yolox-m -c .\weights\yolox_m.pth -o 17 --no-onnxsim  

#### 普通の推論テスト
> cd demo\ONNXRuntime  
> python .\onnx_inference.py -m ..\..\models\yolox_s_op17.onnx -i ..\..\..\test.jpg -o .\out -s 0.3 --input_shape 640,640  
#### BF16による画像一枚出力テスト test用画像test.jpgが必要  
> cd ..\..\..\
> python .\run_yolox_bf16_image.py -m original_yolox\models\yolox_s_op17.onnx -i .\test.jpg -o .\bf16_test.jpg --config_file .\vai_ep_config.json --score_thr 0.3  

#### BF16によるカメラ試験（人数カウント付き) YOLOX-sでおよそ16fps   
> python .\run_yolox_bf16_camera_count.py -m .\original_yolox\models\yolox_s_op17.onnx --config_file .\vai_ep_config.json --count-person --count-thr 0.40  

#### BF16によるカメラ試験（人数カウント付き) YOLOX-mでおよそ8fps  
> python .\run_yolox_bf16_camera_count.py -m .\original_yolox\models\yolox_m_op17.onnx --config_file .\vai_ep_config.json --count-person --count-thr 0.40  

#### 調整ポイント  
--score_thr 0.35  
--count-thr 0.40  


### YOLOX-m Int8へ  
INT8はキャリブレーションが必要になるため、calib_images(32枚程度)ディレクトリに画像を準備する  
あまり画像数が多いとQuarkに必要なメモリが破裂する。    
> python .\quantize_yolox_m.py   
※mは相性が良くないようで、7-9%程度のオフロード率になった。  