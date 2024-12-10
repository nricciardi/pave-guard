import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:responsive_admin_dashboard/screens/dash_board_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Duration get loginTime => const Duration(milliseconds: 2250);

  Future<String?> _authUser(LoginData data) {
    Map<String, String> users = {"marco": "pini"};
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(data.name)) {
        return 'User not exists';
      }
      if (users[data.name] != data.password) {
        return 'Password does not match';
      }
      return null;
    });
  }

  Future<String> _recoverPassword(String name) {
    Map<String, String> users = {"marco": "pini"};
    debugPrint('Name: $name');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(name)) {
        return 'User not exists';
      }
      return "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'PaveGuard',
      onLogin: _authUser,
      onSignup: (_) => Future.delayed(loginTime),
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const DashBoardScreen(),
        ));
      },
      onRecoverPassword: _recoverPassword,
      hideForgotPasswordButton: true,
      hideSignUpButton: true,
    );
  }
}