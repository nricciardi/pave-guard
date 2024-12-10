import 'dart:developer';
import 'package:flutter_login/flutter_login.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:responsive_admin_dashboard/data/env_manager.dart';
import 'package:responsive_admin_dashboard/data/me_data.dart';
// import '../global/env_manager.dart';

abstract class QueryAbstractManager {

  QueryResult? queryResult;

  Future<QueryResult> sendQuery(data, {String token = ""}) async{

    final String query = getQuery(data, token: token);
    final String link = EnvManager.getUrl();
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
    queryResult = result;

    return result;

  }

  String getQuery(data, {String token=""});
  bool checkData(data, {String token=""});
  bool checkResults(QueryResult queryResult);

}

class LoginManager extends QueryAbstractManager{

  @override
  bool checkData(data, {token=""}) {
    
    if(data is! LoginData){
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

  String getToken(){

    return queryResult!.data!["login"]["token"];

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

  MeData getMeData(){

    Map<String, dynamic> data = queryResult!.data!["me"];
    return MeData(data["firstName"], data["lastName"], data["createdAt"].toString().substring(0, 10), data["email"], data["id"]);

  }

}