import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:dynamic_bridge/global/env_manager.dart';
import 'package:embedded_serialport/embedded_serialport.dart';
import 'package:dynamic_bridge/logic/vibration_manager.dart';

class SerialInterface {

  Serial? serial;
  VibrationManager vibrationManager = VibrationManager();

  Future<void> initialize() async {

    List<String> ports = Serial.getPorts();

    if(EnvManager.isDebugAndroidMode()){
      log(ports.join(" "));
    }
    
    serial = Serial(ports.first, Baudrate.b9600);
    Serial fixSerial = serial as Serial;
    fixSerial.timeout(2);
    fixSerial.setDataBits(DataBits.db8);
    fixSerial.setParity(Parity.parityNone);
    fixSerial.setStopBits(StopBits.sb1);

  }

  void manageSerialLine(String line){

    if (line[0] == 'A'){
      // Accelerometer
      AccelerometerData data = parseAccelerometerData(line);
      vibrationManager.addAccelerometerData(data);

    } else if (line[0] == 'g'){
      // GPS
      GPSData data = parseGpsData(line);
      vibrationManager.addGpsData(data);

    } else if (line[0] == 'G'){
      // Gyroscope
    }

  }

  void closePort() async { serial!.dispose(); }

  void readFromPort(){

    Serial fixSerial = serial as Serial;
    SerialReadEvent readData = fixSerial.read(0);
    String stringData = readData.uf8ToString();

    if (stringData.contains('\n')) {
        List<String> lines = stringData.split('\n');
        for(int i = 0; i < lines.length - 1; i++) {
          manageSerialLine(lines[i]);
        }
    }
  }

  Future<bool> writeOnPort(String toWrite) async {
    
    if(serial == null){ return false; }
    try{
      serial!.write(Uint8List.fromList(utf8.encode(toWrite)));
    } catch(e) { return false; }
    return true;

  }

  static GPSData parseGpsData(String data){

    RegExp regex = RegExp(r'^g\d+,\d+$');

    if(!regex.hasMatch(data)){
      if(EnvManager.isDebugAndroidMode()){
        log("Wrong GPS data format!");
      }
      return GPSData(0, 0);
    }

    regex = RegExp(r'^g(\d+),(\d+)$');
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

  static GyroscopeData parseGyroscopeData(String data){

    RegExp regex = RegExp(r'^G\d+,\d+,\d+$');
    if(!regex.hasMatch(data)){
      if(EnvManager.isDebugAndroidMode()){
        log("Wrong gyroscope data format!");
      }
      return GyroscopeData(0, 0, 0);
    }

    regex = RegExp(r'^G(\d+),(\d+),(\d+)$');
    final RegExpMatch match = regex.firstMatch(data)!;
    double x = double.parse(match.group(1)!);
    double y = double.parse(match.group(2)!);
    double z = double.parse(match.group(3)!);
    return GyroscopeData(x, y, z);

  }

}