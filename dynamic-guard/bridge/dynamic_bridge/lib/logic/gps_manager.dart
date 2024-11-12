import 'package:dynamic_bridge/logic/serial_interface.dart';
import 'package:dynamic_bridge/logic/vibration_manager.dart';
import 'package:geolocator/geolocator.dart';

class GpsManager {

  static Future<bool> isBuiltInGPSOn() async{

    return await Geolocator.isLocationServiceEnabled();

  }

  static Future<String> isExternalGPSOn() async {

    SerialInterface serialInterface = SerialInterface();

    try{ await serialInterface.initialize(); } 
    catch(e) { return "No USB devices connected!"; }

    try{ serialInterface.readFromPort(); }
    catch(e) { return "Can't read from Dynamic Guard!"; }
    GPSData? gpsData;
    for(int i = 0; i < 10; i++){
      if(!await serialInterface.writeOnPort("g")) { return "Can't send data to Dynamic Guard!"; }
      gpsData = serialInterface.vibrationManager.getGpsData();
      if(gpsData.latitude == 0 && gpsData.longitude == 0) { continue; }
      else { return ""; }
    }
    return "Can't connect to Dynamic-Guard's GPS!";

  }

}