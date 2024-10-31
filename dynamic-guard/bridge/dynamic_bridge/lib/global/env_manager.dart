import 'package:flutter_dotenv/flutter_dotenv.dart';

const String modeVarName = "MODE";
const String debugAndroidName = "debug-android";
const String debugPcName = "debug-pc";
const String deployName = "deploy";

const String loginFileVarName = "LOGIN_FILE";

const String urlVarName = "URL";

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

  static String getUrl(){
    return getStringVar(urlVarName);
  }

}