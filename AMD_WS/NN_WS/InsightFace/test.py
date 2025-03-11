import argparse
import os
import cv2
import insightface
import numpy as np
from insightface.app import FaceAnalysis

# 顔認識モデルを準備
model = FaceAnalysis(name='buffalo_l')
model.prepare(ctx_id=-1)

def get_embedding(image_path):
    """ 画像の埋め込みを取得する """
    image = cv2.imread(image_path)
    if image is None:
        print(f"⚠ 画像が読み込めません: {image_path}")
        return None
    faces = model.get(image)
    if len(faces) == 0:
        print(f"⚠ 顔が検出されません: {image_path}")
        return None
    return faces[0].embedding  # 最初の顔の特徴量を返す

def compare_embeddings(emb1, emb2, threshold=0.5):
    """ 2つの埋め込みを比較し、同一人物か判定する """
    if emb1 is None or emb2 is None:
        return False
    sim = np.dot(emb1, emb2) / (np.linalg.norm(emb1) * np.linalg.norm(emb2))
    return sim > threshold  # 閾値を超えたら同一人物

def process_pair(img1, img2):
    """ 2つの画像を比較する """
    emb1 = get_embedding(img1)
    emb2 = get_embedding(img2)
    if compare_embeddings(emb1, emb2):
        print(f"✅ {img1} と {img2} は同一人物です！")
    else:
        print(f"❌ {img1} と {img2} は別人です。")

def process_directory(img1, directory):
    """ 画像とディレクトリ内のjpgを比較する """
    emb1 = get_embedding(img1)
    if emb1 is None:
        return
    
    print(f"🔍 {directory} 内の画像と {img1} を比較中...")
    for filename in os.listdir(directory):
        if filename.lower().endswith(".jpg"):
            img2_path = os.path.join(directory, filename)
            emb2 = get_embedding(img2_path)
            if compare_embeddings(emb1, emb2):
                print(f"✅ {img2_path} は同一人物の可能性あり！")

# コマンドライン引数の解析
parser = argparse.ArgumentParser(description="顔認識で画像を比較")
parser.add_argument("-p", nargs=2, metavar=("IMAGE1", "IMAGE2"), help="2枚の画像を比較")
parser.add_argument("-l", nargs=2, metavar=("IMAGE", "DIRECTORY"), help="1枚の画像とディレクトリ内の画像を比較")

args = parser.parse_args()

if args.p:
    process_pair(args.p[0], args.p[1])
elif args.l:
    process_directory(args.l[0], args.l[1])
else:
    print("⚠ オプションが指定されていません。 -p か -l を使ってください。")

