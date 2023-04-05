import re
import sys
args = sys.argv

infile  = open(args[1], 'r')
outfile1  = open("tst2_adc_coefile1_4096x128.csv", 'w')
outfile2  = open("tst2_adc_coefile2_4096x128.csv", 'w')
outfile3  = open("tst2_adc_coefile3_4096x128.csv", 'w')
outfile4  = open("tst2_adc_coefile4_4096x128.csv", 'w')
outfile5  = open("tst2_adc_coefile5_4096x128.csv", 'w')
outfile6  = open("tst2_adc_coefile6_4096x128.csv", 'w')
outfile7  = open("tst2_adc_coefile7_4096x128.csv", 'w')
outfile8  = open("tst2_adc_coefile8_4096x128.csv", 'w')
outfile9  = open("tst2_adc_coefile9_4096x128.csv", 'w')
outfile10 = open("tst2_adc_coefile10_4096x128.csv", 'w')
outfile11 = open("tst2_adc_coefile11_4096x128.csv", 'w')
outfile12 = open("tst2_adc_coefile12_4096x128.csv", 'w')
outfile13 = open("tst2_adc_coefile13_4096x128.csv", 'w')
outfile14 = open("tst2_adc_coefile14_4096x128.csv", 'w')
outfile15 = open("tst2_adc_coefile15_4096x128.csv", 'w')
outfile16 = open("tst2_adc_coefile16_4096x128.csv", 'w')
outfile17 = open("tst2_adc_coefile17_4096x128.csv", 'w')
outfile18 = open("tst2_adc_coefile18_4096x128.csv", 'w')
outfile19 = open("tst2_adc_coefile19_4096x128.csv", 'w')
outfile20 = open("tst2_adc_coefile20_4096x128.csv", 'w')
outfile21 = open("tst2_adc_coefile21_4096x128.csv", 'w')
outfile22 = open("tst2_adc_coefile22_4096x128.csv", 'w')
outfile23 = open("tst2_adc_coefile23_4096x128.csv", 'w')
outfile24 = open("tst2_adc_coefile24_4096x128.csv", 'w')
outfile25 = open("tst2_adc_coefile25_4096x128.csv", 'w')
outfile26 = open("tst2_adc_coefile26_4096x128.csv", 'w')
outfile27 = open("tst2_adc_coefile27_4096x128.csv", 'w')
outfile28 = open("tst2_adc_coefile28_4096x128.csv", 'w')
outfile29 = open("tst2_adc_coefile29_4096x128.csv", 'w')
outfile30 = open("tst2_adc_coefile30_4096x128.csv", 'w')
outfile31 = open("tst2_adc_coefile31_4096x128.csv", 'w')
outfile32 = open("tst2_adc_coefile32_4096x128.csv", 'w')
lines = infile.readlines()
lin01=[]
lin02=[]
lin03=[]
lin04=[]
lin05=[]
lin06=[]
lin07=[]
lin08=[]
lin09=[]
lin10=[]
lin11=[]
lin12=[]
lin13=[]
lin14=[]
lin15=[]
lin16=[]
lin17=[]
lin18=[]
lin19=[]
lin20=[]
lin21=[]
lin22=[]
lin23=[]
lin24=[]
lin25=[]
lin26=[]
lin27=[]
lin28=[]
lin29=[]
lin30=[]
lin31=[]
lin32=[]

line_num = 0
num_text=""

for line in lines:
    if line_num == 0 :
        lin01.append(line)
    elif line_num == 1 :
        lin02.append(line)
    elif line_num == 2 :
        lin03.append(line)
    elif line_num == 3 :
        lin04.append(line)
    elif line_num == 4 :
        lin05.append(line)
    elif line_num == 5 :
        lin06.append(line)
    elif line_num == 6 :
        lin07.append(line)
    elif line_num == 7 :
        lin08.append(line)
    elif line_num == 8 :
        lin09.append(line)
    elif line_num == 9 :
        lin10.append(line)
    elif line_num == 10 :
        lin11.append(line)
    elif line_num == 11 :
        lin12.append(line)
    elif line_num == 12 :
        lin13.append(line)
    elif line_num == 13 :
        lin14.append(line)
    elif line_num == 14 :
        lin15.append(line)
    elif line_num == 15 :
        lin16.append(line)
    elif line_num == 16 :
        lin17.append(line)
    elif line_num == 17 :
        lin18.append(line)
    elif line_num == 18 :
        lin19.append(line)
    elif line_num == 19 :
        lin20.append(line)
    elif line_num == 20 :
        lin21.append(line)
    elif line_num == 21 :
        lin22.append(line)
    elif line_num == 22 :
        lin23.append(line)
    elif line_num == 23 :
        lin24.append(line)
    elif line_num == 24 :
        lin25.append(line)
    elif line_num == 25 :
        lin26.append(line)
    elif line_num == 26 :
        lin27.append(line)
    elif line_num == 27 :
        lin28.append(line)
    elif line_num == 28 :
        lin29.append(line)
    elif line_num == 29 :
        lin30.append(line)
    elif line_num == 30 :
        lin31.append(line)
    elif line_num == 31 :
        lin32.append(line)

    if line_num == 31 :
        line_num = 0
    else :
        line_num = line_num + 1

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
		
for lines in lin01:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text01 += str(format(int(tmp_text), '010b'))

for lines in lin02:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text02 += str(format(int(tmp_text), '010b'))

for lines in lin03:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text03 += str(format(int(tmp_text), '010b'))

for lines in lin04:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text04 += str(format(int(tmp_text), '010b'))

for lines in lin05:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text05 += str(format(int(tmp_text), '010b'))
		
for lines in lin06:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text06 += str(format(int(tmp_text), '010b'))

for lines in lin07:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text07 += str(format(int(tmp_text), '010b'))

for lines in lin08:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text08 += str(format(int(tmp_text), '010b'))

for lines in lin09:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text09 += str(format(int(tmp_text), '010b'))

for lines in lin10:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text10 += str(format(int(tmp_text), '010b'))

for lines in lin11:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text11 += str(format(int(tmp_text), '010b'))

for lines in lin12:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text12 += str(format(int(tmp_text), '010b'))

for lines in lin13:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text13 += str(format(int(tmp_text), '010b'))

for lines in lin14:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text14 += str(format(int(tmp_text), '010b'))

for lines in lin15:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text15 += str(format(int(tmp_text), '010b'))
		
for lines in lin16:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text16 += str(format(int(tmp_text), '010b'))

for lines in lin17:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text17 += str(format(int(tmp_text), '010b'))

for lines in lin18:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text18 += str(format(int(tmp_text), '010b'))

for lines in lin19:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text19 += str(format(int(tmp_text), '010b'))

for lines in lin20:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text20 += str(format(int(tmp_text), '010b'))

for lines in lin21:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text21 += str(format(int(tmp_text), '010b'))

for lines in lin22:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text22 += str(format(int(tmp_text), '010b'))

for lines in lin23:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text23 += str(format(int(tmp_text), '010b'))

for lines in lin24:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text24 += str(format(int(tmp_text), '010b'))

for lines in lin25:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text25 += str(format(int(tmp_text), '010b'))
		
for lines in lin26:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text26 += str(format(int(tmp_text), '010b'))

for lines in lin27:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text27 += str(format(int(tmp_text), '010b'))

for lines in lin28:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text28 += str(format(int(tmp_text), '010b'))
		
for lines in lin29:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text29 += str(format(int(tmp_text), '010b'))

for lines in lin30:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text30 += str(format(int(tmp_text), '010b'))

for lines in lin31:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text31 += str(format(int(tmp_text), '010b'))

for lines in lin32:
    tmp_list = lines.strip().split(",")
    for tmp_text in tmp_list:
        all_text32 += str(format(int(tmp_text), '010b'))
		
v01 = [all_text01[i: i+160] for i in range(0, len(all_text01), 160)]
v02 = [all_text02[i: i+160] for i in range(0, len(all_text02), 160)]
v03 = [all_text03[i: i+160] for i in range(0, len(all_text03), 160)]
v04 = [all_text04[i: i+160] for i in range(0, len(all_text04), 160)]
v05 = [all_text05[i: i+160] for i in range(0, len(all_text05), 160)]
v06 = [all_text06[i: i+160] for i in range(0, len(all_text06), 160)]
v07 = [all_text07[i: i+160] for i in range(0, len(all_text07), 160)]
v08 = [all_text08[i: i+160] for i in range(0, len(all_text08), 160)]
v09 = [all_text09[i: i+160] for i in range(0, len(all_text09), 160)]
v10 = [all_text10[i: i+160] for i in range(0, len(all_text10), 160)]
v11 = [all_text11[i: i+160] for i in range(0, len(all_text11), 160)]
v12 = [all_text12[i: i+160] for i in range(0, len(all_text12), 160)]
v13 = [all_text13[i: i+160] for i in range(0, len(all_text13), 160)]
v14 = [all_text14[i: i+160] for i in range(0, len(all_text14), 160)]
v15 = [all_text15[i: i+160] for i in range(0, len(all_text15), 160)]
v16 = [all_text16[i: i+160] for i in range(0, len(all_text16), 160)]
v17 = [all_text17[i: i+160] for i in range(0, len(all_text17), 160)]
v18 = [all_text18[i: i+160] for i in range(0, len(all_text18), 160)]
v19 = [all_text19[i: i+160] for i in range(0, len(all_text19), 160)]
v20 = [all_text20[i: i+160] for i in range(0, len(all_text20), 160)]
v21 = [all_text21[i: i+160] for i in range(0, len(all_text21), 160)]
v22 = [all_text22[i: i+160] for i in range(0, len(all_text22), 160)]
v23 = [all_text23[i: i+160] for i in range(0, len(all_text23), 160)]
v24 = [all_text24[i: i+160] for i in range(0, len(all_text24), 160)]
v25 = [all_text25[i: i+160] for i in range(0, len(all_text25), 160)]
v26 = [all_text26[i: i+160] for i in range(0, len(all_text26), 160)]
v27 = [all_text27[i: i+160] for i in range(0, len(all_text27), 160)]
v28 = [all_text28[i: i+160] for i in range(0, len(all_text28), 160)]
v29 = [all_text29[i: i+160] for i in range(0, len(all_text29), 160)]
v30 = [all_text30[i: i+160] for i in range(0, len(all_text30), 160)]
v31 = [all_text31[i: i+160] for i in range(0, len(all_text31), 160)]
v32 = [all_text32[i: i+160] for i in range(0, len(all_text32), 160)]

for line in v01:
        outfile1.write(str(line)+'\r\n')
for line in v02:
        outfile2.write(str(line)+'\r\n')
for line in v03:
        outfile3.write(str(line)+'\r\n')
for line in v04:
        outfile4.write(str(line)+'\r\n')
for line in v05:
        outfile5.write(str(line)+'\r\n')
for line in v06:
        outfile6.write(str(line)+'\r\n')
for line in v07:
        outfile7.write(str(line)+'\r\n')
for line in v08:
        outfile8.write(str(line)+'\r\n')
for line in v09:
        outfile9.write(str(line)+'\r\n')
for line in v10:
        outfile10.write(str(line)+'\r\n')
for line in v11:
        outfile11.write(str(line)+'\r\n')
for line in v12:
        outfile12.write(str(line)+'\r\n')
for line in v13:
        outfile13.write(str(line)+'\r\n')
for line in v14:
        outfile14.write(str(line)+'\r\n')
for line in v15:
        outfile15.write(str(line)+'\r\n')
for line in v16:
        outfile16.write(str(line)+'\r\n')
for line in v17:
        outfile17.write(str(line)+'\r\n')
for line in v18:
        outfile18.write(str(line)+'\r\n')
for line in v19:
        outfile19.write(str(line)+'\r\n')
for line in v20:
        outfile20.write(str(line)+'\r\n')
for line in v21:
        outfile21.write(str(line)+'\r\n')
for line in v22:
        outfile22.write(str(line)+'\r\n')
for line in v23:
        outfile23.write(str(line)+'\r\n')
for line in v24:
        outfile24.write(str(line)+'\r\n')
for line in v25:
        outfile25.write(str(line)+'\r\n')
for line in v26:
        outfile26.write(str(line)+'\r\n')
for line in v27:
        outfile27.write(str(line)+'\r\n')
for line in v28:
        outfile28.write(str(line)+'\r\n')
for line in v29:
        outfile29.write(str(line)+'\r\n')
for line in v30:
        outfile30.write(str(line)+'\r\n')
for line in v31:
        outfile31.write(str(line)+'\r\n')
for line in v32:
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
