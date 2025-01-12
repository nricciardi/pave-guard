import 'dart:developer';
import 'package:dynamic_bridge/global/env_manager.dart';
import 'package:flutter_uvc_camera/flutter_uvc_camera.dart';

class PhotoCollector {

  UVCCameraController? camera;

  // THIS must be called after instatiating!
  void initialize() async {

    // Try to open external camera
    try {
      Future<UVCCameraView> cameraController = openExternalCamera();
      camera = (await cameraController).cameraController;
    } catch(e) {
      if(EnvManager.isDebugAndroidMode()){
        log("Unable to open camera!");
      }
      
      return;
    }
  }

  static Future<UVCCameraView> openExternalCamera() async{

    UVCCameraController cameraController = UVCCameraController();
    UVCCameraView uvcCameraView = UVCCameraView(
                    cameraController: cameraController,
                    width: 480,
                    height: 480,
                  );
    if(uvcCameraView.cameraController.getCameraState != UVCCameraState.opened){
        return uvcCameraView;
    }
    throw Exception("Error opening camera!");

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