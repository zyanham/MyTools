#!/bin/bash
# Copyright 2022 Xilinx Inc.

cd Vitis-AI_v3.5

docker run --device=/dev/dri/renderD128 \
      -v /dev/shm:/dev/shm \
      -v /opt/xilinx/dsa:/opt/xilinx/dsa \
      -v /opt/xilinx/overlaybins:/opt/xilinx/overlaybins \
      -e USER=meowth -e UID=1000 -e GID=1000 \
      -v /home/meowth/Desktop/MyTools/XILINX_WS/Vitis-AI/Vitis-AI_v3.5:/vitis_ai_home \
      -v /home/meowth/Desktop/MyTools/XILINX_WS/Vitis-AI/Vitis-AI_v3.5:/workspace \
      -w /workspace \
      --rm \
      --network=host \
      -it xilinx/vitis-ai-pytorch-gpu:3.5.0.001-7a0d5a695 bash
