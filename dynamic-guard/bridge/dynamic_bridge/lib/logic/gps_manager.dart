import 'package:geolocator/geolocator.dart';

class GpsManager {

  static Future<bool> isBuiltInGPSOn() async{

    return await Geolocator.isLocationServiceEnabled();

  }

}