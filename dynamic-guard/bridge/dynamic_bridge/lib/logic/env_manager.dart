import 'package:flutter_dotenv/flutter_dotenv.dart';

String modeVarName = "MODE";
String debugName = "debug";
String deployName = "deploy";

class EnvManager {

  String getStringVar(String name){

    String? envVar = dotenv.env[name];

    if(envVar == null){
      throw FormatException("$name variable is not defined in environment file.");
    }

    return envVar.toString();

  }

  bool isDebugMode(){

    return getStringVar(modeVarName) == debugName;

  }

  bool isDeployMode(){

    return getStringVar(modeVarName) == deployName;

  }

}