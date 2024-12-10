import 'package:dynamic_bridge/logic/vibration_manager.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class NominatimManager {

  String url = "https://nominatim.openstreetmap.org/reverse?";
  String toGet = "road";

  Future<String> sendQuery(GPSData gpsData) async {

    Uri request = getQuery(gpsData);
    http.Response response = await http.get(request);
    Map<String, String> data = parseResult(response);
    return data[toGet]!;

  }

  Map<String, String> parseResult(http.Response response) {

    xml.XmlDocument document = xml.XmlDocument.parse(response.body);
    xml.XmlElement element = document.firstElementChild!.lastElementChild!;
    /*
    Map<String, String> toRet = {};
    for(xml.XmlElement child in element.childElements){
      toRet[child.name.toString()] = child.innerText;
    }
    */
    for(xml.XmlElement child in element.childElements){
      if(child.name.toString() == "road"){
        return {child.name.toString(): child.innerText};
      }
    }
    return {};

  }

  Uri getQuery(GPSData gpsData) {
    return Uri.parse(
      "${url}lat=${gpsData.latitude.toStringAsFixed(8)}&lon=${gpsData.longitude.toStringAsFixed(8)}"
    );
  }

}