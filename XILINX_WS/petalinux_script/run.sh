#!/bin/sh

echo "##################" >  test.log
echo "# 4K Default_GaussianFilter_measure   #" >> test.log
echo "##################" >> test.log
./Default_GaussianFilter_measure data/4k.jpg >> test.log
./Default_GaussianFilter_measure data/4k.jpg >> test.log
./Default_GaussianFilter_measure data/4k.jpg >> test.log
./Default_GaussianFilter_measure data/4k.jpg >> test.log
./Default_GaussianFilter_measure data/4k.jpg >> test.log

echo "" >> test.log
echo "##################" >> test.log
echo "# 4K Default_GaussianFilter_measure   #" >> test.log
echo "##################" >> test.log
./Default_GaussianFilter_measure test_data/test1_4k.jpg >> test.log
./Default_GaussianFilter_measure test_data/test1_4k.jpg >> test.log
./Default_GaussianFilter_measure test_data/test1_4k.jpg >> test.log
./Default_GaussianFilter_measure test_data/test1_4k.jpg >> test.log
./Default_GaussianFilter_measure test_data/test1_4k.jpg >> test.log

echo "" >> test.log
echo "##################" >> test.log
echo "# FHD Default_GaussianFilter_measure  #" >> test.log
echo "##################" >> test.log
./Default_GaussianFilter_measure test_data/test1_FHD.jpg >> test.log
./Default_GaussianFilter_measure test_data/test1_FHD.jpg >> test.log
./Default_GaussianFilter_measure test_data/test1_FHD.jpg >> test.log
./Default_GaussianFilter_measure test_data/test1_FHD.jpg >> test.log
./Default_GaussianFilter_measure test_data/test1_FHD.jpg >> test.log

echo "" >> test.log
echo "##################" >> test.log
echo "# HD Default_GaussianFilter_measure   #" >> test.log
echo "##################" >> test.log
./Default_GaussianFilter_measure test_data/test1_HD.jpg >> test.log
./Default_GaussianFilter_measure test_data/test1_HD.jpg >> test.log
./Default_GaussianFilter_measure test_data/test1_HD.jpg >> test.log
./Default_GaussianFilter_measure test_data/test1_HD.jpg >> test.log
./Default_GaussianFilter_measure test_data/test1_HD.jpg >> test.log

echo "" >> test.log
echo "##################" >> test.log
echo "# VGA Default_GaussianFilter_measure  #" >> test.log
echo "##################" >> test.log
./Default_GaussianFilter_measure test_data/test1_VGA.jpg >> test.log
./Default_GaussianFilter_measure test_data/test1_VGA.jpg >> test.log
./Default_GaussianFilter_measure test_data/test1_VGA.jpg >> test.log
./Default_GaussianFilter_measure test_data/test1_VGA.jpg >> test.log
./Default_GaussianFilter_measure test_data/test1_VGA.jpg >> test.log
