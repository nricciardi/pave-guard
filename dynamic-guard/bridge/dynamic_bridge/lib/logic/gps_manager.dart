import 'package:dynamic_bridge/logic/serial_interface.dart';
import 'package:geolocator/geolocator.dart';

class GpsManager {

  static Future<bool> isBuiltInGPSOn() async{

    return await Geolocator.isLocationServiceEnabled();

  }

  static Future<String> isExternalGPSOn() async {

    SerialInterface serialInterface = SerialInterface();

    try{ await serialInterface.initialize(); } 
    catch(e) { return "No USB devices connected!"; }

    return "";

  }

}