## Ryzen AI Software 1.7.1のディレクトリ以下にTEST_WS\DnCNNのディレクトリを作成  
  
cd RyzenAI-SW_1.7.1\TEST_WS\DnCNN  
  
conda create --name dncnn_env --clone ryzen-ai-1.7.1  
conda activate dncnn_env  
  
git clone https://github.com/cszn/KAIR.git  
  
python .\KAIR\main_download_pretrained_models.py --models "dncnn_color_blind.pth" --model_dir "weights"  
  
python export_dncnn_onnx.py --weights .\weights\dncnn_color_blind.pth --output .\models\dncnn_color_blind_360x640.onnx --height 360 --width 640  
  
  
## Image TEST CPU  
python .\run_dncnn_image.py --model .\models\dncnn_color_blind_360x640.onnx --input_image .\test_image.jpg --output_image .\results\dncnn_test.jpg --device cpu  
  
## Web Camera TEST CPU  
python .\run_dncnn_camera.py --model .\models\dncnn_color_blind_360x640.onnx --device cpu --model_width 640 --model_height 360  
  
## Web Camera TEST NPU
python .\run_dncnn_camera.py --model .\models\dncnn_color_blind_360x640.onnx --device npu --model_width 640 --model_height 360  
  
## Web Camera TEST NPU(人口ガウシアンノイズを入力画像に追加 差分追加)  
python .\run_dncnn_camera.py --model .\models\dncnn_color_blind_360x640.onnx --device npu --strength 1.0 --demo_noise_sigma 20 --show_diff  
  
## Web Camera TEST NPU(人口ガウシアンノイズを入力画像に追加)  
python .\run_dncnn_camera.py --model .\models\dncnn_color_blind_360x640.onnx --device npu --strength 1.0 --demo_noise_sigma 20  
