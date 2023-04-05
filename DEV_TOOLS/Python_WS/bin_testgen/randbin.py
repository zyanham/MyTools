import random

##Minimum 128
LENGTH_LIST=[  128,   190,   267,   321,   430,   531,   738,  1093,  2490,  5304, 
              7438,  9302, 10239, 16791, 20123, 37049, 40697, 50193, 58041, 65535]
FILE_NUM=1

#print(random.randint(0,255))

for LENGTH in LENGTH_LIST:
    #print (LENGTH)

    if FILE_NUM < 10 :
        filename = "test03_0" + str(FILE_NUM) + ".bin"
    else :
        filename = "test03_"  + str(FILE_NUM) + ".bin"

    outfile = open(filename, 'wb')

    for i in range(LENGTH):
        data = random.randint(0,255)
        outfile.write(data.to_bytes(1, 'little'))

    outfile.close()
    FILE_NUM=FILE_NUM+1
