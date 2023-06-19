import sys
import random

def read_file(input_file):
    with open(input_file, 'r') as file:
        lines = file.readlines()
    return lines

#def generate_random_numbers(count, min_value, max_value, min_distance):
#    numbers = []
#    while len(numbers) < count:
#        number = random.randint(min_value, max_value)
#        if all(abs(number - n) >= min_distance for n in numbers):
#            numbers.append(number)
#    return sorted(numbers)

def write_file(output_file, lines):
    with open(output_file, 'w') as file:
        file.writelines(lines)

def process_input_lines(input_lines):
    output_lines = []
#    random_numbers = generate_random_numbers(20, 10, 100, 10)
    random_numbers = [23, 50, 72, 91, 105, 123, 145, 172, 203, 230, 270, 293, 312, 370, 412]
    inserted_count = 0
    prev_line = ""

    for line_index, line in enumerate(input_lines):
        output_lines.append(line)

        if inserted_count < len(random_numbers):
#            output_lines.append(str(random_numbers[inserted_count]) + '\n')
            inserted_count += 1

            if line.strip() == "SOP":
                output_lines.extend("HDP\n")
                output_lines.extend("HDP\n")
                output_lines.append("EOP-INT\n")
                output_lines.extend(["ILDE\n"] * random.randint(1, 5))
                output_lines.append("SOP-INT\n")
                output_lines.extend("HDP\n")
                output_lines.extend("HDP\n")
            elif line.strip() == "HDP":
                if prev_line == "SOP" :
                    output_lines.extend("HDP\n")
                    output_lines.extend("HDP\n")
                output_lines.append("EOP-INT\n")
                output_lines.extend(["ILDE\n"] * random.randint(1, 5))
                output_lines.append("SOP-INT\n")
                output_lines.extend("HDP\n")

        prev_line = line.strip()

    return output_lines

def main():
    if len(sys.argv) < 3:
        return

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    input_lines = read_file(input_file)
    line_count = len(input_lines)

    output_lines = process_input_lines(input_lines)


    write_file(output_file, output_lines)

if __name__ == '__main__':
    main()

