import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:dynamic_bridge/views/devices.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:image_size_getter/image_size_getter.dart';

class HoleSendableData{

  int severity;
  DeviceData deviceData;
  double latitude;
  double longitude;
  String road;
  HoleSendableData(this.severity, this.deviceData, this.latitude, this.longitude, this.road);

}

class HoleDetector {

  FlutterVision flutterVision = FlutterVision();
  static const double confidenceValue = 0.4;
  static const double classThreshold = 0.3;

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

  Future<int> isHole(XFile file) async {

    Uint8List bytes = await file.readAsBytes();
    Size size = ImageSizeGetter.getSize(MemoryInput(bytes));
    List<Map<String, dynamic>> result = await flutterVision.yoloOnImage(
      bytesList: bytes, 
      imageHeight: size.height, imageWidth: size.width,
      confThreshold: confidenceValue,
      classThreshold: classThreshold,
    );

    if(result.isEmpty){ return 0; }
    else { 
      Float32List array = result[0]["box"];
      double severity = (array[0] - array[1]).abs() + (array[2] - array[3]).abs();
      severity /= (720 * 2);
      severity *= (array[4] * 100);
      return severity.toInt();
    }

  }

}