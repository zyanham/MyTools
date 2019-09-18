import re
import sys
args = sys.argv

cnt = 0 ;
var = 0 ;
infile  = open(args[1], 'r')
outfile = open(args[2], 'w')
lines = infile.readlines()

for line in lines:
    line = line.strip()
    tmp_list = []
    tmp_text = ""

    if cnt == 4 :
        tmp_list = re.split(" +", line)
        for var in range(0, 3):
            outfile.write(tmp_list[var] + "\r\n")
    else :
        outfile.write(line + "\r\n")
        cnt=cnt+1

infile.close()
outfile.close()

