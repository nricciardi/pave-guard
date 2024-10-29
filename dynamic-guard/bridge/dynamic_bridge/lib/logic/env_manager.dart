import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvManager {

  String getStringVar(String name){

    String? envVar = dotenv.env[name];

    if(envVar == null){
      throw FormatException("$name variable is not defined in environment file.");
    }

    return envVar.toString();

  }

  bool isDebugMode(){

    return getStringVar("MODE") == 'debug';

  }

  bool isDeployMode(){

    return getStringVar("MODE") == 'deploy';

  }

}