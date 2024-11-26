import 'package:camera/camera.dart';
import 'package:flutter_vision/flutter_vision.dart';

class HoleDetector {

  FlutterVision flutterVision = FlutterVision();

  Future<void> initialize() async {
    await flutterVision.loadYoloModel(
      modelPath: "assets/model.tflite", 
      labels: "assets/labels.txt", 
      modelVersion: "yolov8",
      quantization: false,
      numThreads: 1,
      useGpu: false
      );
  }

  static bool isHole(XFile file){

    // TODO: Check if it's a hole

    return false;

  }

}