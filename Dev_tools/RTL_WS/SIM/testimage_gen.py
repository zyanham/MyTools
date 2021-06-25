import re
import random

cnt = 0
h_odd_even = 0
v_odd_even = 0

outfile01 = open("test01_image.txt", 'w') # all 4095   - 0xFFF
outfile02 = open("test02_image.txt", 'w') # all    0   - 0x000
outfile03 = open("test03_image.txt", 'w') # all 2047   - 0x7FF
outfile04 = open("test04_image.txt", 'w') # all random
outfile05 = open("test05_image.txt", 'w') # R  = 500   - 0x1F4 / G1,B,G2 =  200 - 0x0C8
outfile06 = open("test06_image.txt", 'w') # G1 = 700   - 0x2BC / R,B,G2  =  120 - 0x078
outfile07 = open("test07_image.txt", 'w') # B  = 1200  - 0x4B0 / R,G1,G2 =  320 - 0x140
outfile08 = open("test08_image.txt", 'w') # G2 = 720   - 0x2D0 / R,G1,B  =  440 - 0x1B8
outfile09 = open("test09_image.txt", 'w') # R,G1 = 900 - 0x384 / G2,B    = 1500 - 0x5DC
outfile10 = open("test10_image.txt", 'w') # R,B  = 20  - 0x014 / G1,G2   =  820 - 0x334


#random.randrange(0,4096)
#outfile.write("255\r\n")

for v in range(2048):
    for h in range(2448):

        outfile01.write("fff\r\n")
        outfile02.write("0\r\n")
        outfile03.write("7ff\r\n")
        outfile04.write(hex(random.randrange(0,4096)) + "\r\n")

        if v_odd_even == 0 :
            if h_odd_even == 0 :  # R
                outfile05.write("1f4\r\n") 
                outfile06.write("78\r\n") 
                outfile07.write("140\r\n") 
                outfile08.write("1b8\r\n") 
                outfile09.write("384\r\n") 
                outfile10.write("14\r\n") 
            else :                # G1
                outfile05.write("c8\r\n")
                outfile06.write("2bc\r\n") 
                outfile07.write("140\r\n") 
                outfile08.write("1b8\r\n") 
                outfile09.write("384\r\n") 
                outfile10.write("334\r\n") 
        else :
            if h_odd_even == 0 :  # B
                outfile05.write("c8\r\n")
                outfile06.write("78\r\n") 
                outfile07.write("4b0\r\n") 
                outfile08.write("1b8\r\n") 
                outfile09.write("5dc\r\n") 
                outfile10.write("14\r\n") 
            else :                # G2
                outfile05.write("c8\r\n")
                outfile06.write("78\r\n") 
                outfile07.write("140\r\n") 
                outfile08.write("2d0\r\n") 
                outfile09.write("5dc\r\n") 
                outfile10.write("334\r\n") 



        if h_odd_even == 1 :
            h_odd_even = 0
        else :
            h_odd_even = 1


    if v_odd_even == 1 :
        v_odd_even = 0
    else :
        v_odd_even = 1


outfile01.close()
outfile02.close()
outfile03.close()
outfile04.close()
outfile05.close()
outfile06.close()
outfile07.close()
outfile08.close()
outfile09.close()
outfile10.close()
