import 'dart:developer';

import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../global/env_manager.dart';

class FileManager {

  // The name of the file from which to read
  final String fileName;

  FileManager(this.fileName);

  // Gets the permanent documents directory
  Future<String> get _docsPath async {

    final Directory directory = await getApplicationCacheDirectory();
    return directory.path;

  }

  // Loads the file
  Future<File> get _docsFile async {
    final String path = await _docsPath;
    if(EnvManager.isDebugMode()){
      log("Getting file $path/$fileName");
    }

    return File('$path/$fileName');
  }

  // Check if file exists
  Future<bool> doFileExists() async{

    final File file = await _docsFile;
    return await file.exists();

  }

  // Reads from the file
  Future<String> readFileContents() async {
  
    final File file = await _docsFile;

    // Reads the file
    final String contents = await file.readAsString();

    return contents;
  }

  // Writes onto the file
  void writeFileContents(String contents) async {
    final File file = await _docsFile;

    // Write the file
    file.writeAsString(contents);
  }

  Future<void> deleteFile() async {
    
    final File file = await _docsFile;
    await file.delete(recursive: false);

  }

}