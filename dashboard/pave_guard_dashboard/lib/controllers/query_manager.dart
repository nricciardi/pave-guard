import 'package:admin/screens/dashboard/dashboard_screen.dart';
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

  String getFirstName() {
    return firstName;
  }

  String getLastName() {
    return lastName;
  }

  String getCreatedAt() {
    return createdAt;
  }

  String getEmail() {
    return email;
  }

  String getId() {
    return id;
  }
}

abstract class QueryAbstractManager {
  Future<QueryResult> sendQuery(data, {String token = ""}) async {
    final String query = getQuery(data, token: token);
    final String link = 'http://${EnvManager.getUrl()}:3000/graphql';
    final HttpLink httpLink;

    if (token == "") {
      httpLink = HttpLink(link);
    } else {
      httpLink = HttpLink(link,
          defaultHeaders: Map.of({"Authorization": "Bearer $token"}));
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

  String getQuery(data, {String token = ""});
  bool checkData(data, {String token = ""});
  bool checkResults(QueryResult queryResult);
}

class LoginManager extends QueryAbstractManager {
  @override
  bool checkData(data, {token = ""}) {
    if (data is! LoginData) {
      return false;
    }

    return true;
  }

  @override
  String getQuery(data, {token = ""}) {
    return '''query {
        login(
        email: "${data.name}",
        password: "${data.password}",
      ) {token} }''';
  }

  String getToken(QueryResult queryResult) {
    return queryResult.data!["login"]["token"];
  }

  @override
  bool checkResults(QueryResult queryResult) {
    try {
      queryResult.data!["login"]["token"];
      return true;
    } catch (e) {
      return false;
    }
  }
}

class MeQueryManager extends QueryAbstractManager {
  @override
  bool checkData(data, {token = ""}) {
    return token != "";
  }

  @override
  String getQuery(data, {token = ""}) {
    if (!checkData(data, token: token)) {
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
  bool checkResults(QueryResult queryResult) {
    try {
      if (!queryResult.data!.containsKey("me")) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  MeData getMeData(QueryResult queryResult) {
    Map<String, dynamic> data = queryResult.data!["me"];
    return MeData(
        data["firstName"],
        data["lastName"],
        data["createdAt"].toString().substring(0, 10),
        data["email"],
        data["id"]);
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

  bool contains(String text) {
    return road!.toLowerCase().contains(text.toLowerCase()) ||
        city!.toLowerCase().contains(text.toLowerCase()) ||
        state!.toLowerCase().contains(text.toLowerCase());
  }
}

class QueryLocationManager extends QueryAbstractManager {
  @override
  bool checkData(data, {String token = ""}) {
    return token != "";
  }

  @override
  bool checkResults(QueryResult<Object?> queryResult) {
    try {
      if (queryResult.data!["location"] == null) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
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

  List<LocationData> getLocationData(QueryResult queryResult) {
    List<LocationData> locations = [];
    List<dynamic> data = queryResult.data!["locations"];
    for (var location in data) {
      locations.add(LocationData(
          road: location["road"],
          city: location["city"],
          county: location["county"],
          state: location["state"]));
    }
    return locations;
  }
}

abstract class SeverityQueryManager extends QueryAbstractManager {
  @override
  bool checkData(data, {String token = ""}) {
    if (data is! LocationData) return false;
    return token != "";
  }

  Future<Map<LocationData, SeverityData>> getSeveritiesForLocations(
      List<LocationData> locations, String token) async {
    Map<LocationData, SeverityData> result = {};
    for (LocationData location in locations) {
      QueryResult queryResult = await sendQuery(location, token: token);
      result[location] = getSeverityData(queryResult);
    }
    return result;
  }

  SeverityData getSeverityData(QueryResult queryResult);
  SeverityData severitiesAveragedByDay(
      List<int> severity, List<DateTime> timestamp) {
    Map<DateTime, List<int>> dailySeverities = {};
    for (int i = 0; i < timestamp.length; i++) {
      DateTime date =
          DateTime(timestamp[i].year, timestamp[i].month, timestamp[i].day);
      if (!dailySeverities.containsKey(date)) {
        dailySeverities[date] = [];
      }
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
    try {
      if (queryResult.data!["roadCrackTelemetries"] == null) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
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
  SeverityData getSeverityData(QueryResult queryResult) {
    List<int> severity = [];
    List<DateTime> timestamp = [];
    if (!checkResults(queryResult)) {
      return SeverityData(severity, timestamp);
    }
    List<dynamic> data = queryResult.data!["roadCrackTelemetries"];
    for (var telemetries in data) {
      severity.add(telemetries["severity"]);
      timestamp.add(DateTime.parse(telemetries["timestamp"]));
    }
    return severitiesAveragedByDay(severity, timestamp);
  }
}

class SeverityPotholeQueryManager extends SeverityQueryManager {
  @override
  bool checkResults(QueryResult<Object?> queryResult) {
    try {
      if (queryResult.data!["roadPotholeTelemetries"] == null) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
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
  SeverityData getSeverityData(QueryResult queryResult) {
    List<int> severity = [];
    List<DateTime> timestamp = [];
    List<dynamic> data = queryResult.data!["roadPotholeTelemetries"];
    for (var telemetries in data) {
      severity.add(telemetries["severity"]);
      timestamp.add(DateTime.parse(telemetries["timestamp"]));
    }
    return severitiesAveragedByDay(severity, timestamp);
  }
}

class PlanningData {
  List<LocationData> locations;
  List<DateTime> dates;
  List<String> ids;
  List<String> descriptions;
  List<bool> dones;
  PlanningData(
      this.locations, this.dates, this.ids, this.descriptions, this.dones);

  PlanningData getPlanning(DateTime day) {
    List<LocationData> locations = [];
    List<DateTime> dates = [];
    List<String> ids = [];
    List<String> descriptions = [];
    List<bool> dones = [];
    for (int i = 0; i < this.dates.length; i++) {
      if (this.dates[i].year == day.year &&
          this.dates[i].month == day.month &&
          this.dates[i].day == day.day) {
        locations.add(this.locations[i]);
        dates.add(this.dates[i]);
        ids.add(this.ids[i]);
        descriptions.add(this.descriptions[i]);
        dones.add(this.dones[i]);
      }
    }
    return PlanningData(locations, dates, ids, descriptions, dones);
  }

  bool isEmpty() {
    return locations.isEmpty;
  }

  List<LocationData> getLocations(DateTime day) {
    List<LocationData> result = [];
    for (int i = 0; i < dates.length; i++) {
      if (dates[i].year == day.year &&
          dates[i].month == day.month &&
          dates[i].day == day.day) {
        result.add(locations[i]);
      }
    }
    return result;
  }
}

class PlanningQueryManager extends QueryAbstractManager {
  @override
  bool checkData(data, {String token = ""}) {
    if (data! is LocationData) return false;
    return token != "";
  }

  @override
  bool checkResults(QueryResult<Object?> queryResult) {
    try {
      if (queryResult.data!["planningCalendar"] == null) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  String getQuery(data, {String token = ""}) {
    return """query {
                planningCalendar{
                  road,
                  city,
                  county,
                  state,
                  date,
                  id,
                  done,
                  description
                }
              }""";
  }

  PlanningData getPlanningData(QueryResult queryResult) {
    List<LocationData> locations = [];
    List<DateTime> dates = [];
    List<String> descriptions = [];
    List<String> ids = [];
    List<bool> dones = [];
    List<dynamic> data = queryResult.data!["planningCalendar"];
    for (var planning in data) {
      locations.add(LocationData(
          road: planning["road"],
          city: planning["city"],
          county: planning["county"],
          state: planning["state"]));
      dates.add(DateTime.parse(planning["date"]));
      if (planning["description"] == null)
        descriptions.add("");
      else
        descriptions.add(planning["description"]);
      ids.add(planning["id"]);
      dones.add(planning["done"]);
    }
    return PlanningData(locations, dates, ids, descriptions, dones);
  }
}

class AddPlanningData {
  LocationData location;
  DateTime date;
  String description;
  AddPlanningData(this.location, this.date, this.description);
}

class AddPlanningQueryManager extends QueryAbstractManager {
  @override
  bool checkData(data, {String token = ""}) {
    if (data is! AddPlanningData) return false;
    return token != "";
  }

  @override
  bool checkResults(QueryResult<Object?> queryResult) {
    try {
      if (queryResult.data!["addPlanning"] == null) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  String getQuery(data, {String token = ""}) {
    LocationData location = data.location;
    DateTime date = data.date;
    String description = data.description;
    return """mutation {
                createPlanning(
                  road: "${location.road}",
                  city: "${location.city}",
                  county: "${location.county}",
                  state: "${location.state}",
                  date: "$date",
                  description: "$description"
                ){ id }
              }""";
  }
}

class EditPlanningData {
  String id;
  String description;
  bool done;
  EditPlanningData(this.id, this.description, this.done);
}

class EditPlanningQueryManager extends QueryAbstractManager {
  @override
  bool checkData(data, {String token = ""}) {
    if (data is! EditPlanningData) return false;
    return token != "";
  }

  @override
  bool checkResults(QueryResult<Object?> queryResult) {
    try {
      if (queryResult.data!["editPlanning"] == null) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  String getQuery(data, {String token = ""}) {
    EditPlanningData editData = data;
    return """mutation {
                updatePlanning(
                  planningId: "${editData.id}",
                  description: "${editData.description}",
                  done: ${editData.done}
                ){ id }
              }""";
  }
}

class PredictionQueryManager extends QueryAbstractManager {
  @override
  bool checkData(data, {String token = ""}) {
    return token != "";
  }

  @override
  bool checkResults(QueryResult<Object?> queryResult) {
    try {
      if (queryResult.data!["predictions"] == null) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  String getQuery(data, {String token = ""}) {
    return """query {
              predictions {
                road,
                city,
                county,
                state,
                crackSeverityPredictions,
                potholeSeverityPredictions,
              }
            }""";
  }

  Predictions getPredictions(QueryResult qr){
    List<dynamic> data = qr.data!["predictions"];
    Map<LocationData, List<Prediction>> preds = {};
    for (var prediction in data) {
      LocationData location = LocationData(
          road: prediction["road"],
          city: prediction["city"],
          county: prediction["county"],
          state: prediction["state"]
        );
      List<Prediction> local_preds = [];
      int i = 0;
      for(double _ in prediction["crackSeverityPredictions"]){
        local_preds.add(Prediction(
          i + 1,
          prediction["crackSeverityPredictions"][i].toInt(),
          prediction["potholeSeverityPredictions"][i].toInt()
        ));
        i += 1;
      }
      preds[location] = local_preds;
    }
    return Predictions(preds);
  }

}

class Temperature {
  DateTime date;
  double temperature;
  Temperature(this.date, this.temperature);
}

class TemperatureTelemetryQueryManager extends QueryAbstractManager {

  @override
  bool checkData(data, {String token = ""}) {
    if(data is! LocationData) return false;
    return token != "";
  }

  @override
  bool checkResults(QueryResult<Object?> queryResult) {
    try {
      if (queryResult.data!["temperatureTelemetries"] == null) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  String getQuery(data, {String token = ""}) {
    return """query {
                temperatureTelemetries(
                  road: "${data.road}",
                  city: "${data.city}",
                  county: "${data.county}",
                  state: "${data.state}"
                ){
                  timestamp,
                  temperature
                }
    }
          """;
  }

  List<Temperature> getTemperatures(QueryResult qr){
    List<dynamic> data = qr.data!["temperatureTelemetries"];
    List<Temperature> temps = [];
    for (var telemetry in data) {
      temps.add(Temperature(DateTime.parse(telemetry["timestamp"]), telemetry["temperature"].toDouble()));
    }
    Map<DateTime, List<double>> dailyTemperatures = {};
    for (var temp in temps) {
      DateTime date = DateTime(temp.date.year, temp.date.month, temp.date.day);
      if (!dailyTemperatures.containsKey(date)) {
      dailyTemperatures[date] = [];
      }
      dailyTemperatures[date]!.add(temp.temperature);
    }

    List<Temperature> averagedTemps = [];
    dailyTemperatures.forEach((date, temperatures) {
      double sum = temperatures.reduce((a, b) => a + b);
      averagedTemps.add(Temperature(date, sum / temperatures.length));
    });

    temps = averagedTemps;
    return temps;
  }

}

class Humidity{
  DateTime date;
  double humidity;
  Humidity(this.date, this.humidity);
}

class HumidityTelemetryQueryManager extends QueryAbstractManager{
  
  @override
  bool checkData(data, {String token = ""}) {
    if(data is! LocationData) return false;
    return token != "";
  }

  @override
  bool checkResults(QueryResult<Object?> queryResult) {
    try {
      if (queryResult.data!["temperatureTelemetries"] == null) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  String getQuery(data, {String token = ""}) {
    return """query {
                humidityTelemetries(
                  road: "${data.road}",
                  city: "${data.city}",
                  county: "${data.county}",
                  state: "${data.state}"
                ){
                  timestamp,
                  humidity
                }
    }
          """;
  }

  List<Humidity> getHumidity(QueryResult qr){
    List<dynamic> data = qr.data!["humidityTelemetries"];
    List<Humidity> hums = [];
    for (var telemetry in data) {
      hums.add(Humidity(DateTime.parse(telemetry["timestamp"]), telemetry["humidity"].toDouble()));
    }
    Map<DateTime, List<double>> dailyHumidity = {};
    for (var hum in hums) {
      DateTime date = DateTime(hum.date.year, hum.date.month, hum.date.day);
      if (!dailyHumidity.containsKey(date)) {
        dailyHumidity[date] = [];
      }
      dailyHumidity[date]!.add(hum.humidity);
    }

    List<Humidity> averagedHums = [];
    dailyHumidity.forEach((date, humidities) {
      double sum = humidities.reduce((a, b) => a + b);
      averagedHums.add(Humidity(date, sum / humidities.length));
    });

    hums = averagedHums;
    return hums;
  }

}

class Transit{
  DateTime date;
  double transitTime;
  double length;
  double speed;
  int num;
  Transit(this.date, this.transitTime, this.length, this.speed, {this.num = 1});
}

class TransitTelemetryQueryManager extends QueryAbstractManager{
  
  @override
  bool checkData(data, {String token = ""}) {
    if(data is! LocationData) return false;
    return token != "";
  }

  @override
  bool checkResults(QueryResult<Object?> queryResult) {
    try {
      if (queryResult.data!["transitTelemetries"] == null) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  String getQuery(data, {String token = ""}) {
    return """query {
  	            transitTelemetries(
                county: "${data.county}",
                state: "${data.state}",
                city: "${data.city}",
                road: "${data.road}"
              ){
            timestamp,length,velocity,transitTime
              }
            }
          """;
  }

  List<Transit> getTransits(QueryResult qr){
    List<dynamic> data = qr.data!["transitTelemetries"];
    List<Transit> transits = [];
    for (var telemetry in data) {
      transits.add(Transit(DateTime.parse(telemetry["timestamp"]), telemetry["transitTime"].toDouble(), telemetry["length"].toDouble(), telemetry["velocity"].toDouble()));
    }

    Map<DateTime, List<Transit>> dailyTransits = {};
    for (var transit in transits) {
      DateTime date = DateTime(transit.date.year, transit.date.month, transit.date.day);
      if (!dailyTransits.containsKey(date)) {
      dailyTransits[date] = [];
      }
      dailyTransits[date]!.add(transit);
    }

    List<Transit> averagedTransits = [];
    dailyTransits.forEach((date, transits) {
      double totalTransitTime = transits.map((t) => t.transitTime).reduce((a, b) => a + b);
      double totalLength = transits.map((t) => t.length).reduce((a, b) => a + b);
      double totalSpeed = transits.map((t) => t.speed).reduce((a, b) => a + b);
      int totalNum = transits.map((t) => t.num).reduce((a, b) => a + b);
      averagedTransits.add(Transit(date, totalTransitTime / transits.length, totalLength / transits.length, totalSpeed / transits.length, num: totalNum));
    });

    return averagedTransits;
  }

}

class Telemetries {
  List<Temperature> temperatures;
  List<Humidity> humidities;
  List<Transit> transits;
  Telemetries(this.temperatures, this.humidities, this.transits);

  Telemetries getRecentData(int n_days){
    List<Temperature> temps = [];
    List<Humidity> hums = [];
    List<Transit> trans = [];
    DateTime now = DateTime.now();
    for(Temperature temp in temperatures){
      if(now.difference(temp.date).inDays <= n_days){
        temps.add(temp);
      }
    }
    for(Humidity hum in humidities){
      if(now.difference(hum.date).inDays <= n_days){
        hums.add(hum);
      }
    }
    for(Transit tran in transits){
      if(now.difference(tran.date).inDays <= n_days){
        trans.add(tran);
      }
    }
    return Telemetries(temps, hums, trans);
  }
}

class TelemetryQueryManager {

  static Future<Telemetries> getTelemetries(LocationData location, String token) async {
    TemperatureTelemetryQueryManager tempManager = TemperatureTelemetryQueryManager();
    HumidityTelemetryQueryManager humManager = HumidityTelemetryQueryManager();
    TransitTelemetryQueryManager tranManager = TransitTelemetryQueryManager();
    List<Temperature> temps = [];
    List<Humidity> hums = [];
    List<Transit> trans = [];
    QueryResult tempQr = await tempManager.sendQuery(location, token: token);
    temps = tempManager.getTemperatures(tempQr);
    QueryResult humQr = await humManager.sendQuery(location, token: token);
    hums = humManager.getHumidity(humQr);
    QueryResult tranQr = await tranManager.sendQuery(location, token: token);
    trans = tranManager.getTransits(tranQr);
    return Telemetries(temps, hums, trans);
  }

  static Future<Map<LocationData, Telemetries>> getTelemetriesForLocations(List<LocationData> locations, String token) async {
    Map<LocationData, Telemetries> result = {};
    for(LocationData location in locations){
      result[location] = await getTelemetries(location, token);
    }
    return result;
  }

}