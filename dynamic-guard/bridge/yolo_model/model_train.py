from ultralytics import YOLO

model = YOLO('dynamic-guard/bridge/yolo_model/yolov8n.pt')

model.train(
    data="C:/Users/filip/Desktop/Universita/Anno IV - Semestre I/IOT/pave-guard/dynamic-guard/bridge/yolo_model/datasets/dataset.yaml",
    epochs=50,
    imgsz=640,
    batch=16,
)

model.val(data="C:/Users/filip/Desktop/Universita/Anno IV - Semestre I/IOT/pave-guard/dynamic-guard/bridge/yolo_model/datasets/dataset.yaml")