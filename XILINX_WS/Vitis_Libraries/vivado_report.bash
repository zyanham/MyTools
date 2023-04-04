#! /bin/bash

sed -n 2,11p ./Vivado_Proj/vivado_gzipc/vivado_gzipc.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt > vivado_report_summary.txt

echo "" >> vivado_report_summary.txt
echo "gzipc report" >> vivado_report_summary.txt
sed -n 32,35p   ./Vivado_Proj/vivado_gzipc/vivado_gzipc.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 40p      ./Vivado_Proj/vivado_gzipc/vivado_gzipc.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 43,46p   ./Vivado_Proj/vivado_gzipc/vivado_gzipc.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 76p      ./Vivado_Proj/vivado_gzipc/vivado_gzipc.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 81p      ./Vivado_Proj/vivado_gzipc/vivado_gzipc.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 92p      ./Vivado_Proj/vivado_gzipc/vivado_gzipc.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 102p     ./Vivado_Proj/vivado_gzipc/vivado_gzipc.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 112p     ./Vivado_Proj/vivado_gzipc/vivado_gzipc.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 118,120p ./Vivado_Proj/vivado_gzipc/vivado_gzipc.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt

echo "" >> vivado_report_summary.txt
echo "gzipc 8KB_report" >> vivado_report_summary.txt
sed -n 32,35p   ./Vivado_Proj/vivado_gzipc_8KB/vivado_gzipc_8KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 40p      ./Vivado_Proj/vivado_gzipc_8KB/vivado_gzipc_8KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 43,46p   ./Vivado_Proj/vivado_gzipc_8KB/vivado_gzipc_8KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 76p      ./Vivado_Proj/vivado_gzipc_8KB/vivado_gzipc_8KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 81p      ./Vivado_Proj/vivado_gzipc_8KB/vivado_gzipc_8KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 92p      ./Vivado_Proj/vivado_gzipc_8KB/vivado_gzipc_8KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 102p     ./Vivado_Proj/vivado_gzipc_8KB/vivado_gzipc_8KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 112p     ./Vivado_Proj/vivado_gzipc_8KB/vivado_gzipc_8KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 118,120p ./Vivado_Proj/vivado_gzipc_8KB/vivado_gzipc_8KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt

echo "" >> vivado_report_summary.txt
echo "gzipc 16KB_report" >> vivado_report_summary.txt
sed -n 32,35p   ./Vivado_Proj/vivado_gzipc_16KB/vivado_gzipc_16KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 40p      ./Vivado_Proj/vivado_gzipc_16KB/vivado_gzipc_16KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 43,46p   ./Vivado_Proj/vivado_gzipc_16KB/vivado_gzipc_16KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 76p      ./Vivado_Proj/vivado_gzipc_16KB/vivado_gzipc_16KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 81p      ./Vivado_Proj/vivado_gzipc_16KB/vivado_gzipc_16KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 92p      ./Vivado_Proj/vivado_gzipc_16KB/vivado_gzipc_16KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 102p     ./Vivado_Proj/vivado_gzipc_16KB/vivado_gzipc_16KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 112p     ./Vivado_Proj/vivado_gzipc_16KB/vivado_gzipc_16KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 118,120p ./Vivado_Proj/vivado_gzipc_16KB/vivado_gzipc_16KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt

echo "" >> vivado_report_summary.txt
echo "gzipc block_mm_report" >> vivado_report_summary.txt
sed -n 32,35p   ./Vivado_Proj/vivado_gzipc_block_mm/vivado_gzipc_block_mm.runs/synth_1/gzipcMulticoreMM_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 40p      ./Vivado_Proj/vivado_gzipc_block_mm/vivado_gzipc_block_mm.runs/synth_1/gzipcMulticoreMM_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 43,46p   ./Vivado_Proj/vivado_gzipc_block_mm/vivado_gzipc_block_mm.runs/synth_1/gzipcMulticoreMM_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 76p      ./Vivado_Proj/vivado_gzipc_block_mm/vivado_gzipc_block_mm.runs/synth_1/gzipcMulticoreMM_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 81p      ./Vivado_Proj/vivado_gzipc_block_mm/vivado_gzipc_block_mm.runs/synth_1/gzipcMulticoreMM_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 92p      ./Vivado_Proj/vivado_gzipc_block_mm/vivado_gzipc_block_mm.runs/synth_1/gzipcMulticoreMM_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 102p     ./Vivado_Proj/vivado_gzipc_block_mm/vivado_gzipc_block_mm.runs/synth_1/gzipcMulticoreMM_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 112p     ./Vivado_Proj/vivado_gzipc_block_mm/vivado_gzipc_block_mm.runs/synth_1/gzipcMulticoreMM_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 118,120p ./Vivado_Proj/vivado_gzipc_block_mm/vivado_gzipc_block_mm.runs/synth_1/gzipcMulticoreMM_utilization_synth.rpt >> vivado_report_summary.txt

echo "" >> vivado_report_summary.txt
echo "gzipc static_report" >> vivado_report_summary.txt
sed -n 32,35p   ./Vivado_Proj/vivado_gzipc_static/vivado_gzipc_static.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 40p      ./Vivado_Proj/vivado_gzipc_static/vivado_gzipc_static.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 43,46p   ./Vivado_Proj/vivado_gzipc_static/vivado_gzipc_static.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 76p      ./Vivado_Proj/vivado_gzipc_static/vivado_gzipc_static.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 81p      ./Vivado_Proj/vivado_gzipc_static/vivado_gzipc_static.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 92p      ./Vivado_Proj/vivado_gzipc_static/vivado_gzipc_static.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 102p     ./Vivado_Proj/vivado_gzipc_static/vivado_gzipc_static.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 112p     ./Vivado_Proj/vivado_gzipc_static/vivado_gzipc_static.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 118,120p ./Vivado_Proj/vivado_gzipc_static/vivado_gzipc_static.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt

echo "" >> vivado_report_summary.txt
echo "gzipc static_8KB_report" >> vivado_report_summary.txt
sed -n 32,35p   ./Vivado_Proj/vivado_gzipc_static_8KB/vivado_gzipc_static_8KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 40p      ./Vivado_Proj/vivado_gzipc_static_8KB/vivado_gzipc_static_8KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 43,46p   ./Vivado_Proj/vivado_gzipc_static_8KB/vivado_gzipc_static_8KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 76p      ./Vivado_Proj/vivado_gzipc_static_8KB/vivado_gzipc_static_8KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 81p      ./Vivado_Proj/vivado_gzipc_static_8KB/vivado_gzipc_static_8KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 92p      ./Vivado_Proj/vivado_gzipc_static_8KB/vivado_gzipc_static_8KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 102p     ./Vivado_Proj/vivado_gzipc_static_8KB/vivado_gzipc_static_8KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 112p     ./Vivado_Proj/vivado_gzipc_static_8KB/vivado_gzipc_static_8KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 118,120p ./Vivado_Proj/vivado_gzipc_static_8KB/vivado_gzipc_static_8KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt

echo "" >> vivado_report_summary.txt
echo "gzipc static_16KB_report" >> vivado_report_summary.txt
sed -n 32,35p   ./Vivado_Proj/vivado_gzipc_static_16KB/vivado_gzipc_static_16KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 40p      ./Vivado_Proj/vivado_gzipc_static_16KB/vivado_gzipc_static_16KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 43,46p   ./Vivado_Proj/vivado_gzipc_static_16KB/vivado_gzipc_static_16KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 76p      ./Vivado_Proj/vivado_gzipc_static_16KB/vivado_gzipc_static_16KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 81p      ./Vivado_Proj/vivado_gzipc_static_16KB/vivado_gzipc_static_16KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 92p      ./Vivado_Proj/vivado_gzipc_static_16KB/vivado_gzipc_static_16KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 102p     ./Vivado_Proj/vivado_gzipc_static_16KB/vivado_gzipc_static_16KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 112p     ./Vivado_Proj/vivado_gzipc_static_16KB/vivado_gzipc_static_16KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 118,120p ./Vivado_Proj/vivado_gzipc_static_16KB/vivado_gzipc_static_16KB.runs/synth_1/gzipcMulticoreStreaming_utilization_synth.rpt >> vivado_report_summary.txt

echo "" >> vivado_report_summary.txt
echo "gzip_decompress_report" >> vivado_report_summary.txt
sed -n 32,35p   ./Vivado_Proj/vivado_gzip_decompress/vivado_gzip_decompress.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 40p      ./Vivado_Proj/vivado_gzip_decompress/vivado_gzip_decompress.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 43,46p   ./Vivado_Proj/vivado_gzip_decompress/vivado_gzip_decompress.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 76p      ./Vivado_Proj/vivado_gzip_decompress/vivado_gzip_decompress.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 81p      ./Vivado_Proj/vivado_gzip_decompress/vivado_gzip_decompress.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 92p      ./Vivado_Proj/vivado_gzip_decompress/vivado_gzip_decompress.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 102p     ./Vivado_Proj/vivado_gzip_decompress/vivado_gzip_decompress.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 112p     ./Vivado_Proj/vivado_gzip_decompress/vivado_gzip_decompress.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 118,120p ./Vivado_Proj/vivado_gzip_decompress/vivado_gzip_decompress.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt

echo "" >> vivado_report_summary.txt
echo "gzip_decompress_dynamic_report" >> vivado_report_summary.txt
sed -n 32,35p   ./Vivado_Proj/vivado_gzip_decompress_dynamic/vivado_gzip_decompress_dynamic.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 40p      ./Vivado_Proj/vivado_gzip_decompress_dynamic/vivado_gzip_decompress_dynamic.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 43,46p   ./Vivado_Proj/vivado_gzip_decompress_dynamic/vivado_gzip_decompress_dynamic.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 76p      ./Vivado_Proj/vivado_gzip_decompress_dynamic/vivado_gzip_decompress_dynamic.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 81p      ./Vivado_Proj/vivado_gzip_decompress_dynamic/vivado_gzip_decompress_dynamic.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 92p      ./Vivado_Proj/vivado_gzip_decompress_dynamic/vivado_gzip_decompress_dynamic.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 102p     ./Vivado_Proj/vivado_gzip_decompress_dynamic/vivado_gzip_decompress_dynamic.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 112p     ./Vivado_Proj/vivado_gzip_decompress_dynamic/vivado_gzip_decompress_dynamic.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 118,120p ./Vivado_Proj/vivado_gzip_decompress_dynamic/vivado_gzip_decompress_dynamic.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt

echo "" >> vivado_report_summary.txt
echo "gzip_decompress_fixed_report" >> vivado_report_summary.txt
sed -n 32,35p   ./Vivado_Proj/vivado_gzip_decompress_fixed/vivado_gzip_decompress_fixed.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 40p      ./Vivado_Proj/vivado_gzip_decompress_fixed/vivado_gzip_decompress_fixed.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 43,46p   ./Vivado_Proj/vivado_gzip_decompress_fixed/vivado_gzip_decompress_fixed.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 76p      ./Vivado_Proj/vivado_gzip_decompress_fixed/vivado_gzip_decompress_fixed.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 81p      ./Vivado_Proj/vivado_gzip_decompress_fixed/vivado_gzip_decompress_fixed.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 92p      ./Vivado_Proj/vivado_gzip_decompress_fixed/vivado_gzip_decompress_fixed.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 102p     ./Vivado_Proj/vivado_gzip_decompress_fixed/vivado_gzip_decompress_fixed.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 112p     ./Vivado_Proj/vivado_gzip_decompress_fixed/vivado_gzip_decompress_fixed.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 118,120p ./Vivado_Proj/vivado_gzip_decompress_fixed/vivado_gzip_decompress_fixed.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt

echo "" >> vivado_report_summary.txt
echo "gzip_decompress_lowLatancy_report" >> vivado_report_summary.txt
sed -n 32,35p   ./Vivado_Proj/vivado_gzip_decompress_lowLatency/vivado_gzip_decompress_lowLatency.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 40p      ./Vivado_Proj/vivado_gzip_decompress_lowLatency/vivado_gzip_decompress_lowLatency.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 43,46p   ./Vivado_Proj/vivado_gzip_decompress_lowLatency/vivado_gzip_decompress_lowLatency.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 76p      ./Vivado_Proj/vivado_gzip_decompress_lowLatency/vivado_gzip_decompress_lowLatency.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 81p      ./Vivado_Proj/vivado_gzip_decompress_lowLatency/vivado_gzip_decompress_lowLatency.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 92p      ./Vivado_Proj/vivado_gzip_decompress_lowLatency/vivado_gzip_decompress_lowLatency.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 102p     ./Vivado_Proj/vivado_gzip_decompress_lowLatency/vivado_gzip_decompress_lowLatency.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 112p     ./Vivado_Proj/vivado_gzip_decompress_lowLatency/vivado_gzip_decompress_lowLatency.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 118,120p ./Vivado_Proj/vivado_gzip_decompress_lowLatency/vivado_gzip_decompress_lowLatency.runs/synth_1/gzipMultiByteDecompressEngineRun_utilization_synth.rpt >> vivado_report_summary.txt

echo "" >> vivado_report_summary.txt
echo "gzip_decompress_mm_report" >> vivado_report_summary.txt
sed -n 32,35p   ./Vivado_Proj/vivado_gzip_decompress_mm/vivado_gzip_decompress_mm.runs/synth_1/gzipDecompressMM_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 40p      ./Vivado_Proj/vivado_gzip_decompress_mm/vivado_gzip_decompress_mm.runs/synth_1/gzipDecompressMM_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 43,46p   ./Vivado_Proj/vivado_gzip_decompress_mm/vivado_gzip_decompress_mm.runs/synth_1/gzipDecompressMM_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 76p      ./Vivado_Proj/vivado_gzip_decompress_mm/vivado_gzip_decompress_mm.runs/synth_1/gzipDecompressMM_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 81p      ./Vivado_Proj/vivado_gzip_decompress_mm/vivado_gzip_decompress_mm.runs/synth_1/gzipDecompressMM_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 92p      ./Vivado_Proj/vivado_gzip_decompress_mm/vivado_gzip_decompress_mm.runs/synth_1/gzipDecompressMM_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 102p     ./Vivado_Proj/vivado_gzip_decompress_mm/vivado_gzip_decompress_mm.runs/synth_1/gzipDecompressMM_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 112p     ./Vivado_Proj/vivado_gzip_decompress_mm/vivado_gzip_decompress_mm.runs/synth_1/gzipDecompressMM_utilization_synth.rpt >> vivado_report_summary.txt
sed -n 118,120p ./Vivado_Proj/vivado_gzip_decompress_mm/vivado_gzip_decompress_mm.runs/synth_1/gzipDecompressMM_utilization_synth.rpt >> vivado_report_summary.txt

