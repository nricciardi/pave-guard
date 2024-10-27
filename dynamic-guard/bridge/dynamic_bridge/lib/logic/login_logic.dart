import 'package:flutter/material.dart';
import '../views/dashboard.dart';

class LoginLogic {

  /// Returns the page to load as soon as the login succeeds
  /// 
  Widget loadNextPage() {

    // TODO: The whole logic, if needed

    return const DashboardPage(title: "prova");

  }

  /// Check if the first or last name is valid
  /// 
  String? nameValidator(String? value){

          if(value == null || value.isEmpty){
            return "Insert a valid name!";
          } return null;

  }

}