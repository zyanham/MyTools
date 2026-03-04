#### FFDNet(Denoise)  
Exportだけ入れる環境を構築  
> conda create -n ffdnet_export python=3.10 -y  
> conda activate ffdnet_export  
> pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu  
> pip install opencv-python requests  

srcにあるソースを展開。  
> mkdir images model_zoo  
> mv src/*.py .  

フルカラーffdnetの学習済み重み入手  
> python get_ffdnet.py

大小のONNXモデルに変換  
> python export_ffdnet_onnx.py --h 544 --w 960 --out ffdnet_color_544x960_op17.onnx  
> python export_ffdnet_onnx.py --h 1088 --w 1920 --out ffdnet_color_1088x1920_op17.onnx  

仮想環境をスイッチ  
> conda activate ryzen-ai-1.7.0  

FP32で動作確認を実施（静止画）
> python run_rai_ffdnet_image.py --onnx ffdnet_color_544x960_op17.onnx --input images\test.jpg --out out_ffdnet_544x960_fp32.png --device npu --h 544 --w 960 --fit resize --sigma 15 --warmup 5 --repeat 30 --cache_dir C:\vaip_cache --cache_key ffdnet_544x960_fp32  

sigma 15 は目安。暗所なら増やす、明所なら下げる。  
cache_key はモデル/解像度/量子化ごとに変える（混線防止）  

##### 量子化  
> python -X utf8 ffdnet_quantize_int8.py --fp32 ffdnet_color_544x960_op17.onnx --out  ffdnet_color_544x960_a16w8.onnx --calib_dir images --h 544 --w 960 --sigma 15 --samples 128 --dtype A16W8 --input_name input --sigma_name sigma  

動作確認  
python run_rai_ffdnet_image.py --onnx ffdnet_color_544x960_a16w8.onnx --input images\test.jpg --out out_ffdnet_544x960_a16w8.png --device npu --h 544 --w 960 --fit resize --sigma 15 --warmup 5 --repeat 30 --cache_dir C:\vaip_cache --cache_key ffdnet_544x960_a16w8  

>python run_rai_ffdnet_camera.py --onnx ffdnet_color_544x960_xint8.onnx --device npu --cam 0 --backend dshow --fourcc MJPG --req_w 1920 --req_h 1080 --req_fps 30 --proc_w 960 --proc_h 544 --sigma 15 --view upscale --side_by_side --cache_dir vaip_cache --cache_key ffdnet_cam_a16w8  

# Generate FFDNET Full HD version
python export_ffdnet_onnx.py --h 1088 --w 1920 --out ffdnet_color_1088x1920_op17.onnx  

# TEST
python run_rai_ffdnet_image.py --onnx ffdnet_color_1080x1920_op17.onnx --input images\test02.jpg --out out_ffdnet_fhd_fp32.png --device npu --h 1080 --w 1920 --fit resize --sigma 15 --warmup 5 --repeat 30 --cache_dir vaip_cache --cache_key ffdnet_1080_1920_fp32  
モデル自体はFP32でも、EP側で BF16に変換してNPUコンパイルして走ることがある(要確認)  