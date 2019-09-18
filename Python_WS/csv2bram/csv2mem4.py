import re
import sys
args = sys.argv

lin01 = [0 for mem_num in range(4*256)] 
lin02 = [0 for mem_num in range(4*256)] 
lin03 = [0 for mem_num in range(4*256)] 
lin04 = [0 for mem_num in range(4*256)] 
lin05 = [0 for mem_num in range(4*256)] 
lin06 = [0 for mem_num in range(4*256)] 
lin07 = [0 for mem_num in range(4*256)] 
lin08 = [0 for mem_num in range(4*256)] 
lin09 = [0 for mem_num in range(4*256)] 
lin10 = [0 for mem_num in range(4*256)] 
lin11 = [0 for mem_num in range(4*256)] 
lin12 = [0 for mem_num in range(4*256)] 
lin13 = [0 for mem_num in range(4*256)] 
lin14 = [0 for mem_num in range(4*256)] 
lin15 = [0 for mem_num in range(4*256)] 
lin16 = [0 for mem_num in range(4*256)] 
lin17 = [0 for mem_num in range(4*256)] 
lin18 = [0 for mem_num in range(4*256)] 
lin19 = [0 for mem_num in range(4*256)] 
lin20 = [0 for mem_num in range(4*256)] 
lin21 = [0 for mem_num in range(4*256)] 
lin22 = [0 for mem_num in range(4*256)] 
lin23 = [0 for mem_num in range(4*256)] 
lin24 = [0 for mem_num in range(4*256)] 
lin25 = [0 for mem_num in range(4*256)] 
lin26 = [0 for mem_num in range(4*256)] 
lin27 = [0 for mem_num in range(4*256)] 
lin28 = [0 for mem_num in range(4*256)] 
lin29 = [0 for mem_num in range(4*256)] 
lin30 = [0 for mem_num in range(4*256)] 
lin31 = [0 for mem_num in range(4*256)] 
lin32 = [0 for mem_num in range(4*256)] 
outfile1  = open("tst2_adc_coefile1_4096x128.mem", 'w')
outfile2  = open("tst2_adc_coefile2_4096x128.mem", 'w')
outfile3  = open("tst2_adc_coefile3_4096x128.mem", 'w')
outfile4  = open("tst2_adc_coefile4_4096x128.mem", 'w')
outfile5  = open("tst2_adc_coefile5_4096x128.mem", 'w')
outfile6  = open("tst2_adc_coefile6_4096x128.mem", 'w')
outfile7  = open("tst2_adc_coefile7_4096x128.mem", 'w')
outfile8  = open("tst2_adc_coefile8_4096x128.mem", 'w')
outfile9  = open("tst2_adc_coefile9_4096x128.mem", 'w')
outfile10 = open("tst2_adc_coefile10_4096x128.mem", 'w')
outfile11 = open("tst2_adc_coefile11_4096x128.mem", 'w')
outfile12 = open("tst2_adc_coefile12_4096x128.mem", 'w')
outfile13 = open("tst2_adc_coefile13_4096x128.mem", 'w')
outfile14 = open("tst2_adc_coefile14_4096x128.mem", 'w')
outfile15 = open("tst2_adc_coefile15_4096x128.mem", 'w')
outfile16 = open("tst2_adc_coefile16_4096x128.mem", 'w')
outfile17 = open("tst2_adc_coefile17_4096x128.mem", 'w')
outfile18 = open("tst2_adc_coefile18_4096x128.mem", 'w')
outfile19 = open("tst2_adc_coefile19_4096x128.mem", 'w')
outfile20 = open("tst2_adc_coefile20_4096x128.mem", 'w')
outfile21 = open("tst2_adc_coefile21_4096x128.mem", 'w')
outfile22 = open("tst2_adc_coefile22_4096x128.mem", 'w')
outfile23 = open("tst2_adc_coefile23_4096x128.mem", 'w')
outfile24 = open("tst2_adc_coefile24_4096x128.mem", 'w')
outfile25 = open("tst2_adc_coefile25_4096x128.mem", 'w')
outfile26 = open("tst2_adc_coefile26_4096x128.mem", 'w')
outfile27 = open("tst2_adc_coefile27_4096x128.mem", 'w')
outfile28 = open("tst2_adc_coefile28_4096x128.mem", 'w')
outfile29 = open("tst2_adc_coefile29_4096x128.mem", 'w')
outfile30 = open("tst2_adc_coefile30_4096x128.mem", 'w')
outfile31 = open("tst2_adc_coefile31_4096x128.mem", 'w')
outfile32 = open("tst2_adc_coefile32_4096x128.mem", 'w')

all_text01 = ""
all_text02 = ""
all_text03 = ""
all_text04 = ""
all_text05 = ""
all_text06 = ""
all_text07 = ""
all_text08 = ""
all_text09 = ""
all_text10 = ""
all_text11 = ""
all_text12 = ""
all_text13 = ""
all_text14 = ""
all_text15 = ""
all_text16 = ""
all_text17 = ""
all_text18 = ""
all_text19 = ""
all_text20 = ""
all_text21 = ""
all_text22 = ""
all_text23 = ""
all_text24 = ""
all_text25 = ""
all_text26 = ""
all_text27 = ""
all_text28 = ""
all_text29 = ""
all_text30 = ""
all_text31 = ""
all_text32 = ""

infile  = open(args[1], 'r')
lines = infile.readlines()
all_text=""
line_num = 0
cnt = 0
val_m = 0
val_x = 0
val_y = 0
val_z = 0


comb_text = ""
list_16pt = []
for line in lines:
    tmp_list = line.strip().split(",")
    for tmp_text in tmp_list:
        
        comb_text = comb_text + str(format(int(tmp_text), '010b'))

        if line_num == 15 :
            list_16pt.append(comb_text)
            comb_text = ""
            line_num = 0
        else :
            line_num = line_num + 1






for tmp_text in list_16pt:
        if(bin((line_num >> 5) & 0b111) == '0b0') :
            val_x = 0
        elif(bin((line_num >> 5) & 0b111) == '0b1') :
            val_x = 1
        elif(bin((line_num >> 5) & 0b111) == '0b10') :
            val_x = 2
        elif(bin((line_num >> 5) & 0b111) == '0b11') :
            val_x = 3
        elif(bin((line_num >> 5) & 0b111) == '0b100') :
            val_x = 4
        elif(bin((line_num >> 5) & 0b111) == '0b101') :
            val_x = 5
        elif(bin((line_num >> 5) & 0b111) == '0b110') :
            val_x = 6
        elif(bin((line_num >> 5) & 0b111) == '0b111') :
            val_x = 7

        if(  bin((line_num >> 8) & 0b11111) == '0b0') :
            val_y = 0
        elif(bin((line_num >> 8) & 0b11111) == '0b1') :
            val_y = 1
        elif(bin((line_num >> 8) & 0b11111) == '0b10') :
            val_y = 2
        elif(bin((line_num >> 8) & 0b11111) == '0b11') :
            val_y = 3
        elif(bin((line_num >> 8) & 0b11111) == '0b100') :
            val_y = 4
        elif(bin((line_num >> 8) & 0b11111) == '0b101') :
            val_y = 5
        elif(bin((line_num >> 8) & 0b11111) == '0b110') :
            val_y = 6
        elif(bin((line_num >> 8) & 0b11111) == '0b111') :
            val_y = 7
        elif(bin((line_num >> 8) & 0b11111) == '0b1000') :
            val_y = 8
        elif(bin((line_num >> 8) & 0b11111) == '0b1001') :
            val_y = 9
        elif(bin((line_num >> 8) & 0b11111) == '0b1010') :
            val_y = 10
        elif(bin((line_num >> 8) & 0b11111) == '0b1011') :
            val_y = 11
        elif(bin((line_num >> 8) & 0b11111) == '0b1100') :
            val_y = 12
        elif(bin((line_num >> 8) & 0b11111) == '0b1101') :
            val_y = 13
        elif(bin((line_num >> 8) & 0b11111) == '0b1110') :
            val_y = 14
        elif(bin((line_num >> 8) & 0b11111) == '0b1111') :
            val_y = 15
        elif(bin((line_num >> 8) & 0b11111) == '0b10000') :
            val_y = 16
        elif(bin((line_num >> 8) & 0b11111) == '0b10001') :
            val_y = 17
        elif(bin((line_num >> 8) & 0b11111) == '0b10010') :
            val_y = 18
        elif(bin((line_num >> 8) & 0b11111) == '0b10011') :
            val_y = 19
        elif(bin((line_num >> 8) & 0b11111) == '0b10100') :
            val_y = 20
        elif(bin((line_num >> 8) & 0b11111) == '0b10101') :
            val_y = 21
        elif(bin((line_num >> 8) & 0b11111) == '0b10110') :
            val_y = 22
        elif(bin((line_num >> 8) & 0b11111) == '0b10111') :
            val_y = 23
        elif(bin((line_num >> 8) & 0b11111) == '0b11000') :
            val_y = 24
        elif(bin((line_num >> 8) & 0b11111) == '0b11001') :
            val_y = 25
        elif(bin((line_num >> 8) & 0b11111) == '0b11010') :
            val_y = 26
        elif(bin((line_num >> 8) & 0b11111) == '0b11011') :
            val_y = 27
        elif(bin((line_num >> 8) & 0b11111) == '0b11100') :
            val_y = 28
        elif(bin((line_num >> 8) & 0b11111) == '0b11101') :
            val_y = 29
        elif(bin((line_num >> 8) & 0b11111) == '0b11110') :
            val_y = 30
        elif(bin((line_num >> 8) & 0b11111) == '0b11111') :
            val_y = 31
            
        if(bin((line_num >> 13) & 0b11) == '0b0') :
            val_z = 0
        if(bin((line_num >> 13) & 0b11) == '0b1') :
            val_z = 1
        if(bin((line_num >> 13) & 0b11) == '0b10') :
            val_z = 2
        if(bin((line_num >> 13) & 0b11) == '0b11') :
            val_z = 3        

        
        adrs = (val_x * 32) + val_y + (256 * val_z)
        
        print adrs
        
        if(bin(line_num & 0b11111) == '0b0') :
            lin01[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b1') :
            lin02[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b10') :
            lin03[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b11') :
            lin04[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b100') :
            lin05[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b101') :
            lin06[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b110') :
            lin07[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b111') :
            lin08[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b1000') :
            lin09[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b1001') :
            lin10[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b1010') :
            lin11[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b1011') :
            lin12[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b1100') :
            lin13[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b1101') :
            lin14[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b1110') :
            lin15[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b1111') :
            lin16[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b10000') :
            lin17[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b10001') :
            lin18[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b10010') :
            lin19[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b10011') :
            lin20[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b10100') :
            lin21[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b10101') :
            lin22[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b10110') :
            lin23[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b10111') :
            lin24[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b11000') :
            lin25[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b11001') :
            lin26[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b11010') :
            lin27[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b11011') :
            lin28[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b11100') :
            lin29[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b11101') :
            lin30[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b11110') :
            lin31[adrs] = str(tmp_text)
        elif(bin(line_num & 0b11111) == '0b11111') :
            lin32[adrs] = str(tmp_text)
            
        line_num = line_num + 1

for line in lin01:
        outfile1.write(str(line)+'\r\n')
for line in lin02:
        outfile2.write(str(line)+'\r\n')
for line in lin03:
        outfile3.write(str(line)+'\r\n')
for line in lin04:
        outfile4.write(str(line)+'\r\n')
for line in lin05:
        outfile5.write(str(line)+'\r\n')
for line in lin06:
        outfile6.write(str(line)+'\r\n')
for line in lin07:
        outfile7.write(str(line)+'\r\n')
for line in lin08:
        outfile8.write(str(line)+'\r\n')
for line in lin09:
        outfile9.write(str(line)+'\r\n')
for line in lin10:
        outfile10.write(str(line)+'\r\n')
for line in lin11:
        outfile11.write(str(line)+'\r\n')
for line in lin12:
        outfile12.write(str(line)+'\r\n')
for line in lin13:
        outfile13.write(str(line)+'\r\n')
for line in lin14:
        outfile14.write(str(line)+'\r\n')
for line in lin15:
        outfile15.write(str(line)+'\r\n')
for line in lin16:
        outfile16.write(str(line)+'\r\n')
for line in lin17:
        outfile17.write(str(line)+'\r\n')
for line in lin18:
        outfile18.write(str(line)+'\r\n')
for line in lin19:
        outfile19.write(str(line)+'\r\n')
for line in lin20:
        outfile20.write(str(line)+'\r\n')
for line in lin21:
        outfile21.write(str(line)+'\r\n')
for line in lin22:
        outfile22.write(str(line)+'\r\n')
for line in lin23:
        outfile23.write(str(line)+'\r\n')
for line in lin24:
        outfile24.write(str(line)+'\r\n')
for line in lin25:
        outfile25.write(str(line)+'\r\n')
for line in lin26:
        outfile26.write(str(line)+'\r\n')
for line in lin27:
        outfile27.write(str(line)+'\r\n')
for line in lin28:
        outfile28.write(str(line)+'\r\n')
for line in lin29:
        outfile29.write(str(line)+'\r\n')
for line in lin30:
        outfile30.write(str(line)+'\r\n')
for line in lin31:
        outfile31.write(str(line)+'\r\n')
for line in lin32:
        outfile32.write(str(line)+'\r\n')

infile.close()
outfile1.close()
outfile2.close()
outfile3.close()
outfile4.close()
outfile5.close()
outfile6.close()
outfile7.close()
outfile8.close()
outfile9.close()
outfile10.close()
outfile11.close()
outfile12.close()
outfile13.close()
outfile14.close()
outfile15.close()
outfile16.close()
outfile17.close()
outfile18.close()
outfile19.close()
outfile20.close()
outfile21.close()
outfile22.close()
outfile23.close()
outfile24.close()
outfile25.close()
outfile26.close()
outfile27.close()
outfile28.close()
outfile29.close()
outfile30.close()
outfile31.close()
outfile32.close()
#print cnt
infile.close()
outfile1.close()
