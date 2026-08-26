#### YOLO-pose設定手順  
cd RyzenAI-SW_1.8.0\TEST_WS\YOLO-Pose  

conda create -n yolopose_export_env python=3.10 -y  
conda activate yolopose_export_env  
pip install ultralytics onnx onnxruntime  
python .\export_yolo11_pose_onnx.py  

次にAMD Quarkだけに使用する仮想環境を設定する。 
calib_imagesの準備もする。 
> conda create -n yolov8m_quark python=3.12 -y  
> conda activate yolov8m_quark  
> pip install numpy==1.26.4  
> pip install amd-quark==0.11  
> pip install torch==2.8.0  
> pip install onnxsim  
> pip install ultralytics==8.3.155  
> pip install onnxruntime==1.22.1  

python quantize_yolo11_pose_quark.py --input_model yolo11n-pose.onnx --calib_dir calib_images --output_model yolo11n-pose_XINT8.onnx

conda create --name yolopose_env --clone ryzen-ai-1.8.0  
conda activate yolopose_env  

python .\probe_yolopose_onnx.py --input ..\MoveNet\test1.png --cpu  
python .\probe_yolopose_onnx.py --input ..\MoveNet\test1.png --provider_config .\vaip_config.json  
python .\probe_yolopose_onnx.py --model yolo11n-pose_XINT8.onnx --input ..\MoveNet\test1.png --provider_config .\vaip_config.json  

#### 画像を一枚ずつ処理CPU・NPU  
python .\run_yolo11_pose_image.py --input ..\MoveNet\test1.png --output .\yolo11n_pose_cpu.jpg --cpu
python .\run_yolo11_pose_image.py --input ..\MoveNet\test1.png --output .\yolo11n_pose_npu.jpg --provider_config .\vaip_config.json  

#### ディレクトリ内の画像を対象に処理  
python .\run_yolo11_pose_image.py --input_dir .\images --output_dir .\results_batch --provider_config .\vaip_config.json --show_box  

#### Webカメラで処理を確認する  
python .\run_yolo11_pose_camera.py --provider_config .\vaip_config.json --show_box  