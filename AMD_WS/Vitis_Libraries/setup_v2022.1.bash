#! /bin/bash

source /opt/Xilinx/Vivado/2022.1/settings64.sh

git clone https://github.com/Xilinx/Vitis_Libraries.git -b 2022.1
#ln -s Vitis_Libraries/data_compression/L1/tests/gzipc GZ_CMP
#ln -s Vitis_Libraries/data_compression/L1/tests/gzip_decompress GZ_DCMP

cd Vitis_Libraries
#rm -r blas genomics quantitative_finance sparse codec database graph data_analytics dsp hpc solver vision

## Directry Delete
## rm -r codec

#xczu7ev-ffvc1156-2-e
#xczu9eg-ffvb1156-2-e

cd data_compression/L1/tests
#cp -r gzipc gzipc_NB2
#cp -r gzipc gzipc_NB4

cd gzipc
sed -i -e "s/CLKP 3\.3/CLKP 8\.0/" run_hls.tcl
make run CSIM=1 CSYNTH=1 COSIM=1 XPART='xczu7ev-ffvc1156-2-e'

#cd ../gzipc_NB2
#sed -i -e "s/CLKP 3\.3/CLKP 8\.0/" run_hls.tcl
#sed -i -e "s/NUM_BLOCKS 8/NUM_BLOCKS 2/" gzip_compress_test.cpp
#make run CSIM=1 CSYNTH=1 COSIM=1 XPART='xczu7ev-ffvc1156-2-e'
#
#cd ../gzipc_NB4
#sed -i -e "s/CLKP 3\.3/CLKP 8\.0/" run_hls.tcl
#sed -i -e "s/NUM_BLOCKS 8/NUM_BLOCKS 4/" gzip_compress_test.cpp
#make run CSIM=1 CSYNTH=1 COSIM=1 XPART='xczu7ev-ffvc1156-2-e'

cd ../gzip_decompress
sed -i -e "s/CLKP 3\.3/CLKP 8\.0/" run_hls.tcl
make run CSIM=1 CSYNTH=1 COSIM=1 XPART='xczu7ev-ffvc1156-2-e'


