import 'dart:developer';
import 'package:dynamic_bridge/global/env_manager.dart';
import 'package:flutter_uvc_camera/flutter_uvc_camera.dart';

class PhotoCollector {

  UVCCameraController? camera;

  // THIS must be called after instatiating!
  void initialize() async {

    // Try to open external camera
    try {
      Future<UVCCameraController> cameraController = openExternalCamera();
      camera = await cameraController;
    } catch(e) {
      if(EnvManager.isDebugAndroidMode()){
        log("Unable to open camera!");
      }
      
      return;
    }
  }

  static Future<UVCCameraController> openExternalCamera() async{

    UVCCameraController cameraController = UVCCameraController();
    return cameraController;

  }

  Future<String?> getPhoto() async {

    if(camera == null){
      return "";
    }

    return camera!.takePicture();

  }

  void close(){

    if(camera == null){
      throw Exception("The camera isn't loaded!");
    }

    camera!.closeCamera();
    camera!.dispose();

  }

}