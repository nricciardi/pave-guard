import 'package:dynamic_bridge/global/env_manager.dart';
import 'package:dynamic_bridge/logic/file_manager.dart';

class TokenManager {

  static Future<String> getToken() async{

    FileManager fileManager = FileManager(EnvManager.getLoginFileName());
    if(! await fileManager.doFileExists()){ return ""; }
    return fileManager.readFileContents();

  }

  static Future<void> writeToken(String token) async{

    FileManager fileManager = FileManager(EnvManager.getLoginFileName());
    fileManager.writeFileContents(token);

  }

}