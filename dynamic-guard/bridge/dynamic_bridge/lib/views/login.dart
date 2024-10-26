import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import '../logic/login_logic.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Duration get loginTime => const Duration(milliseconds: 2250);
  static LoginLogic selfLogic = LoginLogic();

  Future<String?> _authUser(LoginData data) {
    debugPrint('Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {

      // TODO: Database APIs
      /*
        if (!users.containsKey(data.name)) {
          return 'The username does not exist';
        }
        if (users[data.name] != encrypt(data.password)) {
          return 'The password does not match';
        }
      */

      return null;
    });
  }

  Future<String?> _signupUser(SignupData data) {
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {

      // TODO: Database APIs
      // TODO: Which fields to ask the user? Name, surname, email?

      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'PROVA',
      // logo: const AssetImage('assets/images/ecorp-lightblue.png'),
      onLogin: _authUser,
      onSignup: _signupUser,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => selfLogic.loadNextPage(),
        ));
      },
      // NOTE: That must be done because the package requires it, but the function does nothing
      onRecoverPassword: (_) => Future.delayed(loginTime).then((_) {return null;}),
      hideForgotPasswordButton: true,
    );
  }

}