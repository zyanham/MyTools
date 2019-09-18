import re
import sys
args = sys.argv

infile  = open(args[1], 'r')
outfile = open(args[2], 'w')
lines = infile.readlines()
all_text=""

for line in lines:
    tmp_list = line.strip().split(",")
    for tmp_text in tmp_list:
        all_text += str(format(int(tmp_text), '016b'))

v = [all_text[i: i+256] for i in range(0, len(all_text), 256)]

for line in v:
    outfile.write(str(line)+'\r\n')

infile.close()
outfile.close()
