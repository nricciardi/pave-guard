import 'package:flutter_dotenv/flutter_dotenv.dart';

const String urlVarName = "URL";

class EnvManager {

  static String getStringVar(String name){

    String? envVar = dotenv.env[name];

    if(envVar == null){
      throw FormatException("$name variable is not defined in environment file.");
    }

    return envVar.toString();
  }

  static String getUrl(){
    return getStringVar(urlVarName);
  }

}