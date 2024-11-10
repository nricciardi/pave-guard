import 'package:dynamic_bridge/logic/serial_interface.dart';
import 'package:dynamic_bridge/logic/vibration_manager.dart';
import 'package:geolocator/geolocator.dart';

class GpsManager {

  static Future<bool> isBuiltInGPSOn() async{

    return await Geolocator.isLocationServiceEnabled();

  }

  static Future<bool> isExternalGPSOn() async {

    SerialInterface serialInterface = SerialInterface();
    serialInterface.initialize();
    serialInterface.readFromPort();
    GPSData? gpsData;
    for(int i = 0; i < 10; i++){
      if(!await serialInterface.writeOnPort("g")) { return false; }
      gpsData = serialInterface.vibrationManager.getGpsData();
      if(gpsData.latitude == 0 && gpsData.longitude == 0) { continue; }
      else { return true; }
    }
    return false;

  }

}