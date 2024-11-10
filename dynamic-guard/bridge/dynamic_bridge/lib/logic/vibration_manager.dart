class GPSData {

  double latitude, longitude;
  GPSData(this.latitude, this.longitude);

  double getLatitude(){
    return latitude;
  }

  double getLongitude(){
    return longitude;
  }

}

class AccelerometerData {

  double x, y, z;
  AccelerometerData(this.x, this.y, this.z);

  double getX(){
    return x;
  }

  double getY(){
    return y;
  }

  double getZ(){
    return z;
  }

}

class VibrationManager {

  static const int lastMeasurement = 10;

  // Last x measurements for comparisons reason
  List<AccelerometerData> lastAccelerometerData = List.empty(growable: true);
  List<GPSData> lastGPSData = List.empty(growable: true);

  // Latest measurements
  AccelerometerData? accelerometerData;
  GPSData? gpsData;

  bool isDataComplete(){
    if(accelerometerData == null || gpsData == null){
      return false;
    } return true;
  }

  void addAccelerometerData(AccelerometerData data){
    
    if(accelerometerData == null){
      accelerometerData = data;
      return;
    }

    if(lastAccelerometerData.length >= lastMeasurement){
      lastAccelerometerData.removeAt(0);
    }

    lastAccelerometerData.add(accelerometerData!);
    accelerometerData = data;    

  }

  void addGpsData(GPSData data){

    if(gpsData == null){
      gpsData = data;
      return;
    }

    if(lastGPSData.length >= lastMeasurement){
      lastGPSData.removeAt(0);
    }

    lastGPSData.add(gpsData!);
    gpsData = data;   

  }

  GPSData getGpsData(){
    if(gpsData == null){
      return GPSData(0, 0);
    } return gpsData as GPSData;
  }

  AccelerometerData getAccelerometerData(){
    if(accelerometerData == null){
      return AccelerometerData(0, 0, 0);
    } return accelerometerData as AccelerometerData;
  }

  void update(){

    if(isDataComplete()){

      // TODO: check if the data is to send
      if(true){
        // TODO: send data
      }

    }

  }
  
}
