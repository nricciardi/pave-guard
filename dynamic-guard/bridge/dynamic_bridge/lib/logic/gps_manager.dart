import 'package:dynamic_bridge/logic/serial_interface.dart';
import 'package:geolocator/geolocator.dart';

class GpsManager {

  static Future<bool> isBuiltInGPSOn() async{

    return await Geolocator.isLocationServiceEnabled();

  }

  static Future<String> isExternalGPSOn(SerialInterface? serialInterface) async {

    if(serialInterface == null || !serialInterface.isInitialized){ return "No USB devices connected!"; }

    return "";

  }

}