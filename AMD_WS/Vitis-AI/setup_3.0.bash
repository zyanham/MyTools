#! /bin/bash

cd ../XRT/v2022.2
bash setup.bash
cd ../../Vitis-AI
source /opt/xilinx/xrt/setup.sh

source /opt/Xilinx/Vitis/2022.2/settings64.sh
source /opt/Petalinux2022.2/settings.sh

git clone -b v3.0 https://github.com/Xilinx/Vitis-AI.git
mv Vitis-AI Vitis-AI_3.0

mkdir Download
cd Download

wget https://www.xilinx.com/bin/public/openDownload?filename=DPUCZDX8G_VAI_v3.0.tar.gz -O DPUCZDX8G_VAI_v3.0.tar.gz
tar -zxvf DPUCZDX8G_VAI_v3.0.tar.gz
mv DPUCZDX8G_VAI_v3.0 ../Vitis-AI_3.0/DPU-TRD
cd ../

cd Vitis-AI_3.0/DPU-TRD/prj/Vitis/
export TRD_HOME=/home/meowth/Desktop/MyTools/XILINX_WS/Vitis-AI/Vitis-AI_3.0/DPU-TRD
export EDGE_COMMON_SW=/home/meowth/Desktop/MyTools/XILINX_WS/Vitis-AI/Download/xilinx-zynqmp-common-v2022.2
export SDX_PLATFORM=/opt/Xilinx/Vitis/2022.2/base_platforms/xilinx_zcu102_base_202220_1/xilinx_zcu102_base_202220_1.xpfm
make all KERNEL=DPU_SM DEVICE=zcu102

cd ../../../model_zoo
mkdir cache
mkdir models.b4096
cp ../../Material/v3.0/arch.json_zcu102_default ./arch.json
cp ../../Material/v3.0/compile_modelzoo.sh .

cd ../
./docker_run.sh xilinx/vitis-ai-pytorch-cpu:latest
