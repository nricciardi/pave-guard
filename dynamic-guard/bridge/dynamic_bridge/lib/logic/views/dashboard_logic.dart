import 'dart:async';
import 'dart:developer';
import 'dart:io';
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

  bool holeRecentlyFound = false;
  int seenHoles = 0;

  SerialInterface? serialInterface;
  HoleDetector? holeDetector;

  UVCCameraView? uvcCameraView;

  DeviceData deviceData;
  DashboardLogic(this.deviceData);

  Future<XFile?> takePicture() async {
    if (cameraController is CameraController) {
      // built-in
      CameraController toUse = cameraController as CameraController;
      try {
        return await toUse.takePicture();
      } catch (e) {
        return null;
      }
    } else {
      // USB cam
      if(uvcCameraView == null){
        return null;
      }
      String? path = await uvcCameraView!.cameraController.takePicture();
      // TODO: Rimuovere questa linea di debug
      if(path != ''){
        log("Magia!");
      }
      // TODO: ritorna davvero un percorso?
      return path != '' ? XFile(path!) : null;
    }
  }

  bool shouldReload(){
    if(holeRecentlyFound){
      return true;
    }
    if(cameraController is CameraController){
      return false;
    } else {
      // USB cam
      if(uvcCameraView == null || uvcCameraView!.cameraController.getCameraState != UVCCameraState.opened){
        return true;
      } else { return false; }
    }
  }

  void logout() {
    String loginFileName = EnvManager.getLoginFileName();
    FileManager fileManager = FileManager(loginFileName);
    fileManager.deleteFile();
  }

  void collectAndSendTelemetries() async {
    serialInterface ??= SerialInterface();
    if (serialInterface!.isInitialized == true) {
      return;
    }
    try {
      serialInterface = SerialInterface();
      await serialInterface!.initialize();
      Transaction<String> transaction = Transaction.stringTerminated(
          serialInterface!.port!.inputStream!, Uint8List.fromList([10, 10]));
      transaction.stream.listen((String data) async {
        for (String line in data.split("\n")) {
          if (line.isNotEmpty) {
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
      if(holeRecentlyFound){
        return;
      }
      // The photo collection
      XFile? file = await takePicture();
      if (file == null) {
        return;
      }
      int holeSeverity = await holeDetector!.isHole(file);
      final File fileToDelete = File(file.path);
      fileToDelete.delete();
      if (holeSeverity > 0) {
        holeRecentlyFound = true;
        seenHoles++;
        Timer(const Duration(seconds: 10), () {
          holeRecentlyFound = false;
          _timer?.cancel();
        });
        RoadPotholeTelemetryQuery telemetryQuery = RoadPotholeTelemetryQuery();
        GPSData? gpsData;
        try {
          gpsData = serialInterface!.vibrationManager.getGpsData();
        } catch (e) {
          return;
        }
        telemetryQuery.sendQuery(
            HoleSendableData(holeSeverity, deviceData, gpsData.latitude,
                gpsData.longitude, await nominatimManager.sendQuery(gpsData)),
            token: await TokenManager.getToken());
      }
    });
  }

  Future<List<Widget>> dashboardCenterChildren() async {
    List<Widget> children = [];
    SettingsLogic settingsLogic = SettingsLogic();
    if (holeDetector == null) {
      holeDetector = HoleDetector();
      await holeDetector!.initialize();
    }

    children.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shield,
              size: 30,
              color: Colors.blueAccent), // A placeholder for a custom logo
          const SizedBox(width: 10),
          Text(
            'PaveGuard Dashboard',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: <Color>[Colors.blue, Colors.purple],
                ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
            ),
          ),
        ],
      ),
    );

    if (await settingsLogic.isCameraExt()) {
      // The camera is external
      cameraController = PhotoCollector();
      try {
        if(uvcCameraView!.cameraController.getCameraState == UVCCameraState.closed){
          throw Exception("Error");
        }
        if(uvcCameraView != null){
          String? pathTest = await uvcCameraView!.cameraController.takePicture();
          if(pathTest == null || pathTest == ' '){
            throw Exception("Camera not openable!");
          }
        } else {
          uvcCameraView =
            await PhotoCollector.openExternalCamera();
        }
        children.add(
          Column(
            children: [
              const Text(
                'Live Camera Feed',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // Shadow position
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: uvcCameraView!,
                ),
              ),
            ],
          ),
        );
        children.add(
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 10),
              Text(
                'External Camera loaded and working.',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
        cameraWorking = true;
      } catch (e) {
        cameraWorking = false;
        uvcCameraView = null;
        children.add(
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 28), // Icon for error
              SizedBox(width: 10),
              Text(
                'External Camera not loading!',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
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
        children.add(
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 10),
              Text(
                'Camera loaded and working.',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
        cameraWorking = true;
        children.add(
          Column(
            children: [
                const Text(
                'Live Camera View',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Holes seen: $seenHoles',
                  style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black38,
                  ),
                ),
                const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: 1.1 / cameraController.value.aspectRatio,
                    child: CameraPreview(cameraController),
                  ),
                ),
              ),
            ],
          ),
        );
      } catch (e) {
        children.add(
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 28), // Icon for error
              SizedBox(width: 10),
              Text(
                'Built-in camera not loading!',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
    }

    if (await settingsLogic.isGpsExt()) {
      // External GPS
      String result = await GpsManager.isExternalGPSOn(serialInterface);
      if (result == "") {
        children.add(const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 10),
              Text(
                'Dynamic Guard correctly mounted.',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),);
      } else {
        children.add(Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 28), // Icon for error
              const SizedBox(width: 10),
              Text(
                result,
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),);
      }
    } else {
      // Internal GPS
      if (await GpsManager.isBuiltInGPSOn()) {
        children.add(const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 10),
              Text(
                'Built-in GPS active.',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),);
      } else {
        children.add(const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 28), // Icon for error
              SizedBox(width: 10),
              Text(
                "Built-in GPS not active",
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),);
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
