import cv2
import mediapipe as mp

# Mediapipe Poseの初期化
mp_pose = mp.solutions.pose
mp_drawing = mp.solutions.drawing_utils

# 画像の読み込み
image_path = "input.jpg"  # 解析したい画像のパス
image = cv2.imread(image_path)
if image is None:
    print("画像が見つかりません")
    exit()

# OpenCVのBGRをRGBに変換（MediapipeはRGBを使用）
image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

# Pose推論
with mp_pose.Pose(static_image_mode=True) as pose:
    results = pose.process(image_rgb)

    if results.pose_landmarks:
        # キーポイントを描画
        annotated_image = image.copy()
        mp_drawing.draw_landmarks(
            annotated_image, results.pose_landmarks, mp_pose.POSE_CONNECTIONS
        )

        # 結果を保存
        output_path = "output.jpg"
        cv2.imwrite(output_path, annotated_image)
        print(f"出力画像を保存しました: {output_path}")

        # 画像を表示
        cv2.imshow("Pose Estimation", annotated_image)
        cv2.waitKey(0)
        cv2.destroyAllWindows()
    else:
        print("ポーズが検出されませんでした")

