
import 'dart:async';
import 'dart:developer';

import 'package:dynamic_bridge/global/env_manager.dart';
import 'package:dynamic_bridge/logic/user_data_manager.dart';
import 'package:dynamic_bridge/views/devices.dart';
import 'package:flutter/material.dart';
import '../../views/login.dart';

class MainAppLogic {

  Future<MeData?> awaitCheckedIn() async {
    
    return await UserDataManager.getSelfData();

  }

  /// Checks if the user is already logged in
  /// 
  Future<MeData?> isCheckedIn() async {

    final Completer completer = Completer<void>();
    final minDelay = Future.delayed(const Duration(seconds: 1));
    final asyncTask = awaitCheckedIn();

    asyncTask.then((_) => completer.complete());
    await Future.any([minDelay, completer.future]);

    if (!completer.isCompleted) {
      return null;
    }

    return UserDataManager.getSelfData();

  }

  /// Gives the first page to load when the app starts up
  ///
  Future<Widget> loadNextPage() async {

    MeData? selfData = await isCheckedIn();
    Widget toLoad = selfData != null ? Devices(selfData: selfData) : const LoginScreen();

    if(EnvManager.isDebugAndroidMode()){
      log("Are you checked in? ${selfData != null}}");
      log("Now loading ${toLoad.toStringShort()}");
    }

    return toLoad;

  }

}