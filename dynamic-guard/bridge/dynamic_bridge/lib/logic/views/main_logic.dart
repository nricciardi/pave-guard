
import 'dart:developer';

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

    String loginFileName = EnvManager.getLoginFileName();
    FileManager fileManager = FileManager(loginFileName);
    return await fileManager.doFileExists();

    }

  /// Gives the first page to load when the app starts up
  ///
  Future<Widget> loadNextPage() async {

    bool checkedIn = await isCheckedIn();
    Widget toLoad = const DashboardPage(title: "prova");

    if(!checkedIn){
      toLoad = const LoginScreen();
    }

    if(EnvManager.isDebugAndroidMode()){
      log("Are you checked in? $checkedIn");
      log("Now loading ${toLoad.toStringShort()}");
    }

    return toLoad;

  }

}