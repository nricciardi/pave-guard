import 'dart:js_interop';

import 'package:dynamic_bridge/global/env_manager.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:flutter_uvc_camera/flutter_uvc_camera.dart';

class PhotoCollector {

  UVCCameraController? camera;
  SerialPort? port;

  // THIS must be called after instatiating!
  void initialize(){

    if(EnvManager.isDebugAndroidMode()){
      print(SerialPort.availablePorts);
    }

    // Try to open USB port
    try {
      port = openPortUSB();
    } catch(e) {
      if(EnvManager.isDebugAndroidMode()){
        print("Unable to open USB port!");
      }
    }

    // Try to open external camera
    try {
      
      Future<UVCCameraController> cameraController = openExternalCamera();
      
      cameraController.then( (loadedCamera) {
        camera = loadedCamera;
      } );

    } catch(e) {

      if(EnvManager.isDebugAndroidMode()){
        print("Unable to open camera!");
      }
      
      return;
    }

    camera!.startCamera();
    
  }

  bool isUSBPortOpen(){

    return port != null;

  }

  static SerialPort openPortUSB(){

    SerialPort portToOpen = SerialPort("USB");

    if (portToOpen.openReadWrite() && EnvManager.isDebugAndroidMode()) {

      print('USB-C port opened successfully');
      portToOpen.config.baudRate = 9600;

    } else { throw Exception("USB port inaccessible."); }

    return portToOpen;

  }

  static Future<UVCCameraController> openExternalCamera() async{

    UVCCameraController cameraController = UVCCameraController();
    await cameraController.initializeCamera();
    await cameraController.openUVCCamera();
    return cameraController;

  }



  String getPhoto(){

    if(camera == null){
      if(EnvManager.isDebugAndroidMode()){
        print(port);
      }
      throw Exception("The camera isn't loaded!");
    }

    String photo = "";
    camera!.takePicture().then( (photoTaken) {
      photo = photoTaken!;
    });
    return photo;

  }

}