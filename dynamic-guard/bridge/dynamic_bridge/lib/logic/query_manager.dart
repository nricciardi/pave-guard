import 'dart:developer';

import 'package:flutter_login/flutter_login.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../global/env_manager.dart';

abstract class QueryAbstractManager {

  Future<QueryResult> sendQuery(data, {token = ""}) async{

    final String query = getQuery(data, token: token);
    final String link = 'http://${EnvManager.getUrl()}:3000/graphql';
    final HttpLink httpLink;
    
    if(token == ""){
      httpLink = HttpLink(link);
    } else {
      httpLink = HttpLink(link, defaultHeaders: Map.of(
        {"Authorization": "Bearer $token"}
      ));
    }

    final GraphQLClient client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(),
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

  String getQuery(data, {token=""});
  bool checkData(data, {token=""});

}

class SignUpManager extends QueryAbstractManager {


  @override
  bool checkData(data, {token=""}){

    if(data is! SignupData){
      return false;
    }

    return true;

  }

  @override
  String getQuery(data, {token=""}){

    if(!checkData(data)){
      log("ERROR: Wrong data for sign-up!");
      return "";
    }

    return '''query {
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
  bool checkData(data, {token=""}) {
    
    if(data is! SignupData){
      return false;
    }

    return true;

  }

  @override
  String getQuery(data, {token=""}) {
    
    return '''query {
        login(
        email: "${data.name}",
        password: "${data.password}",
      ) {token} }''';

  }

  String getToken(QueryResult queryResult){

    return queryResult.data!["login"]["token"];

  }

}

class MeQueryManager extends QueryAbstractManager {

  @override
  bool checkData(data, {token=""}) {
    return token != "";
  }

  @override
  String getQuery(data, {token=""}) {
    
    if(!checkData(data, token: token)){
      return "";
    }

    return '''query {
      me { createdAt, 
        firstName, 
        lastName,
        email }
    }''';

  }

  bool checkResults(QueryResult result){

    try {
      Map<String, dynamic> data = result.data!["me"];
      log(data.toString());
      return true;
    } catch(e) { return false; }

  }

}