## Ryzen AI Software 1.8.0のディレクトリ以下にTEST_WS\DnCNNのディレクトリを作成して、スクリプトをコピーする  
> cd RyzenAI-SW_1.8.0\TEST_WS\DnCNN  
> conda create --name dncnn_env --clone ryzen-ai-1.8.0  
> conda activate dncnn_env  

ここから下記のトレーニング済み環境をクローンする  
git clone https://github.com/cszn/KAIR.git  

このDnCNNをダウンロードする  
python .\KAIR\main_download_pretrained_models.py --models "dncnn_color_blind.pth" --model_dir "weights"  
  
python export_dncnn_onnx.py --weights .\weights\dncnn_color_blind.pth --output .\KAIR\models\dncnn_color_blind_360x640.onnx --height 360 --width 640  
  
#### 重みをxint8に量子化する  
まずはキャリブレーション画像にノイズを添加する  
> python make_noisy_calib_images.py --dir .\calib_images --sigma 20  

次にAMD Quarkだけに使用する仮想環境を設定する。  
> conda create -n dncnn_quark python=3.12 -y  
> conda activate dncnn_quark  
> pip install numpy==1.26.4  
> pip install amd-quark==0.11  
> pip install torch==2.8.0  
> pip install onnxsim  
> pip install ultralytics==8.3.155  
> pip install onnxruntime==1.22.1  
  
次に量子化を実行する  
> python quantize_dncnn_quark.py --input_model KAIR\models\dncnn_color_blind_360x640.onnx --output_model KAIR\models\dncnn_color_blind_XINT8.onnx --calib_dir calib_clean --sigma_min 20 --sigma_max 20 --samples_per_image 2 --method adaround  
  
> conda activate dncnn_env  

## Image TEST CPU  
python .\run_dncnn_image.py --model .\KAIR\models\dncnn_color_blind_360x640.onnx --input_image .\test_image.png --output_image .\results\dncnn_test.png --device cpu  

## Web Camera TEST CPU  
python .\run_dncnn_camera.py --model .\KAIR\models\dncnn_color_blind_360x640.onnx --device cpu --model_width 640 --model_height 360  
  
  
# BF16  

## Web Camera TEST NPU
python .\run_dncnn_camera.py --model .\KAIR\models\dncnn_color_blind_360x640.onnx --device npu --model_width 640 --model_height 360  
  
## Web Camera TEST NPU(人口ガウシアンノイズを入力画像に追加 差分追加)  
python .\run_dncnn_camera.py --model .\KAIR\models\dncnn_color_blind_360x640.onnx --device npu --strength 1.0 --demo_noise_sigma 20 --show_diff  
  
## Web Camera TEST NPU(人口ガウシアンノイズを入力画像に追加)  
python .\run_dncnn_camera.py --model .\KAIR\models\dncnn_color_blind_360x640.onnx --device npu --strength 1.0 --demo_noise_sigma 20  
  
# XINT8  

## Web Camera TEST NPU
python .\run_dncnn_camera.py --model .\KAIR\models\dncnn_color_blind_XINT8.onnx --device npu --model_width 640 --model_height 360  
  
## Web Camera TEST NPU(人口ガウシアンノイズを入力画像に追加 差分追加)  
python .\run_dncnn_camera.py --model .\KAIR\models\dncnn_color_blind_XINT8.onnx --device npu --strength 1.0 --demo_noise_sigma 20 --show_diff  
  
## Web Camera TEST NPU(人口ガウシアンノイズを入力画像に追加)  
python .\run_dncnn_camera.py --model .\KAIR\models\dncnn_color_blind_XINT8.onnx --device npu --strength 1.0 --demo_noise_sigma 20  
