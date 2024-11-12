import 'dart:async';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:dynamic_bridge/global/env_manager.dart';
import 'package:dynamic_bridge/logic/file_manager.dart';
import 'package:dynamic_bridge/logic/gps_manager.dart';
import 'package:dynamic_bridge/logic/hole_detector.dart';
import 'package:dynamic_bridge/logic/photo_collector.dart';
import 'package:dynamic_bridge/logic/serial_interface.dart';
import 'package:dynamic_bridge/logic/views/settings_logic.dart';
import 'package:flutter/material.dart';

class DashboardLogic {

  // If USB, it's a PhotoCollector
  // Else, it's a CameraController
  // Awful, but I don't know how to make it work otherwise
  var cameraController;

  bool cameraWorking = false;
  Timer? _timer;

  SerialInterface? serialInterface;

  Future<XFile> takePicture() async {

    if(cameraController is CameraController){
      // built-in
      CameraController toUse = cameraController as CameraController;
      await toUse.initialize();
      return await toUse.takePicture();
    } else {
      // USB cam
      PhotoCollector toUse = cameraController as PhotoCollector;
      String? path = await toUse.getPhoto();
      return XFile(path!);
    }

  }

  void logout() {

    String loginFileName = EnvManager.getLoginFileName();
    FileManager fileManager = FileManager(loginFileName);
    fileManager.deleteFile();

  }

  void collectPhotos() {
    int interval = EnvManager.getPhotoCollectionInterval();
    if(!cameraWorking || interval == 0){
      return;
    }
    _timer = Timer.periodic(Duration(seconds: interval), (timer) async {
      // The photo collection
      XFile file = await takePicture();
      if(HoleDetector.isHole(file)){
        // TODO: Send data
      }

    });
  }

  Future<List<Widget>> dashboardCenterChildren() async{

    List<Widget> children = [];
    SettingsLogic settingsLogic = SettingsLogic();
    serialInterface = SerialInterface();

    children.add(
      const Text(
              'Dashboard',
              style: TextStyle(fontSize: 24),
            )
    );

    if(await settingsLogic.isCameraExt()){
      // The camera is external
      cameraController = PhotoCollector();
      try {
        await PhotoCollector.openExternalCamera();
        children.add(const Center(
          child: Text(
              'External Camera loaded and working.',
              style: TextStyle(fontSize: 24, color: Colors.green, ),
            ) )
        );
        cameraWorking = true;
      } catch(e) {
        children.add(
          const Text(
              'External Camera not loading!',
              style: TextStyle(fontSize: 24, color: Colors.red),
            )
        );
      }
    } else {
      // The camera is internal
      List<CameraDescription> _cameras = await availableCameras();
      if(EnvManager.isDebugAndroidMode()){
        log(_cameras.toString());
      }
      try{
        cameraController = CameraController(_cameras.elementAt(1), ResolutionPreset.medium);
        await cameraController.initialize();
        children.add(
          const Text(
              'Built-in camera loaded.',
              style: TextStyle(fontSize: 24, color: Colors.green),
            )
        );
        cameraWorking = true;
      } catch(e){
        children.add(
          const Text(
              'Built-in camera not loaded!',
              style: TextStyle(fontSize: 24, color: Colors.red),
            )
        );
      }
    }

    if(await settingsLogic.isGpsExt()){
      // External GPS
      String result = await GpsManager.isExternalGPSOn();
      if(result == ""){
        children.add(const Text(
                'Dynamic-Guard correctly loaded.',
                style: TextStyle(fontSize: 24, color: Colors.green),
              ));
      }
      else {
        children.add(Text(
                result,
                style: const TextStyle(fontSize: 24, color: Colors.red),
                textAlign: TextAlign.center,
              ));
      }
    } else {
      // Internal GPS
      if(await GpsManager.isBuiltInGPSOn()){
        children.add(const Text(
              'Built-in GPS loaded.',
              style: TextStyle(fontSize: 24, color: Colors.green),
            ));
      } else {
        children.add(const Text(
              'Built-in GPS not loaded!',
              style: TextStyle(fontSize: 24, color: Colors.red),
            ));
      }
    }

    return children;

  }

  void dispose(){
    if(_timer != null){
      _timer!.cancel();
    }
  }

}