import random

output_file = "output.txt"  # 出力ファイル名
strings = ["IDLE", "SOP", "HDP", "EOP"]  # 繰り返す文字列のリスト

with open(output_file, "w") as file:
    line_count = 0  # 行数のカウンター
    while line_count < 512:
        # IDLEの出力
        idle_count = random.randint(4, 40)
        for _ in range(idle_count):
            file.write(strings[0] + "\n")
            line_count += 1
            if line_count >= 512:
                break

        if line_count >= 512:
            break

        # SOPの出力
        file.write(strings[1] + "\n")
        line_count += 1
        if line_count >= 512:
            break

        # HDPの出力
        hdp_count = random.randint(4, 40)
        for _ in range(hdp_count):
            file.write(strings[2] + "\n")
            line_count += 1
            if line_count >= 512:
                break

        if line_count >= 512:
            break

        # EOPの出力
        file.write(strings[3] + "\n")
        line_count += 1

        if line_count >= 512:
            break

        # 512行に達した場合の条件ごとの処理
        if line_count == 511 and strings[3] == "SOP":
            # 最後に出力したものがSOPの場合
            for _ in range(4):  # HDPを4回出力
                file.write(strings[2] + "\n")
            for _ in range(1):  # EOPを1回出力
                file.write(strings[3] + "\n")
            for _ in range(10):  # IDLEを10回出力
                file.write(strings[0] + "\n")
        elif line_count == 511 and strings[3] == "HDP":
            # 最後に出力したものがHDPの場合
            for _ in range(1):  # EOPを1回出力
                file.write(strings[3] + "\n")
            for _ in range(10):  # IDLEを10回出力
                file.write(strings[0] + "\n")
        elif line_count == 511 and strings[3] == "EOP":
            # 最後に出力したものがEOPの場合
            for _ in range(10):  # IDLEを10回出力
                file.write(strings[0] + "\n")


