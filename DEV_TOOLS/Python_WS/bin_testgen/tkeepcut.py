import sys
import re
import argparse


parser = argparse.ArgumentParser(description='binfile to VHDL memfile translate program')

parser.add_argument('arg1', help='input file name')
parser.add_argument('arg2', help='output file name')
parser.add_argument('-l', type=int, default=128)
parser.add_argument('-s', type=int, default=7)
args = parser.parse_args()

#print(args.arg1)
#print(args.arg2)

infile  = open(args.arg1, 'rb')
outfile = open(args.arg2, 'w', newline='')
cnt = 0

if((args.s > 7) or (args.s < 1)) :
    print("argument error")
    sys.exit()

if(args.l < 128) :
    print("argument error")
    sys.exit()

with open(args.arg1, 'r') as infile:
    for text_data in infile:
        text_data = text_data.strip()
        if(cnt == (args.l - 1)) :
            temp = ""
            for i in range(args.s) :
                cut_text = ""
                temp = temp + "00"
                cut_text = temp + text_data[-(16-args.s*2):]
            outfile.write(cut_text+"\r\n")
        else :
            outfile.write(text_data+"\r\n")
        cnt=cnt+1

infile.close()
outfile.close()

