> conda create --name resnet_bf16 --clone ryzen-ai-1.7.1  
> set RYZEN_AI_INSTALLATION_PATH = C:\Program Files\RyzenAI\1.7.1  
> cd CNN-examples\getting_started_resnet\bf16  
> python -m pip install -r requirements.txt  
> python prepare_model_data.py  
> python compile.py --model models\resnet_trained_for_cifar10.onnx  
  
> python predict.py  

'''  
execution started on CPU  
Image 0: Actual Label cat, Predicted Label cat  
Image 1: Actual Label ship, Predicted Label ship  
Image 2: Actual Label ship, Predicted Label ship  
Image 3: Actual Label airplane, Predicted Label airplane  
Image 4: Actual Label frog, Predicted Label frog  
Image 5: Actual Label frog, Predicted Label frog  
Image 6: Actual Label automobile, Predicted Label truck  
Image 7: Actual Label frog, Predicted Label frog  
Image 8: Actual Label cat, Predicted Label cat  
Image 9: Actual Label automobile, Predicted Label automobile  
'''  
  
> python predict.py --ep npu  

'''  
execution started on NPU  
Image 0: Actual Label cat, Predicted Label cat  
Image 1: Actual Label ship, Predicted Label ship  
Image 2: Actual Label ship, Predicted Label ship  
Image 3: Actual Label airplane, Predicted Label airplane  
Image 4: Actual Label frog, Predicted Label frog  
Image 5: Actual Label frog, Predicted Label frog  
Image 6: Actual Label automobile, Predicted Label truck  
Image 7: Actual Label frog, Predicted Label frog  
Image 8: Actual Label cat, Predicted Label cat  
Image 9: Actual Label automobile, Predicted Label automobile  
'''  