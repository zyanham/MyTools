import os
import cv2
import numpy as np
import onnxruntime as ort

# UltraFaceモデルのパス
MODEL_PATH = "./models/version-RFB-640.onnx"

# モデルの入力サイズ
INPUT_WIDTH = 640
INPUT_HEIGHT = 480

# スコア閾値とNMS閾値
CONFIDENCE_THRESHOLD = 0.7
NMS_THRESHOLD = 0.3

# ONNX Runtimeセッションの作成
session = ort.InferenceSession(MODEL_PATH)
input_name = session.get_inputs()[0].name
output_names = [output.name for output in session.get_outputs()]

# ディレクトリ設定
INPUT_DIR = "../Dataset/HumanFaces"  # 入力画像のディレクトリ
OUTPUT_DIR = "./Result"  # 出力結果のディレクトリ
os.makedirs(OUTPUT_DIR, exist_ok=True)

# 推論関数
def preprocess(image):
    resized = cv2.resize(image, (INPUT_WIDTH, INPUT_HEIGHT))
    normalized = resized.astype(np.float32) - 127.0
    normalized /= 128.0
    transposed = np.transpose(normalized, (2, 0, 1))  # HWC -> CHW
    return np.expand_dims(transposed, axis=0)  # CHW -> NCHW

def postprocess(image, scores, boxes):
    h, w, _ = image.shape
    boxes[:, [0, 2]] *= w
    boxes[:, [1, 3]] *= h
    indices = cv2.dnn.NMSBoxes(
        boxes.tolist(), scores.tolist(), CONFIDENCE_THRESHOLD, NMS_THRESHOLD
    )
    if len(indices) > 0:
        indices = indices.flatten()
        return boxes[indices], scores[indices]
    return [], []

# JPEG画像に対する処理
for file_name in os.listdir(INPUT_DIR):
    if file_name.lower().endswith(".jpg"):
        input_path = os.path.join(INPUT_DIR, file_name)
        output_path = os.path.join(OUTPUT_DIR, file_name)

        image = cv2.imread(input_path)
        input_tensor = preprocess(image)
        scores, boxes = session.run(output_names, {input_name: input_tensor})

        scores = scores[0][:, 1]  # 背景クラスを除外
        boxes = boxes[0]

        mask = scores > CONFIDENCE_THRESHOLD
        scores = scores[mask]
        boxes = boxes[mask]

        boxes, scores = postprocess(image, scores, boxes)

        for box in boxes:
            x1, y1, x2, y2 = box.astype(int)
            cv2.rectangle(image, (x1, y1), (x2, y2), (0, 255, 0), 2)

        cv2.imwrite(output_path, image)
        print(f"Processed {file_name}")

