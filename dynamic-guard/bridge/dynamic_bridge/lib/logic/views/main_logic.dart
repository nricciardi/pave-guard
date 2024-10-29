import 'package:flutter/material.dart';
import '../../views/login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MainAppLogic {

  /// Loads the environment
  /// 
  Future loadEnv() async{

    await dotenv.load(fileName: ".env");

  }

  /// Gives the first page to load when the app starts up
  ///
  Widget loadNextPage(){

    // TODO: Saving locally user and pass to 'remember' the login?

    return const LoginScreen();

  }

}