import 'dart:convert';
import 'dart:developer';

import 'package:dynamic_bridge/global/env_manager.dart';
import 'package:dynamic_bridge/logic/file_manager.dart';

const Map<String, bool> defaultOptions = {
  "built-in": true,
  "external": false,
  "crock": false,
};

class SettingsLogic {

  FileManager fileManager = FileManager(EnvManager.getSettingsFileName(), permanent: true);

  Future<Map<String,bool>> getSavedOptions() async {

    if(! await fileManager.doFileExists()){
      if(EnvManager.isDebugAndroidMode()){
        log("Loading default settings...");
      }
      return defaultOptions;
    }

    String fileContents = await fileManager.readFileContents();
    Map<String, dynamic> decodedMap = jsonDecode(fileContents);
    Map<String, bool> toRet = decodedMap.map((key, value) => MapEntry("\"$key\"", value as bool));
    if(EnvManager.isDebugAndroidMode()){
      log("Loading file settings...");
      log(toRet.toString());
    }
    return toRet;

  }

  void saveOptions(Map<String, bool> data) async {

    fileManager.writeFileContents(jsonEncode(data));

  }

}