import 'package:dynamic_bridge/logic/token_manager.dart';
import 'package:dynamic_bridge/logic/user_data_manager.dart';

class ProfileLogic {

  Future<MeData> getProfileData() async{

    String selfToken = await TokenManager.getToken();
    if(selfToken == ""){
      return MeData("ERROR", "ERROR", "ERROR", "ERROR", "ERROR");
    }
    return UserDataManager.getSelfData();

  }

}