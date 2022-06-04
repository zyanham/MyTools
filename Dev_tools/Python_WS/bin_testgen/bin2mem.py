import re
import sys
args = sys.argv

infile  = open(args[1], 'rb')
outfile = open(args[2], 'w')

while True:
    data = infile.read(1).hex()
    if len(data) == 0:
        break
    outfile.write(data+"\r\n")

infile.close()
outfile.close()
