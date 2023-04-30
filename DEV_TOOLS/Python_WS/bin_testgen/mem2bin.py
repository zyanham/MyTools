import re
import sys
args = sys.argv

outfile = open(args[2], 'wb')

with open(args[1], 'r') as infile:
    for text_data in infile:
        text_data = text_data.strip()
        if(len(text_data) > 2) :
            split_text = [text_data[x:x+2] for x in range(0, len(text_data), 2)]
            split_text.reverse();
            for temp_text in split_text :
                data = int(temp_text, 16)
                outfile.write(data.to_bytes(1, 'little'))
                
        else :
            data = int(text_data, 16)
            outfile.write(data.to_bytes(1, 'little'))

infile.close()
outfile.close()
