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
    inserted_count = 0
    prev_line = ""

    if random_numbers :
        first_num = random_numbers[0]
        random_numbers.pop(0)

    for line_index, line in enumerate(input_lines):
#        output_lines.append(line)

        if inserted_count == first_num :
            if line.strip() == "IT":
                output_lines.append(line)
                output_lines.extend("SOP-TRG\n")
                output_lines.extend("HDP-TRG\n")
                output_lines.extend("EOP-TRG\n")
            elif line.strip() == "SOP":
                output_lines.append(line)
                output_lines.extend("HDP\n")
                output_lines.extend("EOP-TRG\n")
                output_lines.extend("SOP-TRG\n")
                output_lines.extend("HDP-TRG\n")
                output_lines.extend("HDP\n")
            elif line.strip() == "HDP":
                output_lines.append(line)
                output_lines.extend("EOP-TRG\n")
                output_lines.extend("SOP-TRG\n")
                output_lines.extend("HDP-TRG\n")
                output_lines.extend("HDP\n")
            elif line.strip() == "EOP":
                output_lines.append(line)
                output_lines.extend("SOP-TRG\n")
                output_lines.extend("HDP-TRG\n")
                output_lines.extend("EOP-TRG\n")
            elif line.strip() == "SOP-INT":
                output_lines.append(line)
                output_lines.extend("HDP\n")
                output_lines.extend("EOP-TRG\n")
                output_lines.extend("SOP-TRG\n")
                output_lines.extend("HDP-TRG\n")
                output_lines.extend("HDP\n")
            elif line.strip() == "EOP-INT":
                output_lines.append(line)
                output_lines.extend("SOP-TRG\n")
                output_lines.extend("HDP-TRG\n")
                output_lines.extend("EOP-TRG\n")
            elif line.strip() == "SOP-IOACK":
                if prev_line == "EOP-IOACK":
                    output_lines.extend("SOP-TRG\n")
                    output_lines.extend("HDP-TRG\n")
                    output_lines.extend("EOP-TRG\n")
                    output_lines.append(line)
                else :
                    output_lines.extend("SOP-TRG\n")
                    output_lines.extend("HDP-TRG\n")
                    output_lines.extend("EOP-TRG\n")
                    output_lines.append(line)
            elif line.strip() == "HDP-IOACK":
                    output_lines.append(line)
            elif line.strip() == "EOP-IOACK":
                if prev_line == "HDF-IOACK":
                    output_lines.append(line)
                    output_lines.extend("SOP-TRG\n")
                    output_lines.extend("HDP-TRG\n")
                    output_lines.extend("EOP-TRG\n")
                else:
                    output_lines.append(line)
                    output_lines.extend("IT\n")
                    output_lines.extend("IT\n")
                    output_lines.extend("IT\n")
                    output_lines.extend("SOP-TRG\n")
                    output_lines.extend("HDP-TRG\n")
                    output_lines.extend("EOP-TRG\n")

            if random_numbers :
                first_num = random_numbers[0]
                random_numbers.pop(0)
            else :
                first_num = 100000000;
        else:
            output_lines.append(line)

        inserted_count += 1
        prev_line = line.strip()

    return output_lines

def main():
    if len(sys.argv) < 4:
        return

    input_file = sys.argv[1]
    output_file = sys.argv[2]
    num = int(sys.argv[3])

    input_lines = read_file(input_file)
    line_count = len(input_lines)
    random_numbers = generate_random_numbers(num, line_count)

    output_lines = process_input_lines(input_lines, random_numbers)

    write_file(output_file, output_lines)

if __name__ == '__main__':
    main()

