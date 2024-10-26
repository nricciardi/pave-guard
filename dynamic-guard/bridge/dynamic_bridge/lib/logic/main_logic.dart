import 'package:flutter/material.dart';
import '../views/login.dart';

class MainAppLogic {

  /// Gives the first page to load when the app starts up
  ///
  Widget loadNextPage(){

    // TODO: Saving locally user and pass to 'remember' the login?

    return const LoginScreen();

  }

}