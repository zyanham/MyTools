#### YOLOv8m Environment  
> conda create --name yolov8_env --clone ryzen-ai-1.7.0  

##### Ryzen AI Software 1.7.0をクローンして必要なディレクトリを取り出す  
> git clone https://github.com/amd/RyzenAI-SW.git -b v1.7.0  
> mv RyzenAI-SW/CNN-examples/object_detection/yolov8m .  
> cd yolov8m  

> pip install -r requirements.txt  
> wget https://github.com/ultralytics/assets/releases/download/v8.3.0/yolov8m.pt -O models/yolov8m.pt  
> cd models  
> python export_to_onnx.py  
> cd ../  
> python quantize_quark.py --input_model_path models\yolov8m.onnx --calib_data_path calib_images --output_model_path models\yolov8m_BF16.onnx --config BF16  
> python run_inference.py --model_input models\yolov8m_BF16.onnx --input_image test_image.jpg --output_image test_output.jpg --device npu-bf16  

##### Default YOLOv8m  
> python run_webcam.py --model_input models\yolov8m_BF16.onnx --device npu-bf16 --camera 0 --show  

##### 640x480 YOLOv8m  
> python run_webcam.py --model_input models\yolov8m_BF16.onnx --device npu-bf16 --camera 0 --backend dshow --cam_width 640 --cam_height 480 --cam_fps 30 --fourcc MJPG --show  

int8はまだ試していないが、速度は向上するハズ。