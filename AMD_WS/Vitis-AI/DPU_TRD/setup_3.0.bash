#!/bin/bash

file_path="/mnt/EXTDSK/Xilinx/Vitis/2022.2/settings64.sh"

if [ -f "$file_path" ]; then
    source "$file_path"
else
    echo "ファイル $file_path が存在しません。スクリプトを終了します。"
    exit 1
fi


if [ "$1" == "KV260" ]; then
## KV260 TRD
    wget https://www.xilinx.com/bin/public/openDownload?filename=DPUCZDX8G_VAI_v3.0.tar.gz -O DPUCZDX8G_VAI_v3.0.tar.gz
    tar zxvf DPUCZDX8G_VAI_v3.0.tar.gz
    mv DPUCZDX8G_VAI_v3.0 DPU_TRD_KV260
    cd DPU_TRD_KV260/prj/Vivado/hw/scripts
#    vivado -source trd_prj.tcl
else
## ZCU102 TRD
    wget https://www.xilinx.com/bin/public/openDownload?filename=DPUCZDX8G_VAI_v3.0.tar.gz -O DPUCZDX8G_VAI_v3.0.tar.gz
    tar zxvf DPUCZDX8G_VAI_v3.0.tar.gz
    mv DPUCZDX8G_VAI_v3.0 DPU_TRD
    cd DPU_TRD/prj/Vivado/hw/scripts
    vivado -source trd_prj.tcl

fi
