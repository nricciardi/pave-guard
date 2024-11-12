import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:dynamic_bridge/global/env_manager.dart';
import 'package:dynamic_bridge/logic/vibration_manager.dart';
import 'package:usb_serial/usb_serial.dart';

class SerialInterface {

  UsbPort? port;
  VibrationManager vibrationManager = VibrationManager();

  Future<String> initialize() async {

    List<UsbDevice> devices = await UsbSerial.listDevices();

    if(EnvManager.isDebugAndroidMode()){
      log(devices.join(" "));
    }

    port = await devices[0].create();
    UsbPort fixPort = port!;
    await fixPort.open();

    await fixPort.setDTR(true);
	  await fixPort.setRTS(true);

	  fixPort.setPortParameters(115200, UsbPort.DATABITS_8,
	              UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    return "";

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

  void closePort() async { port!.close(); }

  Future<bool> writeOnPort(String toWrite) async {
    
    if(port == null){ return false; }
    try{
      port!.write(Uint8List.fromList(utf8.encode(toWrite)));
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