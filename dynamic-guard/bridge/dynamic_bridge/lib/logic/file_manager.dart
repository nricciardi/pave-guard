import 'dart:convert';
import 'dart:developer';

import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../global/env_manager.dart';

class FileManager {

  // The name of the file from which to read
  final String fileName;
  bool permanent = false;

  FileManager(this.fileName, {this.permanent = true});

  // Gets the permanent documents directory
  Future<String> get _filePath async {

    if (permanent){
      Directory directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } else {
      Directory directory = await getApplicationCacheDirectory();
      return directory.path;
    }
    
  }

  Future<File> asFile() async {
    return await _myFile;
  }

  // Loads the file
  Future<File> get _myFile async {
    final String path = await _filePath;
    if(EnvManager.isDebugMode()){
      log("Getting file $path/$fileName");
    }

    return File('$path/$fileName');
  }

  // Check if file exists
  Future<bool> doFileExists() async{

    final File file = await _myFile;
    return await file.exists();

  }

  // Reads from the file
  Future<String> readFileContents() async {
  
    final File file = await _myFile;

    // Reads the file
    final String contents = await file.readAsString();

    return contents;
  }

  // Writes onto the file
  void writeFileContents(String contents) async {
    final File file = await _myFile;

    // Write the file
    file.writeAsString(contents);
  }

  Future<void> deleteFile() async {
    
    final File file = await _myFile;
    await file.delete(recursive: false);

  }

  Future<dynamic> parseJsonContent() async {

    String fileContents = await readFileContents();
    return jsonDecode(fileContents);

  }

}