import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import '../logic/login_logic.dart';


// The Login View
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Duration get loginTime => const Duration(milliseconds: 2250);
  static LoginLogic selfLogic = LoginLogic();

  /// For autorizing the user
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

  /// To sign up
  Future<String?> _signupUser(SignupData data) {
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {

      // TODO: Database APIs

      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'PROVA',
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
        // TODO: Additional fields?
      ],
    );
  }

}