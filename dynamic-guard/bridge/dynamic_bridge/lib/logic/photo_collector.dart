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
      camera!.startCamera();

    } catch(e) {

      if(EnvManager.isDebugAndroidMode()){
        log("Unable to open camera!");
      }
      
      return;
    }
  }

  static Future<UVCCameraController> openExternalCamera() async{

    UVCCameraController cameraController = UVCCameraController();
    await cameraController.initializeCamera();
    await cameraController.openUVCCamera();
    return cameraController;

  }

  String getPhoto(){

    if(camera == null){
      throw Exception("The camera isn't loaded!");
    }

    String photo = "";
    camera!.takePicture().then( (photoTaken) {
      photo = photoTaken!;
    });
    return photo;

  }

}