#### YOLO8mをRyzen NPUで実行する  
[Issue-385に記載あり](https://github.com/amd/RyzenAI-SW/issues/385)  
Ryzen AI 1.8以降、量子​​化のためのAMD QuarkツールはRyzen AI仮想環境にバンドルされなくなった。  
これに関連することかはわからないが、ユーザーがpipでQuarkとtorchvisionをrequirement.txtでインストールすると、  
バージョン不一致が発生してインストールがストレートに終わらない。  
このため、ユーザーはQuark専用の環境を別の仮想環境で準備する必要がありそうだ。  
ここではひとまずQuark用の環境と実行環境を分けて実施することで解決する。  
  
※ExportはRyzenAI 1.8.0のクローン環境で実行する必要がある。  
これはrequirement.txtの公正でないとOnnxruntimeのOpset17で実行できないため。  
Opset17でないとPytrochの重みをONNXに変換時に、RAI Softwareのチュートリアル通りのSubgraph名ではなくなり、  
量子化がチュートリアル通りに再現できなくなるため。  

> conda create --name yolov8m_env --clone ryzen-ai-1.8.0  
> conda activate yolov8m_env  
> cd CNN-examples\object_detection\yolov8m  
> pip install -r requirements.txt  
> pip install onnxsim  
  
[リンク](https://github.com/ultralytics/assets/releases/download/v8.3.0/yolov8m.pt) から重みをダウンロードして、  
  
modelsにyolov8m.ptを配置  
  
> cd models  
> python export_to_onnx.py  
> cd ../  
  
次にAMD Quarkだけに使用する仮想環境を設定する。  
> conda create -n yolov8m_quark python=3.12 -y  
> conda activate yolov8m_quark  
> pip install numpy==1.26.4  
> pip install amd-quark==0.11  
> pip install torch==2.8.0  
> pip install onnxsim  
> pip install ultralytics==8.3.155  
> pip install onnxruntime==1.22.1  
  
#### AMD Quarkをかける  
FP32をコンパイラで自動にBF16に変換することも可能だが、  
事前にQuarkかけて狙った制約をかけて事前にBF16にすることもできる。  
> python quantize_quark.py --input_model_path models\yolov8m.onnx --calib_data_path calib_images --output_model_path models\yolov8m_BF16.onnx --config BF16  
  
ただ単純に全体をInt8に量子化すると精度が著しく落ちるため、  
一部の制約をもって量子化するようにガイドラインが記載されている。  
https://github.com/amd/RyzenAI-SW/tree/1.8.0/CNN-examples/object_detection/yolov8m  
ここではキャリブレーション画像も大事なのでcalib_imageにキャリブレーション用の画像を配置する。  
YOLO8mの検出対象を様々準備する。ここの画像の枚数分メモリを使用するため、キャリブレーションは大型のPCを準備してもよい。  
  
ガイドラインに沿ってサブグラフを指定（除外）して量子化を行う。  
> python quantize_quark.py --input_model_path models/yolov8m.onnx --calib_data_path calib_images --output_model_path models/yolov8m_XINT8.onnx --config XINT8 --exclude_subgraphs "[/model.22/Concat_3], [/model.22/Concat_10]]"  
  
ここで再び、Ryzen ai 1.8.0の仮想環境に戻す。  
#> conda create --name yolov8m_env --clone ryzen-ai-1.8.0  
> conda activate yolov8m_env  
#> cd CNN-examples\object_detection\yolov8m  
#> pip install -r requirements.txt  
#> pip install onnxsim  
  
テスト画像に対して推論を実行する。  
この時自動でコンパイルとテスト実行が行われる  
  
※このrun_inference.pyスクリプトはキャッシュファイルがmodelcachekeyという固定パスになっているので、  
　実行精度をBF16->INT8などに変更する場合は一度キャッシュを削除するか名称変更してキープすること。  
  
> python run_inference.py --model_input models\yolov8m_BF16.onnx --input_image test_image.jpg --output_image test_output.jpg --device npu-bf16  
  
Cocoデータセットを一部落としてくるスクリプト  
> python prepare_data.py  
  
落としてきたCocoデータセットを使って精度評価するスクリプト  
> python run_inference.py --model_input models\yolov8m_BF16.onnx --evaluate --coco_dataset datasets\coco --device npu-bf16  
  
'''  
Running BF16 Model on NPU  
WARNING: Logging before InitGoogleLogging() is written to STDERR  
I20260826 09:56:12.906281 14252 register_dynamicdispatch.cpp:49] Running DynamicDispatchOpRegister::register_ops  
I20260826 09:56:12.906281 14252 register_castavx.cpp:48] Running CastAvxOpRegister::register_ops  
2026-08-26 09:56:13.3000505 [W:onnxruntime:, vaiml_config.hpp:761 vaiml_config.hpp] logging_level option in VAIML pass will be deprecated soon. Please use log_level provider option instead.  
Model Accuracy:  
Evaluating model: models\yolov8m_BF16.onnx  
loading annotations into memory...  
Done (t=0.29s)  
creating index...  
index created!  
100%|███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 5000/5000 [03:34<00:00, 23.27it/s]  
detections saved to:   D:\RyzenWS\RyzenAI-SW_1.8.0\CNN-examples\object_detection\yolov8m\runs\onnx-predict\yolov8m_BF16-instances_val2017-iou=0.50\pred.json  
Loading and preparing results...  
DONE (t=0.15s)  
creating index...  
index created!  
Running per image evaluation...  
Evaluate annotation type *bbox*  
DONE (t=5.86s).  
Accumulating evaluation results...  
DONE (t=0.91s).  
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.430  
 Average Precision  (AP) @[ IoU=0.50      | area=   all | maxDets=100 ] = 0.581  
 Average Precision  (AP) @[ IoU=0.75      | area=   all | maxDets=100 ] = 0.469  
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.231  
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.486  
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.611  
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=  1 ] = 0.334  
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets= 10 ] = 0.486  
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.493  
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.265  
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.552  
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.686  
  
Per-category AP (IoU=0.5:0.95, area=all):  
person               AP: 0.545  
bicycle              AP: 0.345  
car                  AP: 0.417  
motorcycle           AP: 0.462  
airplane             AP: 0.727  
bus                  AP: 0.653  
train                AP: 0.704  
truck                AP: 0.329  
boat                 AP: 0.272  
traffic light        AP: 0.244  
fire hydrant         AP: 0.692  
stop sign            AP: 0.638  
parking meter        AP: 0.465  
bench                AP: 0.266  
bird                 AP: 0.354  
cat                  AP: 0.709  
dog                  AP: 0.650  
horse                AP: 0.634  
sheep                AP: 0.566  
cow                  AP: 0.583  
elephant             AP: 0.680  
bear                 AP: 0.762  
zebra                AP: 0.701  
giraffe              AP: 0.719  
backpack             AP: 0.152  
umbrella             AP: 0.444  
handbag              AP: 0.147  
tie                  AP: 0.353  
suitcase             AP: 0.422  
frisbee              AP: 0.619  
skis                 AP: 0.255  
snowboard            AP: 0.368  
sports ball          AP: 0.369  
kite                 AP: 0.408  
baseball bat         AP: 0.370  
baseball glove       AP: 0.382  
skateboard           AP: 0.570  
surfboard            AP: 0.389  
tennis racket        AP: 0.565  
bottle               AP: 0.374  
wine glass           AP: 0.355  
cup                  AP: 0.417  
fork                 AP: 0.403  
knife                AP: 0.216  
spoon                AP: 0.227  
bowl                 AP: 0.401  
banana               AP: 0.228  
apple                AP: 0.175  
sandwich             AP: 0.388  
orange               AP: 0.283  
broccoli             AP: 0.205  
carrot               AP: 0.213  
hot dog              AP: 0.347  
pizza                AP: 0.558  
donut                AP: 0.429  
cake                 AP: 0.377  
chair                AP: 0.312  
couch                AP: 0.410  
potted plant         AP: 0.298  
bed                  AP: 0.410  
dining table         AP: 0.268  
toilet               AP: 0.621  
tv                   AP: 0.571  
laptop               AP: 0.641  
mouse                AP: 0.597  
remote               AP: 0.315  
keyboard             AP: 0.502  
cell phone           AP: 0.361  
microwave            AP: 0.610  
oven                 AP: 0.362  
toaster              AP: 0.435  
sink                 AP: 0.375  
refrigerator         AP: 0.629  
book                 AP: 0.116  
clock                AP: 0.483  
vase                 AP: 0.382  
scissors             AP: 0.339  
teddy bear           AP: 0.503  
hair drier           AP: 0.020  
toothbrush           AP: 0.298  
COCO evaluation results saved to: D:\RyzenWS\RyzenAI-SW_1.8.0\CNN-examples\object_detection\yolov8m\runs\onnx-predict\yolov8m_BF16-instances_val2017-iou=0.50\coco-metrics.json  
models\yolov8m_BF16.onnx model accuracy on npu-bf16: mAP 42.978, mAP50 58.129, mAP75 46.913  
'''  
  
int8で同じように実行する  
python run_inference.py --model_input models\yolov8m_XINT8.onnx --input_image test_image.jpg --output_image test_output_int8.jpg --device npu-int8  
python run_inference.py --model_input models\yolov8m_XINT8.onnx --evaluate --coco_dataset datasets\coco --device npu-int8  

'''  
Running INT8 Model on NPU  
WARNING: Logging before InitGoogleLogging() is written to STDERR  
I20260826 10:12:06.302851 32772 register_dynamicdispatch.cpp:49] Running DynamicDispatchOpRegister::register_ops
I20260826 10:12:06.302851 32772 register_castavx.cpp:48] Running CastAvxOpRegister::register_ops  
2026-08-26 10:12:06.5487173 [W:onnxruntime:, session_state.cc:1367 onnxruntime::VerifyEachNodeIsAssignedToAnEp] Some nodes were not assigned to the preferred execution providers which may or may not have an negative impact on performance. e.g. ORT explicitly assigns shape related ops to CPU to improve perf.  
2026-08-26 10:12:06.5532941 [W:onnxruntime:, session_state.cc:1369 onnxruntime::VerifyEachNodeIsAssignedToAnEp] Rerunning with verbose output on a non-minimal build will show node assignments.  
Model Accuracy:  
Evaluating model: models\yolov8m_XINT8.onnx  
loading annotations into memory...  
Done (t=0.29s)  
creating index...  
index created!  
100%|███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 5000/5000 [03:18<00:00, 25.23it/s]  
detections saved to: D:\RyzenWS\RyzenAI-SW_1.8.0\CNN-examples\object_detection\yolov8m\runs\onnx-predict\yolov8m_XINT8-instances_val2017-iou=0.50\pred.json  
Loading and preparing results...  
DONE (t=0.16s)  
creating index...  
index created!  
Running per image evaluation...  
Evaluate annotation type *bbox*  
DONE (t=6.05s).  
Accumulating evaluation results...  
DONE (t=1.08s).  
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.380  
 Average Precision  (AP) @[ IoU=0.50      | area=   all | maxDets=100 ] = 0.517  
 Average Precision  (AP) @[ IoU=0.75      | area=   all | maxDets=100 ] = 0.413  
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.218  
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.432  
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.501  
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=  1 ] = 0.310  
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets= 10 ] = 0.446  
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.453  
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.256  
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.507  
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.601  
  
Per-category AP (IoU=0.5:0.95, area=all):  
person               AP: 0.530  
bicycle              AP: 0.317  
car                  AP: 0.408  
motorcycle           AP: 0.418  
airplane             AP: 0.643  
bus                  AP: 0.646  
train                AP: 0.652  
truck                AP: 0.319  
boat                 AP: 0.218  
traffic light        AP: 0.225  
fire hydrant         AP: 0.656  
stop sign            AP: 0.606  
parking meter        AP: 0.413  
bench                AP: 0.248  
bird                 AP: 0.314  
cat                  AP: 0.601  
dog                  AP: 0.549  
horse                AP: 0.592  
sheep                AP: 0.494  
cow                  AP: 0.518  
elephant             AP: 0.616  
bear                 AP: 0.569  
zebra                AP: 0.658  
giraffe              AP: 0.711  
backpack             AP: 0.104  
umbrella             AP: 0.383  
handbag              AP: 0.118  
tie                  AP: 0.295  
suitcase             AP: 0.318  
frisbee              AP: 0.606  
skis                 AP: 0.209  
snowboard            AP: 0.361  
sports ball          AP: 0.393  
kite                 AP: 0.339  
baseball bat         AP: 0.325  
baseball glove       AP: 0.337  
skateboard           AP: 0.522  
surfboard            AP: 0.338  
tennis racket        AP: 0.525  
bottle               AP: 0.329  
wine glass           AP: 0.323  
cup                  AP: 0.382  
fork                 AP: 0.327  
knife                AP: 0.154  
spoon                AP: 0.151  
bowl                 AP: 0.375  
banana               AP: 0.201  
apple                AP: 0.123  
sandwich             AP: 0.271  
orange               AP: 0.242  
broccoli             AP: 0.162  
carrot               AP: 0.154  
hot dog              AP: 0.279  
pizza                AP: 0.517  
donut                AP: 0.383  
cake                 AP: 0.310  
chair                AP: 0.285  
couch                AP: 0.359  
potted plant         AP: 0.250  
bed                  AP: 0.314  
dining table         AP: 0.243  
toilet               AP: 0.563  
tv                   AP: 0.506  
laptop               AP: 0.621  
mouse                AP: 0.596  
remote               AP: 0.243  
keyboard             AP: 0.485  
cell phone           AP: 0.275  
microwave            AP: 0.533  
oven                 AP: 0.325  
toaster              AP: 0.260  
sink                 AP: 0.347  
refrigerator         AP: 0.550  
book                 AP: 0.094  
clock                AP: 0.478  
vase                 AP: 0.323  
scissors             AP: 0.256  
teddy bear           AP: 0.415  
hair drier           AP: 0.040  
toothbrush           AP: 0.257  
COCO evaluation results saved to: D:\RyzenWS\RyzenAI-SW_1.8.0\CNN-examples\object_detection\yolov8m\runs\onnx-predict\yolov8m_XINT8-instances_val2017-iou=0.50\coco-metrics.json  
models\yolov8m_XINT8.onnx model accuracy on npu-int8: mAP 37.991, mAP50 51.666, mAP75 41.305  
'''  

(yolov8m_env) D:\RyzenWS\RyzenAI-SW_1.8.0\CNN-examples\object_detection\yolov8m>python run_inference.py --model_input models\yolov8m_BF16.onnx --input_image test_image.jpg --output_image test_output.jpg --device npu-bf16 --benchmark  
'''  
Running BF16 Model on NPU  
WARNING: Logging before InitGoogleLogging() is written to STDERR  
I20260826 10:16:59.688848 31492 register_dynamicdispatch.cpp:49] Running DynamicDispatchOpRegister::register_ops  
I20260826 10:16:59.688848 31492 register_castavx.cpp:48] Running CastAvxOpRegister::register_ops  
2026-08-26 10:17:00.0829092 [W:onnxruntime:, vaiml_config.hpp:761 vaiml_config.hpp] logging_level option in VAIML pass will be deprecated soon. Please use log_level provider option instead.  
Model Performance:  
Avg time for each inference run:0.027 seconds  
Model performance:37.3 FPS  
'''  
  
(yolov8m_env) D:\RyzenWS\RyzenAI-SW_1.8.0\CNN-examples\object_detection\yolov8m>python run_inference.py --model_input models\yolov8m_XINT8.onnx --input_image test_image.jpg --output_image test_output.jpg --device npu-int8 --benchmark  
'''  
Running INT8 Model on NPU  
WARNING: Logging before InitGoogleLogging() is written to STDERR  
I20260826 10:47:47.497201 17884 register_dynamicdispatch.cpp:49] Running DynamicDispatchOpRegister::register_ops  
I20260826 10:47:47.497201 17884 register_castavx.cpp:48] Running CastAvxOpRegister::register_ops  
2026-08-26 10:47:47.7431250 [W:onnxruntime:, session_state.cc:1367 onnxruntime::VerifyEachNodeIsAssignedToAnEp] Some nodes were not assigned to the preferred execution providers which may or may not have an negative impact on performance. e.g. ORT explicitly assigns shape related ops to CPU to improve perf.  
2026-08-26 10:47:47.7466764 [W:onnxruntime:, session_state.cc:1369 onnxruntime::VerifyEachNodeIsAssignedToAnEp] Rerunning with verbose output on a non-minimal build will show node assignments.  
Model Performance:  
Avg time for each inference run:0.025 seconds  
Model performance:39.5 FPS  
'''  