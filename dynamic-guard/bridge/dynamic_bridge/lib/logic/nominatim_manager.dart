import 'package:dynamic_bridge/logic/vibration_manager.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class MapData {

  String road;
  String city;
  String county;
  String state;

  MapData(this.road, this.city, this.county, this.state);

}

class NominatimManager {

  String url = "https://nominatim.openstreetmap.org/reverse?";

  Future<MapData> sendQuery(GPSData gpsData) async {

    Uri request = getQuery(gpsData);
    http.Response response = await http.get(request);
    int statusCode = response.statusCode;

    // Simil-coda ;)
    while(statusCode != 200){
      await Future.delayed(const Duration(seconds: 2));
      http.Response response = await http.get(request);
      statusCode = response.statusCode;
    }

    MapData data = parseResult(response);
    return data;

  }

  MapData parseResult(http.Response response) {

    xml.XmlDocument document = xml.XmlDocument.parse(response.body);
    xml.XmlElement element = document.firstElementChild!.lastElementChild!;
    /*
    Map<String, String> toRet = {};
    for(xml.XmlElement child in element.childElements){
      toRet[child.name.toString()] = child.innerText;
    }
    */
    Map<String, String> data = {};
    for(xml.XmlElement child in element.childElements){
      if(child.name.toString() == "road" || child.name.toString() == "county" || child.name.toString() == "city" || child.name.toString() == "state"){
        data[child.name.toString()] = child.innerText;
      }
    }

    return MapData(
      data["road"] ?? "",
      data["city"] ?? "",
      data["county"] ?? "",
      data["state"] ?? ""
    );

  }

  Uri getQuery(GPSData gpsData) {
    return Uri.parse(
      "${url}lat=${gpsData.latitude.toStringAsFixed(8)}&lon=${gpsData.longitude.toStringAsFixed(8)}"
    );
  }

}