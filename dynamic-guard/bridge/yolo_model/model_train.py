from ultralytics import YOLO

model = YOLO('dynamic-guard/bridge/yolo_model/yolov8n.pt')

model.train(
    data="datasets/dataset.yaml",
    epochs=50,
    imgsz=640,
    batch=32,
)

model.val(data="datasets/dataset.yaml")