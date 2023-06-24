import sys
import random

def read_file(input_file):
    with open(input_file, 'r') as file:
        lines = file.readlines()
    return lines


def write_file(output_file, lines):
    with open(output_file, 'w') as file:
        file.writelines(lines)

def phy2cxp_conv(lines, pkt_num, data):
    result = []
    hex_pkt_num = ""
    hex_data = ""


def process_input_lines(input_lines):
    output_lines = []
    data=0
    pkt_num=0

    for line_index, line in enumerate(input_lines):
#        output_lines.append(line)

        if line.strip() == "IT":
            output_lines.append("F"+"07070707") # RXC + RXD
        elif line.strip() == "SOP":
            output_lines.append("1"+"00FB80FB") # RXC + RXD
        elif line.strip() == "HDP":
            hex_pkt_num  = hex(pkt_num)[2:].zfill(2).upper()
            hex_data = hex(data)[2:].zfill(2).upper()
            output_lines.append("0"+("00"+hex_pkt_num+"00"+hex_data)) # RXC + RXD
            data=data+1
        elif line.strip() == "EOP":
            output_lines.append("C"+"07FD00FD") # RXC + RXD
            output_lines.append("F"+"07070707") # RXC + RXD
            pkt_num=pkt_num+1
            data=0
        elif line.strip() == "SOP-INT":
            output_lines.append("1"+"000080FB") # RXC + RXD
        elif line.strip() == "EOP-INT":
            output_lines.append("C"+"07FD0000") # RXC + RXD
            output_lines.append("F"+"07070707") # RXC + RXD
        elif line.strip() == "SOP-IOACK":
            output_lines.append("1"+"00DC80FB") # RXC + RXD
        elif line.strip() == "HDP-IOACK":
            output_lines.append("0"+"DEADBEEF") # RXC + RXD
        elif line.strip() == "EOP-IOACK":
            output_lines.append("C"+"07FD0000") # RXC + RXD
            output_lines.append("F"+"07070707") # RXC + RXD
        elif line.strip() == "SOP-TRG":
            output_lines.append("1"+"005C80FB") # RXC + RXD
        elif line.strip() == "HDP-TRG":
            output_lines.append("0"+"BEEFDEAD") # RXC + RXD
        elif line.strip() == "EOP-TRG":
            output_lines.append("C"+"07FD0000") # RXC + RXD
            output_lines.append("F"+"07070707") # RXC + RXD
        else :
            print("Error"+line+"\n")


    return output_lines

def combine_2pkt(input_lines):
    output_lines=[]
    odd_even = 0
    prev_line = ""

    for line_index, line in enumerate(input_lines):
        
        if odd_even == 0:
            prev_line=line
            odd_even = 1
        elif odd_even == 1:
#            print("prev_line="+prev_line)
#            print("line="+line)
            output_lines.append(line[0]+prev_line[0]+line[1:8]+prev_line[1:8]+"\n")
            odd_even = 0

    return output_lines

def main():
    if len(sys.argv) < 3:
        return

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    input_lines = read_file(input_file)
    line_count = len(input_lines)

    output_lines = process_input_lines(input_lines)
    output_lines2 = combine_2pkt(output_lines)

    write_file(output_file, output_lines2)

if __name__ == '__main__':
    main()

