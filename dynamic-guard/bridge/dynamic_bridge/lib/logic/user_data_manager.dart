import 'package:dynamic_bridge/logic/query_manager.dart';
import 'package:dynamic_bridge/logic/token_manager.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class MeData {

  String firstName;
  String lastName;
  String createdAt;
  String email;
  String id;

  MeData(this.firstName, this.lastName, this.createdAt, this.email, this.id);

  String getFirstName(){ return firstName; }
  String getLastName(){ return lastName; }
  String getCreatedAt(){ return createdAt; }
  String getEmail(){ return email; }
  String getId(){ return id; }

}

class UserDataManager {

  static Future<MeData?> getSelfData() async {

    MeQueryManager meQueryManager = MeQueryManager();
    QueryResult queryResult = await meQueryManager.sendQuery("", token: await TokenManager.getToken());
    if(!meQueryManager.checkResults(queryResult)){ return null; }
    return meQueryManager.getMeData(queryResult);

  }

}