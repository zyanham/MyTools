conda create --name yolov8m_env --clone ryzen-ai-1.7.1  
conda activate yolov8m_env  
cd CNN-examples\object_detection\yolov8m  
pip install -r requirements.txt  

https://github.com/ultralytics/assets/releases/download/v8.3.0/yolov8m.pt
modelsにyolov8m.ptを配置

cd models
python export_to_onnx.py
cd ../


python quantize_quark.py --input_model_path models\yolov8m.onnx --calib_data_path calib_images --output_model_path models\yolov8m_BF16.onnx --config BF16

>python run_inference.py --model_input models\yolov8m_BF16.onnx --input_image test_image.jpg --output_image test_output.jpg --device npu-bf16

python prepare_data.py

python run_inference.py --model_input models\yolov8m_BF16.onnx --evaluate --coco_dataset datasets\coco --device npu-bf16


Model Accuracy:
Evaluating model: models\yolov8m_BF16.onnx
loading annotations into memory...
Done (t=0.29s)
creating index...
index created!
100%|██████████████████████████████████████████████████████████████████████████████| 5000/5000 [04:06<00:00, 20.29it/s]
detections saved to: D:\RyzenWS\RyzenAI-SW_1.7.1\CNN-examples\object_detection\yolov8m\runs\onnx-predict\yolov8m_BF16-instances_val2017-iou=0.50\pred.json
Loading and preparing results...
DONE (t=0.15s)
creating index...
index created!
Running per image evaluation...
Evaluate annotation type *bbox*
DONE (t=5.65s).
Accumulating evaluation results...
DONE (t=0.94s).
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.429
 Average Precision  (AP) @[ IoU=0.50      | area=   all | maxDets=100 ] = 0.581
 Average Precision  (AP) @[ IoU=0.75      | area=   all | maxDets=100 ] = 0.468
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.230
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.484
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.611
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=  1 ] = 0.333
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets= 10 ] = 0.485
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.492
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.264
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.552
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.686

Per-category AP (IoU=0.5:0.95, area=all):
person               AP: 0.545
bicycle              AP: 0.347
car                  AP: 0.416
motorcycle           AP: 0.463
airplane             AP: 0.723
bus                  AP: 0.652
train                AP: 0.704
truck                AP: 0.332
boat                 AP: 0.272
traffic light        AP: 0.246
fire hydrant         AP: 0.685
stop sign            AP: 0.639
parking meter        AP: 0.469
bench                AP: 0.266
bird                 AP: 0.351
cat                  AP: 0.710
dog                  AP: 0.647
horse                AP: 0.636
sheep                AP: 0.566
cow                  AP: 0.578
elephant             AP: 0.680
bear                 AP: 0.763
zebra                AP: 0.698
giraffe              AP: 0.718
backpack             AP: 0.153
umbrella             AP: 0.445
handbag              AP: 0.149
tie                  AP: 0.353
suitcase             AP: 0.417
frisbee              AP: 0.611
skis                 AP: 0.257
snowboard            AP: 0.367
sports ball          AP: 0.366
kite                 AP: 0.406
baseball bat         AP: 0.366
baseball glove       AP: 0.379
skateboard           AP: 0.572
surfboard            AP: 0.389
tennis racket        AP: 0.564
bottle               AP: 0.373
wine glass           AP: 0.354
cup                  AP: 0.416
fork                 AP: 0.402
knife                AP: 0.217
spoon                AP: 0.224
bowl                 AP: 0.401
banana               AP: 0.227
apple                AP: 0.174
sandwich             AP: 0.383
orange               AP: 0.280
broccoli             AP: 0.205
carrot               AP: 0.215
hot dog              AP: 0.346
pizza                AP: 0.559
donut                AP: 0.428
cake                 AP: 0.375
chair                AP: 0.312
couch                AP: 0.411
potted plant         AP: 0.296
bed                  AP: 0.409
dining table         AP: 0.269
toilet               AP: 0.627
tv                   AP: 0.569
laptop               AP: 0.637
mouse                AP: 0.592
remote               AP: 0.317
keyboard             AP: 0.500
cell phone           AP: 0.362
microwave            AP: 0.599
oven                 AP: 0.361
toaster              AP: 0.418
sink                 AP: 0.375
refrigerator         AP: 0.625
book                 AP: 0.116
clock                AP: 0.483
vase                 AP: 0.384
scissors             AP: 0.335
teddy bear           AP: 0.502
hair drier           AP: 0.020
toothbrush           AP: 0.296
COCO evaluation results saved to: D:\RyzenWS\RyzenAI-SW_1.7.1\CNN-examples\object_detection\yolov8m\runs\onnx-predict\yolov8m_BF16-instances_val2017-iou=0.50\coco-metrics.json
models\yolov8m_BF16.onnx model accuracy on npu-bf16: mAP 42.862, mAP50 58.109, mAP75 46.797

python quantize_quark.py --input_model_path models/yolov8m.onnx --calib_data_path calib_images --output_model_path models/yolov8m_XINT8.onnx --config XINT8  

python run_inference.py --model_input models\yolov8m_XINT8.onnx --input_image test_image.jpg --output_image test_output_int8.jpg --device npu-int8

python run_inference.py --model_input models\yolov8m_XINT8.onnx --evaluate --coco_dataset datasets\coco --device npu-int8


python quantize_quark.py --input_model_path models/yolov8m.onnx --calib_data_path calib_images --output_model_path models/yolov8m_XINT8.onnx --config XINT8 --exclude_subgraphs "[/model.22/Concat_3], [/model.22/Concat_10]]"
 
python prepare_data.py  

python run_inference.py --model_input models\yolov8m_XINT8.onnx --evaluate --coco_dataset datasets\coco --device npu-int8

(yolov8m_env) D:\RyzenWS\RyzenAI-SW_1.7.1\CNN-examples\object_detection\yolov8m>python run_inference.py --model_input models\yolov8m_BF16.onnx --input_image test_image.jpg --output_image test_output.jpg --device npu-bf16 --benchmark
Running BF16 Model on NPU
Model Performance:
Avg time for each inference run:0.031 seconds
Model performance:32.8 FPS

XINT8が環境で動かず。原因は不明
(yolov8m_env) D:\RyzenWS\RyzenAI-SW_1.7.1\CNN-examples\object_detection\yolov8m>python run_inference.py --model_input models\yolov8m_XINT8.onnx --input_image test_image.jpg --output_image test_output.jpg --device npu-int8 --benchmark
Running INT8 Model on NPU
check failure: node != nullptrcannot find producer. onnx_node_arg_name=/model.22/Slice_output_0_QuantizeLinear_Output