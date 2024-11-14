import 'dart:developer';

import 'package:dynamic_bridge/views/devices.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../global/env_manager.dart';

abstract class QueryAbstractManager {

  Future<QueryResult> sendQuery(data, {String token = ""}) async{

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
      log(checkResults(result) ? "response seems correct!" : "wrong response");
    }

    return result;

  }

  String getQuery(data, {String token=""});
  bool checkData(data, {String token=""});
  bool checkResults(QueryResult queryResult);

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
  
  @override
  bool checkResults(QueryResult queryResult) {
    try{
      queryResult.data!["signup"]["token"];
      return true;
    } catch(e) { return false; }
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
  
  @override
  bool checkResults(QueryResult queryResult) {
    try{
      queryResult.data!["login"]["token"];
      return true;
    } catch(e) { return false; }
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
        email,
        id }
    }''';

  }

  @override
  bool checkResults(QueryResult queryResult){

    try {
      Map<String, dynamic> data = queryResult.data!["me"];
      log(data.toString());
      return true;
    } catch(e) { return false; }

  }

  String getId(QueryResult queryResult){

    return queryResult.data!["me"]["id"];

  }

}

class DynamicGuardsGetQueryManager extends QueryAbstractManager{

  @override
  bool checkData(data, {String token = ""}) {
    return token != "";
  }

  @override
  bool checkResults(QueryResult<Object?> queryResult) {
    // TODO: implement it
    return true;
  }

  @override
  String getQuery(data, {String token = ""}) {
    
    return """query{
      dynamicGuards { id, serialNumber, userId }
    }
    """;

  }

  

}

class DynamicGuardCreationQueryManager extends QueryAbstractManager{

  @override
  bool checkData(data, {String token = ""}) {
    
    if(token == ""){ return false; }
    if(data is! DeviceLinkageData){ return false; }
    return true;

  }

  @override
  bool checkResults(QueryResult<Object?> queryResult) {
    // TODO: implement it
    return true;
  }

  @override
  String getQuery(data, {String token = ""}) {
    
    DeviceLinkageData deviceLinkageData = data as DeviceLinkageData;

    return """mutation {
      createDynamicGuard(
        serialNumber:"${deviceLinkageData.getSerialNumber()}",
        userId:"${deviceLinkageData.getId()}"
      ) { id }
    }
    """;

  }

}

// TODO: class RoadCrackTelemetry extends QueryAbstractManager
// TODO: class RoadPotholeTelemtry extends QueryAbstractManager