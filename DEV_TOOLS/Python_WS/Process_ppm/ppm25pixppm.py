import re
import sys
args = sys.argv

cnt = 0 ;
var = 0 ;
line_cnt =0;
infile  = open(args[1], 'r')
outfile = open(args[2], 'w')
lines = infile.readlines()

line_num=len(lines)-4-1
tmp_text = ""

for line in lines:
    line = line.strip()

    if cnt > 3 :
        if(line_num == cnt) :
            tmp_text = tmp_text + " " + line + "\r\n"
            outfile.write(tmp_text)
            break
        else :
            if(line_cnt==14) :
                tmp_text = tmp_text + " " + line + "\r\n" 
                outfile.write(tmp_text)
                tmp_text = ""
                line_cnt= 0
            elif(line_cnt==0) :
                tmp_text = line
                line_cnt=line_cnt+1
            else :
                tmp_text = tmp_text + " " + line
                line_cnt=line_cnt+1

        cnt=cnt+1
    else :
        outfile.write(line + "\r\n")
        cnt=cnt+1

infile.close()
outfile.close()

