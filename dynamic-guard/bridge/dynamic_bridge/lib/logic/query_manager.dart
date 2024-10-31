import 'dart:developer';

import 'package:flutter_login/flutter_login.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../global/env_manager.dart';

abstract class QueryAbstractManager {

  Future<QueryResult> sendQuery(data) async{

    final String query = getQuery(data);
    final HttpLink httpLink = HttpLink('http://${EnvManager.getUrl()}:3000/graphql');
      
    final GraphQLClient client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(), // Set up a cache if needed
    );

    final QueryOptions options = QueryOptions(
      document: gql(query),
    );

    QueryResult result = await client.query(options);

    if(EnvManager.isDebugAndroidMode()){
      log("response: $result");
    }

    return result;

  }

  String getQuery(data);
  bool checkData(data);

}

class SignUpManager extends QueryAbstractManager {


  @override
  bool checkData(data){

    if(data is! SignupData){
      return false;
    }

    return true;

  }

  @override
  String getQuery(data){

    if(!checkData(data)){
      log("ERROR: Wrong data for sign-up!");
      return "";
    }

    return '''mutation {
        signup(
        email: "${data.name}",
        password: "${data.password}",
        firstName: "${data.additionalSignupData!["firstName"]}",
        lastName: "${data.additionalSignupData!["lastName"]}",
        userCode: "${data.additionalSignupData!["userCode"]}",
        ) { token }
        }''';
  }

  String getToken(QueryResult queryResult){

    return queryResult.data!["signup"]["token"];

  }

}

class LoginManager extends QueryAbstractManager{

  @override
  bool checkData(data) {
    
    if(data is! SignupData){
      return false;
    }

    return true;

  }

  @override
  String getQuery(data) {
    
    return '''mutation {
        login(
        email: "${data.name}",
        password: "${data.password}",
      ) {token} }''';

  }

  String getToken(QueryResult queryResult){

    return queryResult.data!["login"]["token"];

  }

}