#### lraspp_mobilenetv3設定手順  
cd RyzenAI-SW_1.7.1\TEST_WS\LRASPP_MNV3  
  
##### images,weights, resultsディレクトリを作成し、imagesにはテスト画像を置く。  
cd weights  

conda create --name lraspp_mnv3_env --clone ryzen-ai-1.7.1  
conda activate lraspp_mnv3_env  

pip install torch torchvision onnx onnxsim  
python export.py  

#### 単一画像のNPU実施  
python run_npu_image.py --input images\test.png --show  
  
#### ディレクトリ一括処理  
python run_npu_dir.py --input_dir images  
  
#### Webカメラによる実施  
python run_npu_camera.py  
