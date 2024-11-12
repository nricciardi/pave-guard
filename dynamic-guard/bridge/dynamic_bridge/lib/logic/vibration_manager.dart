class GPSData {

  double latitude, longitude;
  GPSData(this.latitude, this.longitude);

  double getLatitude(){ return latitude; }
  double getLongitude(){ return longitude;}

}

class AccelerometerData {

  double x, y, z;
  AccelerometerData(this.x, this.y, this.z);

  double getX(){ return x; }
  double getY(){ return y; }
  double getZ(){ return z; }

}

class GyroscopeData {

  double x, y, z;
  GyroscopeData(this.x, this.y, this.z);

  double getX(){ return x; }
  double getY(){ return y; }
  double getZ(){ return z; }

}

class AccGyrData {

  AccelerometerData accData;
  GyroscopeData gyrData;
  AccGyrData(this.accData, this.gyrData);

  AccelerometerData getAccelerometerData(){ return accData; }
  GyroscopeData getGyroscopeData(){ return gyrData; }

}

class VibrationManager {

  static const int lastMeasurement = 10;

  // Last x measurements for comparisons reason
  List<AccGyrData> lastAccGyrData = List.empty(growable: true);
  List<GPSData> lastGPSData = List.empty(growable: true);

  // Latest measurements
  AccelerometerData? accelerometerData;
  GyroscopeData? gyroscopeData;
  GPSData? gpsData;

  bool isDataComplete(){
    if(accelerometerData == null || gpsData == null || gyroscopeData == null){ return false; } 
    return true;
  }

  void addAccelerometerData(AccelerometerData data){
    
    updateAccGyr();
    accelerometerData ??= data;

  }

  void addGyroscopeData(GyroscopeData data){

    updateAccGyr();
    gyroscopeData ??= data;

  }

  void updateAccGyr(){

    if(accelerometerData == null || gyroscopeData == null){ return; }

    if(lastAccGyrData.length >= lastMeasurement){
      lastAccGyrData.removeAt(0);
    }

    lastAccGyrData.add(AccGyrData(accelerometerData!, gyroscopeData!));
    accelerometerData = null; gyroscopeData = null;

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

  GyroscopeData getGyroscopeData(){
    if(gyroscopeData == null){
      return GyroscopeData(0, 0, 0);
    } return gyroscopeData as GyroscopeData;
  }

  void update(){

    if(isDataComplete()){

      // TODO: check if the data in the list is to send
      if(true){
        // TODO: send data
      }

    }

  }
  
}
