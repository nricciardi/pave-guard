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

    port = openPortUSB();
    openExternalCamera().then( (loadedCamera) {
      camera = loadedCamera;
    } );

    camera!.startCamera();
    
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
    await cameraController.openUVCCamera();
    return cameraController;

  }

  String getPhoto(){

    String photo = "";
    camera!.takePicture().then( (photoTaken) {
      photo = photoTaken!;
    });
    return photo;

  }

}