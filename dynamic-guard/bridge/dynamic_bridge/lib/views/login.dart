import 'dart:developer';

import 'package:dynamic_bridge/global/env_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import '../logic/views/login_logic.dart';


// The Login View
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Duration get loginTime => const Duration(milliseconds: 2250);
  static LoginLogic selfLogic = LoginLogic();

  /// For autorizing the user
  Future<String?> _authUser(LoginData data) async {

    bool isAuthorized = await selfLogic.authorizeUser(data);
    return Future.delayed(loginTime).then((_) {

      if(!isAuthorized){
        return "Authentication failed!";
      }

      return null;
      
    });
  }

  /// To sign up
  Future<String?> _signupUser(SignupData data) {

    if(EnvManager.isDebugMode()){
      log('Signup Name: ${data.name}, Password: ${data.password}');
    }

    return Future.delayed(loginTime).then((_) {

      selfLogic.signupUser(data);
      return null;

    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'PaveGuard',
      onLogin: _authUser,
      onSignup: _signupUser,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => selfLogic.loadNextPage(),
        ));
      },
      // NOTE: The following line must be done because the package requires it, but the function does nothing
      onRecoverPassword: (_) => Future.delayed(loginTime).then((_) {return null;}),
      hideForgotPasswordButton: true,
      additionalSignupFields: [
        UserFormField(keyName: "firstName", displayName: "First Name", fieldValidator: (value) => selfLogic.nameValidator(value),),
        UserFormField(keyName: "secondName", displayName: "Last Name", fieldValidator: (value) => selfLogic.nameValidator(value),),
        UserFormField(keyName: "userCode", displayName: "Codice Fiscale", fieldValidator: (value) => selfLogic.cfValidator(value),),
      ],
    );
  }

}