import 'package:dynamic_bridge/global/env_manager.dart';
import 'package:dynamic_bridge/logic/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import '../../views/dashboard.dart';
import 'package:flutter_codice_fiscale/codice_fiscale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class LoginLogic {

  /// Returns the page to load as soon as the login succeeds
  /// 
  Widget loadNextPage() {

    // TODO: The whole logic, if needed

    return const DashboardPage(title: "prova");

  }

  // Returns true if the user is authorized
  bool autorizeUser(LoginData data){

    String query = '''
      mutation {
        login(
        email: "${data.name}",
        password: "${data.password}",
      ) {
        token
        }
      }''';

    // TODO: Capire da Nicola chi cazzo crea il token

    QueryResult queryResult = executeQuery(query);

    return true;

  }

  // Returns true if the signup was successful
  bool signupUser(SignupData data){

      String query = '''
      mutation {
        signup(
        email: "${data.name}",
        password: "${data.password}",
        firstName: "${data.additionalSignupData!["firstName"]}",
        lastName: "${data.additionalSignupData!["lastName"]}",
        userCode: "${data.additionalSignupData!["userCode"]}"
      ) {
        token
        }
      }''';

    // TODO: Capire da Nicola chi cazzo crea il token

    QueryResult queryResult = executeQuery(query);

    String loginFileName = EnvManager.getLoginFileName();
    FileManager fileManager = FileManager(loginFileName);

    String contents = "${data.name}\n";
    fileManager.writeFileContents(contents);

    return true;

  }

  QueryResult executeQuery(String query){

    final HttpLink httpLink = HttpLink('http://127.0.0.1:3000/graphql');
      
    final GraphQLClient client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(), // Set up a cache if needed
    );

    final QueryOptions options = QueryOptions(
    document: gql(query),
    );

    // TODO: Cosa ritorna?
    QueryResult? result;
    client.query(options).then((resultOfQuery) {
      result = resultOfQuery;
    });

    return result!;

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
    if(value == null || !CodiceFiscale.check(value.toString())){
      return "Invalid CF!";
    } return null;
  }

}