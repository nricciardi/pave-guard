import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:dynamic_bridge/global/env_manager.dart';
import 'package:dynamic_bridge/logic/query_manager.dart';
import 'package:dynamic_bridge/logic/token_manager.dart';
import 'package:dynamic_bridge/logic/vibration_manager.dart';
import 'package:dynamic_bridge/logic/views/settings_logic.dart';
import 'package:dynamic_bridge/views/devices.dart';
import 'package:geolocator/geolocator.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:usb_serial/usb_serial.dart';

class SendableData {

  GPSData position;
  int severity;
  DeviceData deviceData;
  SendableData(this.position, this.severity, this.deviceData);

}

class SerialInterface {

  UsbPort? port;
  VibrationManager vibrationManager = VibrationManager();
  SettingsLogic settings = SettingsLogic();
  bool isInitialized = false;
  bool isGpsExt = false;

  // TODO: Remove it. For debug purposes.
  MeQueryManager meQueryManager = MeQueryManager();

  Future<String> initialize() async {

    isGpsExt = await settings.isGpsExt();
    List<UsbDevice> devices = await UsbSerial.listDevices();

    if(EnvManager.isDebugAndroidMode()){
      log(devices.join(" "));
    }

    port = await devices[0].create();
    
    UsbPort fixPort = port!;
    await fixPort.open();

    await fixPort.setDTR(true);
	  await fixPort.setRTS(true);

	  fixPort.setPortParameters(9600, UsbPort.DATABITS_8,
	              UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    isInitialized = true;

    return "";

  }

  void manageSerialLine(String line) async {
    
    if (line[0] == 'A'){
      // Accelerometer
      AccelerometerData data = parseAccelerometerData(line);
      vibrationManager.addAccelerometerData(data);

    } else if (line[0] == 'g'){
      if(isGpsExt){
        // GPS
        GPSData data = parseGpsData(line);
        vibrationManager.addGpsData(data);
      } else {
        Position currentPosition = await Geolocator.getCurrentPosition(timeLimit: const Duration(milliseconds: 20));
        vibrationManager.addGpsData(
          GPSData(currentPosition.latitude, currentPosition.longitude)
        );
      }

    } else if (line[0] == 'G'){
      // Gyroscope
    }

  }

  void closePort() async { port!.close(); }

  Future<bool> writeOnPort(String toWrite) async {
    
    if(port == null){ return false; }
    try{
      port!.write(Uint8List.fromList(utf8.encode(toWrite)));
    } catch(e) { return false; }
    return true;

  }

  static GPSData parseGpsData(String data){

    RegExp regex = RegExp(r'^g\d+(\.\d+)?,\d+(\.\d+)?$');

    if(!regex.hasMatch(data)){
      if(EnvManager.isDebugAndroidMode()){
        log("Wrong GPS data format!");
      }
      return GPSData(0, 0);
    }

    final RegExpMatch match = regex.firstMatch(data)!;
    double latitude = double.parse(match.group(1)!);
    double longitude = double.parse(match.group(2)!);
    return GPSData(latitude, longitude);

  }

  static AccelerometerData parseAccelerometerData(String data){

    RegExp regex = RegExp(r'^A\d+,\d+,\d+$');
    if(!regex.hasMatch(data)){
      if(EnvManager.isDebugAndroidMode()){
        log("Wrong accelerometer data format!");
      }
      return AccelerometerData(0, 0, 0);
    }

    regex = RegExp(r'^A(\d+),(\d+),(\d+)$');
    final RegExpMatch match = regex.firstMatch(data)!;
    double x = double.parse(match.group(1)!);
    double y = double.parse(match.group(2)!);
    double z = double.parse(match.group(3)!);
    return AccelerometerData(x, y, z);

  }

  Future<void> sendData(DeviceData deviceData) async {

    Map<GPSData, int> data = vibrationManager.getDataToSend();
    if(data.isEmpty){ return; }
    GPSData gpsToSend = compressGPS(data.keys.toList());
    int severityToSend = compressSeverities(data.values.toList());
    if(severityToSend <= 15){ return; }

    RoadCrackTelemetryQuery roadCrackTelemetry = RoadCrackTelemetryQuery();
    QueryResult queryResult = await roadCrackTelemetry.sendQuery(SendableData(
        gpsToSend, severityToSend, deviceData
      ), token: await TokenManager.getToken()); 
    if(EnvManager.isDebugAndroidMode()){
      log(queryResult.toString());
    }

  }

  GPSData compressGPS(List<GPSData> data){
    
    double lat = 0; double lon = 0;
    for (var key in data) {
      lat += key.latitude;
      lon += key.longitude;
    }
    return GPSData(lat / data.length, lon / data.length);
  }

  int compressSeverities(List<int> severities){

    severities.sort();
    return 
      ((severities[severities.length - 1] - severities[0]) / 2).round();

  }

}