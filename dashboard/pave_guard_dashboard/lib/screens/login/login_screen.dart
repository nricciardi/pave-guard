import 'package:admin/controllers/query_manager.dart';
import 'package:admin/screens/main/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

String? token;

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Duration get loginTime => const Duration(milliseconds: 500);

  Future<String?> _authUser(LoginData data) async {
    LoginManager loginManager = LoginManager();
    QueryResult queryResult = await loginManager.sendQuery(data);
    if(loginManager.checkResults(queryResult) == false){
      return "User not exists";
    } else {
      token = loginManager.getToken(queryResult);
      return null;
    }
  }

  Future<String?> _signupUser(SignupData data) {
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'PAVEGUARD',
      theme: 
      LoginTheme(
        primaryColor: Colors.black,
        accentColor: Colors.purple,
        errorColor: Colors.deepOrange,
      ),
      onLogin: _authUser,
      onSignup: _signupUser,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => MainScreen(token: token!),
        ));
      },
      onRecoverPassword: (_) async => null,
      hideForgotPasswordButton: true,
    );
  }
}