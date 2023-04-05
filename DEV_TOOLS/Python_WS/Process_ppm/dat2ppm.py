import re
import sys
args = sys.argv

cnt = 0 ;
var = 0 ;
infile  = open(args[1], 'r')
outfile = open(args[2], 'w')
lines = infile.readlines()

outfile.write("P3\r\n")
outfile.write("2420 2020\r\n")
outfile.write("255\r\n")

for line in lines:
    line = line.strip()
    tmp_list = []
    tmp_text = ""

    tmp_list = re.split(" +", line)
    outfile.write(tmp_list[var] + " " + tmp_list[var] + " " +  tmp_list[var] + "\r\n")

infile.close()
outfile.close()

