import re
import sys
import math
args = sys.argv

cnt = 0 ;
var = 0 ;
infile  = open(args[1], 'r')
outfile = open(args[2], 'w')
lines = infile.readlines()

for line in lines:
    line = line.strip("")
    tmp_list = []
    tmp_text = ""

    if cnt == 4 :
        tmp_list = re.split(" +", line)
        for var in range(0, 5):
            red   = long(tmp_list[var*3].strip("")) * 0.3
            green = long(tmp_list[var*3+1].strip("")) * 0.59
            blue  = long(tmp_list[var*3+2].strip("")) * 0.11
            data = red + green + blue
            if data > 255 : data = 255
            data = math.floor(data+0.5)
            outfile.write(str(int(data)) + " " + str(int(data)) + " " + str(int(data)) + "\r\n")
    else :
        outfile.write(line + "\r\n")
        cnt=cnt+1




infile.close()
outfile.close()

