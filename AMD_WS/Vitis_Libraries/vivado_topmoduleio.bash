#! /bin/bash

echo "" >> vivado_io_summary.txt
echo "gzipc report" >> vivado_io_summary.txt
sed -n 1,50p ./Vivado_Proj/vivado_gzipc/src/gzipcMulticoreStreaming.vhd >> vivado_io_summary.txt

echo "" >> vivado_io_summary.txt
echo "gzipc 8KB_report" >> vivado_io_summary.txt
sed -n 1,50p ./Vivado_Proj/vivado_gzipc_8KB/src/gzipcMulticoreStreaming.vhd >> vivado_io_summary.txt

echo "" >> vivado_io_summary.txt
echo "gzipc 16KB_report" >> vivado_io_summary.txt
sed -n 1,50p ./Vivado_Proj/vivado_gzipc_16KB/src/gzipcMulticoreStreaming.vhd >> vivado_io_summary.txt

echo "" >> vivado_io_summary.txt
echo "gzipc block_mm_report" >> vivado_io_summary.txt
sed -n 1,50p ./Vivado_Proj/vivado_gzipc_block_mm/src/gzipcMulticoreMM.vhd >> vivado_io_summary.txt

echo "" >> vivado_io_summary.txt
echo "gzipc static_report" >> vivado_io_summary.txt
sed -n 1,50p ./Vivado_Proj/vivado_gzipc_static/src/gzipcMulticoreStreaming.vhd >> vivado_io_summary.txt

echo "" >> vivado_io_summary.txt
echo "gzipc static_8KB_report" >> vivado_io_summary.txt
sed -n 1,50p ./Vivado_Proj/vivado_gzipc_static_8KB/src/gzipcMulticoreStreaming.vhd >> vivado_io_summary.txt

echo "" >> vivado_io_summary.txt
echo "gzipc static_16KB_report" >> vivado_io_summary.txt
sed -n 1,50p ./Vivado_Proj/vivado_gzipc_static_16KB/src/gzipcMulticoreStreaming.vhd >> vivado_io_summary.txt

echo "" >> vivado_io_summary.txt
echo "gzip_decompress_report" >> vivado_io_summary.txt
sed -n 1,50p ./Vivado_Proj/vivado_gzip_decompress/src/gzipMultiByteDecompressEngineRun.vhd >> vivado_io_summary.txt

echo "" >> vivado_io_summary.txt
echo "gzip_decompress_dynamic_report" >> vivado_io_summary.txt
sed -n 1,50p ./Vivado_Proj/vivado_gzip_decompress_dynamic/src/gzipMultiByteDecompressEngineRun.vhd >> vivado_io_summary.txt

echo "" >> vivado_io_summary.txt
echo "gzip_decompress_fixed_report" >> vivado_io_summary.txt
sed -n 1,50p ./Vivado_Proj/vivado_gzip_decompress_fixed/src/gzipMultiByteDecompressEngineRun.vhd >> vivado_io_summary.txt

echo "" >> vivado_io_summary.txt
echo "gzip_decompress_lowLatancy_report" >> vivado_io_summary.txt
sed -n 1,50p ./Vivado_Proj/vivado_gzip_decompress_lowLatency/src/gzipMultiByteDecompressEngineRun.vhd >> vivado_io_summary.txt

echo "" >> vivado_io_summary.txt
echo "gzip_decompress_mm_report" >> vivado_io_summary.txt
sed -n 1,50p ./Vivado_Proj/vivado_gzip_decompress_mm/src/gzipDecompressMM.vhd >> vivado_io_summary.txt
