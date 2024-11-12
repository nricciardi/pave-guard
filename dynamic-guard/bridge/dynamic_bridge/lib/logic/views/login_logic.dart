import 'package:dynamic_bridge/global/env_manager.dart';
import 'package:dynamic_bridge/logic/file_manager.dart';
import 'package:dynamic_bridge/logic/query_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import '../../views/dashboard.dart';
import 'package:flutter_codice_fiscale/codice_fiscale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class LoginLogic {

  /// Returns the page to load as soon as the login succeeds
  /// 
  Widget loadNextPage() {

    return const DashboardPage(title: "prova");

  }

  // Returns true if the user is authorized
  Future<bool> authorizeUser(LoginData data) async{
    
    LoginManager loginManager = LoginManager();
    QueryResult queryResult = await loginManager.sendQuery(data);

    try {

      String token = loginManager.getToken(queryResult);
      FileManager fileManager = FileManager(EnvManager.getLoginFileName());
      fileManager.writeFileContents(token);
      return true;

    } catch (e) { return false; }
    
  }

  // Returns true if the signup was successful
  Future<bool> signupUser(SignupData data) async {

    SignUpManager signupQueryManager = SignUpManager();
    QueryResult queryResult = await signupQueryManager.sendQuery(data);

    String loginFileName = EnvManager.getLoginFileName();
    FileManager fileManager = FileManager(loginFileName);

    try {

      String contents = signupQueryManager.getToken(queryResult);
      fileManager.writeFileContents(contents);
      return true;
      
    } catch (e) { return false; }

  }

  /// Check if the first or last name is valid
  /// 
  String? nameValidator(String? value){

          if(value == null || value.isEmpty){
            return "Insert a valid name!";
          } return null;

  }

  /// Check if the CF is valid
  /// 
  String? cfValidator(String? value){

    if(EnvManager.isDebugAndroidMode()){
      return null;
    }

    if(value == null || !CodiceFiscale.check(value.toString())){
      return "Invalid CF!";
    } return null;
  }

}