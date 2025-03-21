import argparse
import os
import cv2
import numpy as np
from insightface.app import FaceAnalysis

# 閾値（0.5以上なら同一人物とみなす）
THRESHOLD = 0.5

def load_face_embedding(model, image_path):
    """画像から顔の埋め込みベクトルを取得"""
    image = cv2.imread(image_path)
    if image is None:
        print(f"Error: 画像を読み込めませんでした → {image_path}")
        return None
    
    faces = model.get(image)
    if len(faces) == 0:
        print(f"Warning: 顔が検出されませんでした → {image_path}")
        return None

    return faces[0].normed_embedding  # 正規化埋め込みベクトルを返す

def cosine_similarity(vec1, vec2):
    """コサイン類似度を計算"""
    return np.dot(vec1, vec2) / (np.linalg.norm(vec1) * np.linalg.norm(vec2))

def compare_two_images(model, imageA, imageB):
    """2つの画像を比較"""
    embeddingA = load_face_embedding(model, imageA)
    embeddingB = load_face_embedding(model, imageB)

    if embeddingA is None or embeddingB is None:
        return
    
    similarity = cosine_similarity(embeddingA, embeddingB)
    print(f"類似度: {similarity:.3f}")

    if similarity >= THRESHOLD:
        print("✅ 同一人物です！")
    else:
        print("❌ 別人の可能性が高いです。")

def search_directory(model, imageA, directory):
    """画像Aとディレクトリ内のJPG画像を比較"""
    embeddingA = load_face_embedding(model, imageA)
    if embeddingA is None:
        return
    
    print(f"🔍 {directory} 内の画像を検索中...")
    
    matched_files = []
    for file in os.listdir(directory):
        if file.lower().endswith(".jpg"):
            image_path = os.path.join(directory, file)
            embeddingB = load_face_embedding(model, image_path)
            if embeddingB is None:
                continue

            similarity = cosine_similarity(embeddingA, embeddingB)
            if similarity >= THRESHOLD:
                print(f"✅ {file} は同一人物の可能性あり（類似度: {similarity:.3f}）")
                matched_files.append(file)

    if not matched_files:
        print("❌ 一致する画像は見つかりませんでした。")

def main():
    parser = argparse.ArgumentParser(description="顔認識比較スクリプト")
    parser.add_argument("-p", nargs=2, metavar=("IMAGE_A", "IMAGE_B"), help="2枚の画像を比較")
    parser.add_argument("-l", nargs=2, metavar=("IMAGE_A", "DIRECTORY"), help="ディレクトリ内の画像と比較")

    args = parser.parse_args()

    # FaceAnalysisモデルの初期化
    face_app = FaceAnalysis(
        name="auraface",
        providers=["CUDAExecutionProvider", "CPUExecutionProvider"],
        root="."
    )
    face_app.prepare(ctx_id=0, det_size=(640, 640))

    if args.p:
        imageA, imageB = args.p
        compare_two_images(face_app, imageA, imageB)
    elif args.l:
        imageA, directory = args.l
        search_directory(face_app, imageA, directory)
    else:
        print("エラー: -p または -l オプションを指定してください。")

if __name__ == "__main__":
    main()

