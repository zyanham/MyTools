import cv2
import numpy as np
import onnxruntime as ort

# UltraFaceモデルのパス
MODEL_PATH = "./models/version-RFB-320.onnx"

# モデルの入力サイズ
INPUT_WIDTH = 320
INPUT_HEIGHT = 240

# スコア閾値とNMS閾値
CONFIDENCE_THRESHOLD = 0.7
NMS_THRESHOLD = 0.3

# ONNX Runtimeセッションの作成
session = ort.InferenceSession(MODEL_PATH)
input_name = session.get_inputs()[0].name
output_names = [output.name for output in session.get_outputs()]

# 推論関数
def preprocess(frame):
    resized = cv2.resize(frame, (INPUT_WIDTH, INPUT_HEIGHT))
    normalized = resized.astype(np.float32) - 127.0
    normalized /= 128.0
    transposed = np.transpose(normalized, (2, 0, 1))  # HWC -> CHW
    return np.expand_dims(transposed, axis=0)  # CHW -> NCHW

def postprocess(frame, scores, boxes):
    h, w, _ = frame.shape
    boxes[:, [0, 2]] *= w
    boxes[:, [1, 3]] *= h
    indices = cv2.dnn.NMSBoxes(
        boxes.tolist(), scores.tolist(), CONFIDENCE_THRESHOLD, NMS_THRESHOLD
    )
    if len(indices) > 0:
        indices = indices.flatten()
        return boxes[indices], scores[indices]
    return [], []

# カメラの起動
cap = cv2.VideoCapture(0)
if not cap.isOpened():
    print("Webカメラを起動できませんでした")
    exit()

print("Webカメラを起動しました。終了するには 'q' を押してください。")

while True:
    ret, frame = cap.read()
    if not ret:
        print("フレームを取得できませんでした")
        break

    input_tensor = preprocess(frame)
    scores, boxes = session.run(output_names, {input_name: input_tensor})

    scores = scores[0][:, 1]  # 背景クラスを除外
    boxes = boxes[0]
    
    # スコアが閾値を超えるものをフィルタ
    mask = scores > CONFIDENCE_THRESHOLD
    scores = scores[mask]
    boxes = boxes[mask]

    # 非極大抑制 (NMS)
    boxes, scores = postprocess(frame, scores, boxes)

    # 結果を描画
    for box in boxes:
        x1, y1, x2, y2 = box.astype(int)
        cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)

    cv2.imshow("UltraFace - Face Detection", frame)

    # 'q' キーで終了
    if cv2.waitKey(1) & 0xFF == ord("q"):
        break

cap.release()
cv2.destroyAllWindows()

