#! /bin/bash

#git clone https://github.com/Xilinx/XRT.git
cd XRT
#sudo ./src/runtime_src/tools/scripts/xrtdeps.sh
cd build
#./build.sh

cd Release
#make package
cd ../Debug
#make package
sudo apt install ./xrt_202320.2.16.0_22.04-amd64-xrt.deb
