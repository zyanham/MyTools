import random
import sys

# コマンドライン引数から出力ファイル名と生成回数を取得
if len(sys.argv) < 3:
    print("パケットの生成回数と出力ファイル名を指定してください。")
    sys.exit(1)

num_iterations = int(sys.argv[1])
output_file = sys.argv[2]

# テキスト生成とファイル出力
with open(output_file, "w") as file:
    for _ in range(num_iterations):
        # IDLEを生成
        idle_word = random.randint(4, 10)
        file.write("IT\n" * idle_word)

        # SOPを生成
        file.write("SOP\n")

        # HDFを生成
        hdf_word = random.randint(4, 40)
        file.write("HDP\n" * hdf_word)

        # EOPを生成
        file.write("EOP\n")

        # IDLEを生成
        idle_word = random.randint(4, 10)
        file.write("IT\n" * idle_word)

    # ファイルへの書き込み完了
    print("テキスト生成が完了しました。")

