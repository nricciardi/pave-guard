import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:dynamic_bridge/global/env_manager.dart';
import 'package:dynamic_bridge/logic/file_manager.dart';
import 'package:dynamic_bridge/logic/gps_manager.dart';
import 'package:dynamic_bridge/logic/hole_detector.dart';
import 'package:dynamic_bridge/logic/nominatim_manager.dart';
import 'package:dynamic_bridge/logic/photo_collector.dart';
import 'package:dynamic_bridge/logic/query_manager.dart';
import 'package:dynamic_bridge/logic/serial_interface.dart';
import 'package:dynamic_bridge/logic/token_manager.dart';
import 'package:dynamic_bridge/logic/vibration_manager.dart';
import 'package:dynamic_bridge/logic/views/settings_logic.dart';
import 'package:dynamic_bridge/views/devices.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uvc_camera/flutter_uvc_camera.dart';
import 'package:usb_serial/transaction.dart';

class DashboardLogic {
  // If USB, it's a PhotoCollector
  // Else, it's a CameraController
  // Awful, but I don't know how to make it work otherwise
  var cameraController;

  NominatimManager nominatimManager = NominatimManager();

  bool cameraWorking = false;
  Timer? _timer;

  SerialInterface? serialInterface;
  HoleDetector? holeDetector;
  
  DeviceData deviceData;
  DashboardLogic(this.deviceData);

  Future<XFile?> takePicture() async {
    if (cameraController is CameraController) {
      // built-in
      CameraController toUse = cameraController as CameraController;
      try{
        return await toUse.takePicture();
        }catch(e){
          return null;
        }
    } else {
      // USB cam
      PhotoCollector toUse = cameraController as PhotoCollector;
      String? path = await toUse.getPhoto();
      // TODO: ritorna davvero un percorso?
      return XFile(path!);
    }
  }

  void logout() {
    String loginFileName = EnvManager.getLoginFileName();
    FileManager fileManager = FileManager(loginFileName);
    fileManager.deleteFile();
  }

  void collectAndSendTelemetries() async {
    serialInterface ??= SerialInterface();
    if(serialInterface!.isInitialized == true){ return; }
    try {
      serialInterface = SerialInterface();
      await serialInterface!.initialize();
      Transaction<String> transaction = Transaction.stringTerminated(
          serialInterface!.port!.inputStream!, Uint8List.fromList([10, 10])
          );
      transaction.stream.listen((String data) async {
        for (String line in data.split("\n")) {
          if(line.isNotEmpty){
            serialInterface!.manageSerialLine(line.trim());
          }
        }
        await serialInterface!.sendData(deviceData);
      });
    } catch (e) {
      serialInterface = null;
    }
  }

  void collectPhotos() {
    int interval = EnvManager.getPhotoCollectionInterval();
    if (!cameraWorking || interval == 0) {
      return;
    }
    _timer = Timer.periodic(Duration(seconds: interval), (timer) async {
      // The photo collection
      XFile? file = await takePicture();
      if(file == null){return;}
      int holeSeverity = await holeDetector!.isHole(file);
      if (holeSeverity > 0) {
        RoadPotholeTelemetryQuery telemetryQuery = RoadPotholeTelemetryQuery();
        GPSData? gpsData;
        try{ 
          gpsData = serialInterface!.vibrationManager.getGpsData();
        } catch (e) {
          return;
        }
        telemetryQuery.sendQuery( 
          HoleSendableData(holeSeverity, deviceData, gpsData.latitude, gpsData.longitude, await nominatimManager.sendQuery(gpsData)), 
          token: await TokenManager.getToken()
        );
      }
    });
  }

  Future<List<Widget>> dashboardCenterChildren() async {
    List<Widget> children = [];
    SettingsLogic settingsLogic = SettingsLogic();
    if(holeDetector == null){
      holeDetector = HoleDetector();
      await holeDetector!.initialize();
    }

    children.add(const Text(
      'Dashboard',
      style: TextStyle(fontSize: 24),
    ));

    if (await settingsLogic.isCameraExt()) {
      // The camera is external
      cameraController = PhotoCollector();
      try {
        UVCCameraController uvcCameraController =
            await PhotoCollector.openExternalCamera();
        children.add(UVCCameraView(
          cameraController: uvcCameraController,
          width: 480, height: 480
        ));
        children.add(const Text(
          'External Camera loaded and working.',
          style: TextStyle(fontSize: 24, color: Colors.green),
          textAlign: TextAlign.center,
        ));
        uvcCameraController.msgCallback;
        cameraWorking = true;
      } catch (e) {
        children.add(const Text(
          'External Camera not loading!',
          style: TextStyle(fontSize: 24, color: Colors.red),
        ));
      }
    } else {
      // The camera is internal
      List<CameraDescription> cameras = await availableCameras();
      if (EnvManager.isDebugAndroidMode()) {
        log(cameras.toString());
      }
      try {
        cameraController =
            CameraController(cameras.elementAt(0), ResolutionPreset.medium);
        await cameraController.initialize();
        children.add(const Text(
          'Built-in camera loaded.',
          style: TextStyle(fontSize: 24, color: Colors.green),
        ));
        cameraWorking = true;
        children.add(CameraPreview(cameraController));
      } catch (e) {
        children.add(const Text(
          'Built-in camera not loaded!',
          style: TextStyle(fontSize: 24, color: Colors.red),
        ));
      }
    }

    if (await settingsLogic.isGpsExt()) {
      // External GPS
      String result = await GpsManager.isExternalGPSOn(serialInterface);
      if (result == "") {
        children.add(const Text(
          'Dynamic-Guard correctly loaded.',
          style: TextStyle(fontSize: 24, color: Colors.green),
        ));
      } else {
        children.add(Text(
          result,
          style: const TextStyle(fontSize: 24, color: Colors.red),
          textAlign: TextAlign.center,
        ));
      }
    } else {
      // Internal GPS
      if (await GpsManager.isBuiltInGPSOn()) {
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

  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }
  }
}
