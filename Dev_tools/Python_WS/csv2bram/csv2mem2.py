import re
import sys
args = sys.argv

infile  = open(args[1], 'r')
outfile1 = open("tst2_dac_coefile1_32x4096.csv", 'w')
outfile2 = open("tst2_dac_coefile2_32x4096.csv", 'w')
outfile3 = open("tst2_dac_coefile3_32x4096.csv", 'w')
outfile4 = open("tst2_dac_coefile4_32x4096.csv", 'w')
outfile5 = open("tst2_dac_coefile5_32x4096.csv", 'w')
outfile6 = open("tst2_dac_coefile6_32x4096.csv", 'w')
outfile7 = open("tst2_dac_coefile7_32x4096.csv", 'w')
outfile8 = open("tst2_dac_coefile8_32x4096.csv", 'w')
lines = infile.readlines()
all_text=""
line_num = 0
cnt = 0

for line in lines:
    tmp_list = line.strip().split(",")
    for tmp_text in tmp_list:
        all_text += str(format(int(tmp_text), '010b'))

v = [all_text[i: i+160] for i in range(0, len(all_text), 160)]

for line in v:
    if line_num < 8 :
        outfile1.write(str(line)+'\r\n')
    elif line_num < 16 :
        outfile2.write(str(line)+'\r\n')
    elif line_num < 24 :
        outfile3.write(str(line)+'\r\n')
    elif line_num < 32 :
        outfile4.write(str(line)+'\r\n')
    elif line_num < 40 :
        outfile5.write(str(line)+'\r\n')
    elif line_num < 48 :
        outfile6.write(str(line)+'\r\n')
    elif line_num < 56 :
        outfile7.write(str(line)+'\r\n')
    else :
        outfile8.write(str(line)+'\r\n')
	
    if line_num == 63 :
	    line_num = 0
    else :
        line_num = line_num + 1

    cnt = cnt + 1 ;

print cnt
infile.close()
outfile1.close()
