#! /bin/bash

#git clone -b v3.5 https://github.com/Xilinx/Vitis-AI.git

cd Vitis-AI/model_zoo
#mkdir -p work/d2k
#mkdir -p work/quant

cd work/d2k
#git clone https://github.com/qqwweee/keras-yolo3.git

cd ../quant
#wget https://www.xilinx.com/bin/public/openDownload?filename=tf2_yolov3_coco_416_416_65.9G_2.5.zip -O tf2_yolov3_coco_416_416_65.9G_2.5.zip
#unzip tf2_yolov3_coco_416_416_65.9G_2.5.zip
cd tf2_yolov3_coco_416_416_65.9G_2.5/code/test
#mkdir float

cd ../../../../d2k/keras-yolo3
#wget https://pjreddie.com/media/files/yolov3-tiny.weights

#sed -i 's/from keras.layers.normalization/from keras.layers/' convert.py
#python3 convert.py yolov3-tiny.cfg yolov3-tiny.weights model_data/yolov3-tiny.h5

#mkdir -p ../../quant/tf2_yolov3_coco_416_416_65.9G_2.5/code/test/float
#cp model_data/yolov3-tiny.h5 ../../quant/tf2_yolov3_coco_416_416_65.9G_2.5/code/test/float

cd ../../quant/tf2_yolov3_coco_416_416_65.9G_2.5/code/test/
#sed -i 's/python /python3 /' convert_data.sh

#bash download_data.sh
cd ../../data
#ln -s ../code/test/annotations .
#ln -s ../code/test/val2017 .
cd ../
#bash ./code/test/convert_data.sh



pwd

