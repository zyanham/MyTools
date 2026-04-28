cd CNN-examples\super-resolution
conda create --name sr_env --clone ryzen-ai-1.7.1  
conda activate sr_env  

git clone https://hf.co/amd/realesrgan-128x128-tiles-amdnpu
git clone https://hf.co/amd/realesrgan-256x256-tiles-amdnpu
git clone https://hf.co/amd/realesrgan-512x512-tiles-amdnpu
git clone https://hf.co/amd/realesrgan-1024x1024-tiles-amdnpu
cd realesrgan-256x256-tiles-amdnpu

pip install -r requirements.txt  

python onnx_inference.py --onnx onnx-models/realesrgan_nchw_256x256_u8s8.onnx --input assets/input_tiger_320x480_108005.png --out-dir outputs --device npu

(sr_env) D:\RyzenWS\RyzenAI-SW_1.7.1\CNN-examples\super-resolution\realesrgan-256x256-tiles-amdnpu>python onnx_inference.py --onnx onnx-models/realesrgan_nchw_256x256_u8s8.onnx --input assets/input_tiger_320x480_108005.png --out-dir outputs --device npu
Creating ONNX runner...
Using NPU type: STX
Running inference with providers: ['VitisAIExecutionProvider']
2026-04-24 09:28:47.2155632 [W:onnxruntime:, session_state.cc:1316 onnxruntime::VerifyEachNodeIsAssignedToAnEp] Some nodes were not assigned to the preferred execution providers which may or may not have an negative impact on performance. e.g. ORT explicitly assigns shape related ops to CPU to improve perf.
2026-04-24 09:28:47.2216251 [W:onnxruntime:, session_state.cc:1318 onnxruntime::VerifyEachNodeIsAssignedToAnEp] Rerunning with verbose output on a non-minimal build will show node assignments.
ONNX runner created successfully
Input image shape (BGR HWC): (320, 480, 3)
Preprocessed image shape (RGB CHW): (3, 320, 480)
Tiling to 6 tiles of size 256x256 (overlap: 16px)
Number of tiles: 6, Tile shape: (3, 256, 256)
Model input shape: (1, 3, 256, 256), Format: nchw
Processing tiles: 100%|█████████████████████████████████████████████████████████████████████████| 6/6 [00:01<00:00,  3.36tile/s]
Output SR tile shape: (3, 1024, 1024)
Output SR image shape (BGR HWC): (1280, 1920, 3)
saved outputs\input_tiger_320x480_108005.png


