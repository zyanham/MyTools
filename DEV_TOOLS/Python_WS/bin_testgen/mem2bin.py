import re
import sys
args = sys.argv

outfile = open(args[2], 'wb')

with open(args[1], 'r') as infile:
    for text_data in infile:
        text_data = text_data.strip()
        data = int(text_data, 16)
        outfile.write(data.to_bytes(1, 'little'))

infile.close()
outfile.close()
