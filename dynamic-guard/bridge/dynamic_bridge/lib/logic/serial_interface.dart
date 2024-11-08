import 'dart:developer';

import 'package:dynamic_bridge/global/env_manager.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class GPSData {

  double latitude, longitude;
  GPSData(this.latitude, this.longitude);

  double getLatitude(){
    return latitude;
  }

  double getLongitude(){
    return longitude;
  }

}

class AccelerometerData {

  double x, y, z;
  AccelerometerData(this.x, this.y, this.z);

  double getX(){
    return x;
  }

  double getY(){
    return y;
  }

  double getZ(){
    return z;
  }

}

class SerialInterface {

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

    regex = RegExp(r'^g(\d+),(\d+),(\d+)$');
    final RegExpMatch match = regex.firstMatch(data)!;
    double x = double.parse(match.group(1)!);
    double y = double.parse(match.group(2)!);
    double z = double.parse(match.group(3)!);
    return AccelerometerData(x, y, z);

  }

}