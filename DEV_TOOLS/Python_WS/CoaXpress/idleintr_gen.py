import sys
import random

def read_file(input_file):
    with open(input_file, 'r') as file:
        lines = file.readlines()
    return lines


def write_file(output_file, lines):
    with open(output_file, 'w') as file:
        file.writelines(lines)

def generate_random_numbers(num, range_max):
    if range_max < 256:
        print("生成範囲は256以上である必要があります。")
        sys.exit(1)

    if num * 10 > range_max:
        print("生成数が多すぎます。各値が10以上離れるように生成範囲を調整してください。")
        sys.exit(1)

    result = []
    for _ in range(num):
        value = random.randint(0, range_max)
        while any(abs(value - x) < 10 for x in result):
            value = random.randint(0, range_max)
        result.append(value)

    result.sort()  # 生成された数値を小さい順にソート
    print(str(result))
    return result


def process_input_lines(input_lines, random_numbers):
    output_lines = []
#    random_numbers = [23, 50, 72, 91, 105, 123, 145, 172, 203, 230, 270, 293, 312, 370, 412]
    inserted_count = 0
    prev_line = ""

    if random_numbers :
        first_num = random_numbers[0]
        random_numbers.pop(0)

    for line_index, line in enumerate(input_lines):
        output_lines.append(line)

#        if inserted_count < len(random_numbers):
        if inserted_count == first_num :
#            output_lines.append(str(random_numbers[inserted_count]) + '\n')
#            print(str(inserted_count)+" "+str(first_num))
            if line.strip() == "SOP":
                output_lines.extend("HDP\n")
                output_lines.extend("HDP\n")
                output_lines.append("EOP-INT\n")
                output_lines.extend(["IT\n"] * random.randint(1, 5))
                output_lines.append("SOP-INT\n")
                output_lines.extend("HDP\n")
                output_lines.extend("HDP\n")
            elif line.strip() == "HDP":
                if prev_line == "SOP" :
                    output_lines.extend("HDP\n")
                    output_lines.extend("HDP\n")
                output_lines.append("EOP-INT\n")
                output_lines.extend(["IT\n"] * random.randint(1, 5))
                output_lines.append("SOP-INT\n")
                output_lines.extend("HDP\n")
            if random_numbers :
                first_num = random_numbers[0]
                random_numbers.pop(0)
            else :
                first_num = 100000000;

        inserted_count += 1
        prev_line = line.strip()

    return output_lines

def main():
#    if len(sys.argv) < 5:
    if len(sys.argv) < 4:
        return

    input_file = sys.argv[1]
    output_file = sys.argv[2]
    num = int(sys.argv[3])
#    range_max = int(sys.argv[4])


    input_lines = read_file(input_file)
    line_count = len(input_lines)
    random_numbers = generate_random_numbers(num, line_count)

    output_lines = process_input_lines(input_lines, random_numbers)

    write_file(output_file, output_lines)

if __name__ == '__main__':
    main()

