import 'package:dynamic_bridge/global/env_manager.dart';
import 'package:dynamic_bridge/views/dashboard.dart';
import 'package:flutter/material.dart';
import '../../views/login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../file_manager.dart';

class MainAppLogic {

  /// Checks if the user is already logged in
  /// 
  Future<bool> isCheckedIn() async {

    //TODO: JVD

    String loginFileName = EnvManager.getLoginFileName();
    return FileManager(loginFileName).doFileExists();

    }

  /// Loads the environment
  /// 
  Future loadEnv() async{

    await dotenv.load(fileName: ".env");

  }

  /// Gives the first page to load when the app starts up
  ///
  Widget loadNextPage(){

    Widget toLoad = const DashboardPage(title: "prova");

    isCheckedIn().then( (onValue) =>
      
      {
        if(!onValue){
          toLoad = const LoginScreen()
        }
      }

    );

    return toLoad;

  }

}