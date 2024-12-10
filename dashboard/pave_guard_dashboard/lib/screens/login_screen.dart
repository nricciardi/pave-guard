import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:responsive_admin_dashboard/database/query_manager.dart';
import 'package:responsive_admin_dashboard/screens/dash_board_screen.dart';

class LoginScreen extends StatelessWidget {

  LoginScreen({super.key});

  final LoginManager loginManager = LoginManager();
  Duration get loginTime => const Duration(milliseconds: 2250);

  Future<String?> _authUser(LoginData data) async {

    LoginManager loginManager = LoginManager();
    try{ await loginManager.sendQuery(data);  } 
    catch(e){ return "Connection error";      }

    return null;

  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'PaveGuard',
      onLogin: _authUser,
      onSignup: (_) => Future.delayed(loginTime),
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => DashBoardScreen(token: loginManager.getToken()),
        ));
      },
      onRecoverPassword: (_) => Future.delayed(loginTime),
      hideForgotPasswordButton: true,
      hideSignUpButton: true,
    );
  }
}