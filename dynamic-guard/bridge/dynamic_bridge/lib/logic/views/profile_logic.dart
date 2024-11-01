import 'package:dynamic_bridge/global/env_manager.dart';
import 'package:dynamic_bridge/logic/file_manager.dart';
import 'package:dynamic_bridge/logic/query_manager.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ProfileLogic {

  Future<Map<String, dynamic>> getProfileData() async{

    MeQueryManager meQueryManager = MeQueryManager();
    FileManager fileManager = FileManager(EnvManager.getLoginFileName());
    if(!(await fileManager.doFileExists())){
      return {
        "firstName": "ERROR",
        "lastName": "ERROR",
        "createdAt": "ERROR"
      };
    }
    String selfToken = await fileManager.readFileContents();
    QueryResult queryResult = await meQueryManager.sendQuery("", token: selfToken);
    return queryResult.data!;

  }

}