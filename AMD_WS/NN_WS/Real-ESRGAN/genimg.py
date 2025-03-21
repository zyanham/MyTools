import cv2
import numpy as np

# 代表的なカラーパレットの色 (sRGB)
colors = [
    (115, 82, 68), (194, 150, 130), (98, 122, 157), (87, 108, 67), (133, 128, 177), (103, 189, 170),
    (214, 126, 44), (80, 91, 166), (193, 90, 99), (94, 60, 108), (157, 188, 64), (224, 163, 46),
    (56, 61, 150), (70, 148, 73), (175, 54, 60), (231, 199, 31), (187, 86, 149), (8, 133, 161),
    (243, 243, 242), (200, 200, 200), (160, 160, 160), (122, 122, 121), (85, 85, 85), (52, 52, 52)
]

# 画像サイズ
rows, cols = 4, 6  # 4行 x 6列
square_size = 100  # 各色の正方形サイズ
img_height = rows * square_size
img_width = cols * square_size

# カラーパレット画像を作成
palette = np.zeros((img_height, img_width, 3), dtype=np.uint8)

# 各色を配置
for i in range(rows):
    for j in range(cols):
        color = colors[i * cols + j]
        y_start, y_end = i * square_size, (i + 1) * square_size
        x_start, x_end = j * square_size, (j + 1) * square_size
        palette[y_start:y_end, x_start:x_end] = color

# 画像を保存
cv2.imwrite("input.jpg", palette)

print("カラーパレット画像 'input.jpg' を出力しました。")

