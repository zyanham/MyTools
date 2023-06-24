#! /bin/bash

## TEST10
python datapkt_gen.py 10 test10_tmp1.txt
python idleintr_gen.py test10_tmp1.txt test10_tmp2.txt 20
python phy2cxp.py test10_tmp2.txt test10_data.txt

## TEST11
python datapkt_gen.py 10 test11_tmp1.txt
python idleintr_gen.py test11_tmp1.txt test11_tmp2.txt 20
python ioackintr_gen.py test11_tmp2.txt test11_tmp3.txt 20
python phy2cxp.py test11_tmp3.txt test11_data.txt

## TEST12
python datapkt_gen.py 10 test12_tmp1.txt
python idleintr_gen.py test12_tmp1.txt test12_tmp2.txt 20
python trgintr_gen.py test12_tmp2.txt test12_tmp3.txt 20
python phy2cxp.py test12_tmp3.txt test12_data.txt

## TEST13
python datapkt_gen.py 10 test13_tmp1.txt
python idleintr_gen.py test13_tmp1.txt test13_tmp2.txt 20
python ioackintr_gen.py test13_tmp2.txt test13_tmp3.txt 20
python trgintr_gen.py test13_tmp3.txt test13_tmp4.txt 20
python phy2cxp.py test13_tmp4.txt test13_data.txt

rm test10_tmp*.txt
rm test11_tmp*.txt
rm test12_tmp*.txt
rm test13_tmp*.txt
