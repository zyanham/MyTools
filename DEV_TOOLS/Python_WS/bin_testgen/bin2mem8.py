import re
import argparse


parser = argparse.ArgumentParser(description='binfile to VHDL memfile translate program')

parser.add_argument('arg1', help='input file name')
parser.add_argument('arg2', help='output file name')
parser.add_argument('-o', '--offset', action='store_true')
args = parser.parse_args()

infile  = open(args.arg1, 'rb')
outfile = open(args.arg2, 'w', newline='')

cnt=0
temp_text=""

if (args.offset) :
    offset=0
else:
    offset=4

while True:
    data = infile.read(1).hex()
    data = data.upper()

    if len(data) == 0:
        break

    if(offset>3):
        if cnt == 7 :
            temp_text = data + temp_text
            outfile.write(temp_text+"\r\n")
            temp_text = ""
            cnt = 0
        else :
            temp_text = data + temp_text
            cnt = cnt + 1

    offset=offset+1

infile.close()
outfile.close()
