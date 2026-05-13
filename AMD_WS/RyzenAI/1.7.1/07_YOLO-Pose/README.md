#### YOLO-pose設定手順  
cd RyzenAI-SW_1.7.1\TEST_WS\YOLO-Pose  

conda create -n yolopose_export_env python=3.10 -y  
conda activate yolopose_export_env  
pip install ultralytics onnx onnxruntime  
python .\export_yolo11_pose_onnx.py  

conda create --name yolopose_env --clone ryzen-ai-1.7.1  
conda activate yolopose_env  

python .\probe_yolopose_onnx.py --input ..\MoveNet\test1.png --cpu  
python .\probe_yolopose_onnx.py --input ..\MoveNet\test1.png --provider_config .\vaip_config.json  

#### 画像を一枚ずつ処理CPU・NPU  
python .\run_yolo11_pose_image.py --input ..\MoveNet\test1.png --output .\yolo11n_pose_cpu.jpg --cpu
python .\run_yolo11_pose_image.py --input ..\MoveNet\test1.png --output .\yolo11n_pose_npu.jpg --provider_config .\vaip_config.json  

#### ディレクトリ内の画像を対象に処理  
python .\run_yolo11_pose_image.py --input_dir .\images --output_dir .\results_batch --provider_config .\vaip_config.json --show_box  

#### Webカメラで処理を確認する  
python .\run_yolo11_pose_camera.py --provider_config .\vaip_config.json --show_box  