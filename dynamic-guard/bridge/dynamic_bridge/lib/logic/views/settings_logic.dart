import 'dart:convert';

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
      return defaultOptions;
    }
    String fileContents = await fileManager.readFileContents();
    return jsonDecode(fileContents) as Map<String, bool>;

  }

  void saveOptions(Map<String, bool> data) async {

    fileManager.writeFileContents(data.toString());

  }

}