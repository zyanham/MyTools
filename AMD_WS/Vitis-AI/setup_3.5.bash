#! /bin/bash

################################
#Required:
# - Vitis 2022.2
# - XRT 2022.2
# - ZYNQMP common image 2022.2
################################

#### USER SETUP AREA ####
VITIS_PATH="/opt//Xilinx/Vitis/2022.2"
PETA_PATH="/opt/Petalinux2022.2"
WORK_DIR="$PWD"
#########################

#cd ../XRT/v2022.2
#bash setup.bash
#cd ../../Vitis-AI
source /opt/xilinx/xrt/setup.sh

source ${VITIS_PATH}/settings64.sh
source ${PETA_PATH}/settings.sh

#git clone -b v3.5 https://github.com/Xilinx/Vitis-AI.git
mv Vitis-AI Vitis-AI_v3.5

#mkdir Download
cd Download

## Vitis AI v3.5 -> MPSOC DPU v4.1 ##
#wget https://www.xilinx.com/bin/public/openDownload?filename=DPUCZDX8G_VAI_v3.0.tar.gz -O DPUCZDX8G_VAI_v3.0.tar.gz
#tar -zxvf DPUCZDX8G_VAI_v3.0.tar.gz
#mv DPUCZDX8G_VAI_v3.0 ../Vitis-AI_v3.5/DPU-TRD
wget https://japan.xilinx.com/bin/public/openDownload?filename=vitis-ai-runtime-3.0.0.tar.gz -O  vitis-ai-runtime-3.0.0.tar.gz
tar -zxvf vitis-ai-runtime-3.0.0.tar.gz
cd ../

if [ -d "./xilinx-zynqmp-common-v2022.2" ]; then
#    mv xilinx-zynqmp-common-v2022.2 Download/
#    echo "mpsoc commonをDownloadディレクトリに移しました"
    cd Download/xilinx-zynqmp-common-v2022.2
#    chmod 777 sdk.sh
#    ./sdk.sh
    cd ../../
else
    echo "mpsoc commonがみつかりません"
fi

cd Vitis-AI_v3.5/DPU-TRD/prj/Vitis/
export TRD_HOME=${WORK_DIR}/Vitis-AI_v3.5/DPU-TRD
export EDGE_COMMON_SW=${WORK_DIR}/Download/xilinx-zynqmp-common-v2022.2
export SDX_PLATFORM=${VITIS_PATH}/base_platforms/xilinx_zcu102_base_202220_1/xilinx_zcu102_base_202220_1.xpfm
make all KERNEL=DPU_SM DEVICE=zcu102

cd ../../../model_zoo
mkdir cache
mkdir models.b4096
cp ../../Material/v3.0/arch.json_zcu102_default ./arch.json
cp ../../Material/v3.0/compile_modelzoo.sh .

cd ../
./docker_run.sh xilinx/vitis-ai-pytorch-cpu:latest

