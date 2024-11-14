import 'package:dynamic_bridge/logic/query_manager.dart';
import 'package:dynamic_bridge/logic/token_manager.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ProfileLogic {

  Future<Map<String, dynamic>> getProfileData() async{

    MeQueryManager meQueryManager = MeQueryManager();
    String selfToken = await TokenManager.getToken();
    if(selfToken == ""){
      return {
        "firstName": "ERROR",
        "lastName": "ERROR",
        "createdAt": "ERROR",
        "email": "ERROR"
      };
    }
    QueryResult queryResult = await meQueryManager.sendQuery("", token: selfToken);
    return queryResult.data!["me"];

  }

}