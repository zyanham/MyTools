#! /bin/bash

sed -n 18,22p ./Vitis_Libraries/data_compression/L1/tests/gzipc/gzip_compress_test.prj/sol1/syn/report/csynth.rpt > report_summary.txt
sed -n 22p ./Vitis_Libraries/data_compression/L1/tests/gzipc_8KB/gzip_compress_test.prj/sol1/syn/report/csynth.rpt >> report_summary.txt
sed -n 22p ./Vitis_Libraries/data_compression/L1/tests/gzipc_16KB/gzip_compress_test.prj/sol1/syn/report/csynth.rpt >> report_summary.txt
sed -n 22p ./Vitis_Libraries/data_compression/L1/tests/gzipc_block_mm/gzip_compress_test.prj/sol1/syn/report/csynth.rpt >> report_summary.txt
sed -n 22p ./Vitis_Libraries/data_compression/L1/tests/gzipc_static/gzip_compress_test.prj/sol1/syn/report/csynth.rpt >> report_summary.txt
sed -n 22p ./Vitis_Libraries/data_compression/L1/tests/gzipc_static_8KB/gzip_compress_test.prj/sol1/syn/report/csynth.rpt >> report_summary.txt
sed -n 22p ./Vitis_Libraries/data_compression/L1/tests/gzipc_static_16KB/gzip_compress_test.prj/sol1/syn/report/csynth.rpt >> report_summary.txt
sed -n 22p ./Vitis_Libraries/data_compression/L1/tests/gzip_decompress/gzip_decompress_test.prj/sol1/syn/report/csynth.rpt >> report_summary.txt
sed -n 22p ./Vitis_Libraries/data_compression/L1/tests/gzip_decompress_fixed/gzip_decompress_test.prj/sol1/syn/report/csynth.rpt >> report_summary.txt
sed -n 22p ./Vitis_Libraries/data_compression/L1/tests/gzip_decompress_mm/gzip_decompress_test.prj/sol1/syn/report/csynth.rpt >> report_summary.txt
sed -n 22p ./Vitis_Libraries/data_compression/L1/tests/gzip_decompress_dynamic/gzip_decompress_test.prj/sol1/syn/report/csynth.rpt >> report_summary.txt
sed -n 22p ./Vitis_Libraries/data_compression/L1/tests/gzip_decompress_lowLatency/gzip_decompress_test.prj/sol1/syn/report/csynth.rpt >> report_summary.txt
