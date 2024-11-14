import 'package:flutter_dotenv/flutter_dotenv.dart';

const String modeVarName = "MODE";
const String debugAndroidName = "debug-android";
const String debugPcName = "debug-pc";
const String deployName = "deploy";

const String loginFileVarName = "LOGIN_FILE";
const String settingsFileVarName = "SETTINGS_FILE";
const String devicesFileVarName = "DEVICES_FILE";

const String urlVarName = "URL";

const String photoCollectionIntervalVarName = "PHOTO_INTERVAL";

class EnvManager {

  static String getStringVar(String name){

    String? envVar = dotenv.env[name];

    if(envVar == null){
      throw FormatException("$name variable is not defined in environment file.");
    }

    return envVar.toString();
  }

  static bool isDebugMode(){
    return isDebugAndroidMode() || isDebugPcMode();
  }

  static bool isDebugAndroidMode(){
    return getStringVar(modeVarName) == debugAndroidName;
  }

  static bool isDebugPcMode(){
    return getStringVar(modeVarName) == debugPcName;
  }

  static bool isDeployMode(){
    return getStringVar(modeVarName) == deployName;
  }

  static String getLoginFileName(){
    return getStringVar(loginFileVarName);
  }

  static String getDevicesFileName(){
    return getStringVar(devicesFileVarName);
  }

  static String getUrl(){
    return getStringVar(urlVarName);
  }

  static String getSettingsFileName(){
    return getStringVar(settingsFileVarName);
  }

  static int getPhotoCollectionInterval(){
    return int.parse(getStringVar(photoCollectionIntervalVarName));
  }

}