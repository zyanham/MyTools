import sys
import random

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

    return result

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("生成数と生成範囲を指定してください。")
        sys.exit(1)

    num = int(sys.argv[1])
    range_max = int(sys.argv[2])

    random_numbers = generate_random_numbers(num, range_max)
    print(random_numbers)

