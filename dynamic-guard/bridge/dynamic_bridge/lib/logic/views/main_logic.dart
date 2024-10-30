
import 'package:dynamic_bridge/global/env_manager.dart';
import 'package:dynamic_bridge/views/dashboard.dart';
import 'package:flutter/material.dart';
import '../../views/login.dart';
import '../file_manager.dart';

class MainAppLogic {

  /// Checks if the user is already logged in
  /// 
  Future<bool> isCheckedIn() async {

    if(EnvManager.isDebugPcMode()){
      return false;
    }

    //TODO: JVD

    String loginFileName = EnvManager.getLoginFileName();
    FileManager fileManager = FileManager(loginFileName);
    return fileManager.doFileExists();

    }

  /// Gives the first page to load when the app starts up
  ///
  Widget loadNextPage(){

    Widget toLoad = const DashboardPage(title: "prova");
    Future<bool> checkedIn = isCheckedIn();

    checkedIn.then( (onValue) =>
      
      {
        if(!onValue){
          toLoad = const LoginScreen()
        }
      }

    );

    return toLoad;

  }

}