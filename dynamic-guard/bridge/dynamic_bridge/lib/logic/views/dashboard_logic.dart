import 'dart:async';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:dynamic_bridge/global/env_manager.dart';
import 'package:dynamic_bridge/logic/file_manager.dart';
import 'package:dynamic_bridge/logic/gps_manager.dart';
import 'package:dynamic_bridge/logic/hole_detector.dart';
import 'package:dynamic_bridge/logic/photo_collector.dart';
import 'package:dynamic_bridge/logic/views/settings_logic.dart';
import 'package:flutter/material.dart';

class DashboardLogic {

  // If USB, it's a PhotoCollector
  // Else, it's a CameraController
  // Awful, but I don't know how to make it work otherwise
  var cameraController;

  Future<String?> takePicture() async {

    if(cameraController is CameraController){
      // built-in
      CameraController toUse = cameraController as CameraController;
      XFile file = await toUse.takePicture();
      return await file.readAsString();
    } else {
      // USB cam
      PhotoCollector toUse = cameraController as PhotoCollector;
      return toUse.getPhoto();
    }

  }

  void logout() {

    String loginFileName = EnvManager.getLoginFileName();
    FileManager fileManager = FileManager(loginFileName);
    fileManager.deleteFile();

  }

  void collectPhotos() {
    int interval = EnvManager.getPhotoCollectionInterval();
    Timer timer = Timer.periodic(Duration(seconds: interval), (timer) async {
      // The photo collection
      String data = await takePicture() as String;
      if(HoleDetector.isHole(data)){
        // TODO: Send data
      }

    });
  }

  Future<List<Widget>> dashboardCenterChildren() async{

    List<Widget> children = [];
    SettingsLogic settingsLogic = SettingsLogic();

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
        cameraController.initialize();
        PhotoCollector.openExternalCamera();
        children.add(const Center(
          child: Text(
              'External Camera loaded and working.',
              style: TextStyle(fontSize: 24, color: Colors.green, ),
            ) )
        );
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
      cameraController = CameraController(_cameras.first, ResolutionPreset.medium);
      await cameraController.initialize();
      children.add(
          const Text(
              'Built-in camera loaded.',
              style: TextStyle(fontSize: 24, color: Colors.green),
            )
        );
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
      // TODO
      children.add(const Text(
              'Dynamic-Guard not loaded!',
              style: TextStyle(fontSize: 24, color: Colors.red),
            ));
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

}