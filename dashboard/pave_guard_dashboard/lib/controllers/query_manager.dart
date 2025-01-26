import 'package:admin/screens/statistics/stats_screen.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../data/env_manager.dart';

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
      if (!queryResult.data!.containsKey("me")) {
        return false;
      }
      return true;
    } catch(e) { return false; }

  }

  MeData getMeData(QueryResult queryResult){

    Map<String, dynamic> data = queryResult.data!["me"];
    return MeData(data["firstName"], data["lastName"], data["createdAt"].toString().substring(0, 10), data["email"], data["id"]);

  }

}

class LocationData {
  String? road;
  String? city;
  String? county;
  String? state;
  LocationData({this.road, this.city, this.county, this.state});

  @override
  String toString() {
    return "$road\n$city ($state)";
  }

  bool contains(String text){
    return road!.toLowerCase().contains(text.toLowerCase()) || city!.toLowerCase().contains(text.toLowerCase()) || state!.toLowerCase().contains(text.toLowerCase());
  }

}

class QueryLocationManager extends QueryAbstractManager {

  @override
  bool checkData(data, {String token = ""}) {
    return token != "";
  }

  @override
  bool checkResults(QueryResult<Object?> queryResult) {
    try{
      if(queryResult.data!["location"] == null){
        return false;
      } return true;
    } catch(e) { return false; }
  }

  @override
  String getQuery(data, {String token = ""}) {
    return """query {
                locations{
                  road, 
                  city, 
                  county, 
                  state
                }
              }""";
  }

  List<LocationData> getLocationData(QueryResult queryResult){
    List<LocationData> locations = [];
    List<dynamic> data = queryResult.data!["locations"];
    for(var location in data){
      locations.add(LocationData(road: location["road"], city: location["city"], county: location["county"], state: location["state"]));
    }
    return locations;
  }
  
}

abstract class SeverityQueryManager extends QueryAbstractManager{

  @override
  bool checkData(data, {String token = ""}) {
    if(data is! LocationData) return false;
    return token != "";
  }

  Future<Map<LocationData, SeverityData>> getSeveritiesForLocations(List<LocationData> locations, String token) async {
    Map<LocationData, SeverityData> result = {};
    for(LocationData location in locations){
      QueryResult queryResult = await sendQuery(location, token: token);
      result[location] = getSeverityData(queryResult);
    }
    return result;
  }

  SeverityData getSeverityData(QueryResult queryResult);
  SeverityData severitiesAveragedByDay(List<int> severity, List<DateTime> timestamp){
    Map<DateTime, List<int>> dailySeverities = {};
    for (int i = 0; i < timestamp.length; i++) {
      DateTime date = DateTime(timestamp[i].year, timestamp[i].month, timestamp[i].day);
      if (!dailySeverities.containsKey(date)) { dailySeverities[date] = [];}
      dailySeverities[date]!.add(severity[i]);
    }

    List<int> meanSeverities = [];
    List<DateTime> uniqueDates = [];
    dailySeverities.forEach((date, severities) {
      int sum = severities.reduce((a, b) => a + b);
      meanSeverities.add((sum / severities.length).round());
      uniqueDates.add(date);
    });

    severity = meanSeverities;
    timestamp = uniqueDates;
    return SeverityData(severity, timestamp);
  }

}

class SeverityCrackQueryManager extends SeverityQueryManager {

  @override
  bool checkResults(QueryResult<Object?> queryResult) {
    try{
      if(queryResult.data!["roadCrackTelemetries"] == null){
        return false;
      } return true;
    } catch(e) { return false; }
  }

  @override
  String getQuery(data, {String token = ""}) {
    return """query {
                roadCrackTelemetries(
                  road: "${data.road}",
                  city: "${data.city}",
                  county: "${data.county}",
                  state: "${data.state}"
                ){
                  severity,
                  timestamp
                }
              }""";
  }

  @override
  SeverityData getSeverityData(QueryResult queryResult){
    List<int> severity = [];
    List<DateTime> timestamp = [];
    List<dynamic> data = queryResult.data!["roadCrackTelemetries"];
    for(var telemetries in data){
      severity.add(telemetries["severity"]);
      timestamp.add(DateTime.parse(telemetries["timestamp"]));
    }
    return severitiesAveragedByDay(severity, timestamp);    
  }

}

class SeverityPotholeQueryManager extends SeverityQueryManager {

  @override
  bool checkResults(QueryResult<Object?> queryResult) {
    try{
      if(queryResult.data!["roadPotholeTelemetries"] == null){
        return false;
      } return true;
    } catch(e) { return false; }
  }

  @override
  String getQuery(data, {String token = ""}) {
    return """query {
                roadPotholeTelemetries(
                  road: "${data.road}",
                  city: "${data.city}",
                  county: "${data.county}",
                  state: "${data.state}"
                ){
                  severity,
                  timestamp
                }
              }""";
  }

  @override
  SeverityData getSeverityData(QueryResult queryResult){
    List<int> severity = [];
    List<DateTime> timestamp = [];
    List<dynamic> data = queryResult.data!["roadPotholeTelemetries"];
    for(var telemetries in data){
      severity.add(telemetries["severity"]);
      timestamp.add(DateTime.parse(telemetries["timestamp"]));
    }
    return severitiesAveragedByDay(severity, timestamp);
  }

}