from ultralytics import YOLO

model = YOLO("yolo11n-pose.pt")
model.export(
    format="onnx",
    imgsz=640,
    dynamic=False,
    simplify=False,
    nms=False,
)