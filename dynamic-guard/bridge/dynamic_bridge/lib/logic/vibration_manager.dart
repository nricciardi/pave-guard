import 'dart:math';

class GPSData {
  double latitude, longitude;
  GPSData(this.latitude, this.longitude);

  double getLatitude() {
    return latitude;
  }

  double getLongitude() {
    return longitude;
  }
}

class AccelerometerData {
  double x, y, z;
  AccelerometerData(this.x, this.y, this.z);

  double getX() {
    return x;
  }

  double getY() {
    return y;
  }

  double getZ() {
    return z;
  }
}

class VibrationManager {
  static const int lastMeasurement = 200;
  static const int severityThreshold = 15;

  // Last x measurements for comparisons reason
  List<AccelerometerData> lastAccData = List.empty(growable: true);
  List<GPSData> lastGPSData = List.empty(growable: true);

  // Latest measurements
  AccelerometerData? accelerometerData;
  GPSData? gpsData;

  bool isDataComplete() {
    if (accelerometerData == null || gpsData == null) {
      return false;
    }
    return true;
  }

  void addAccelerometerData(AccelerometerData data) {
    updateAcc();
    accelerometerData ??= data;
  }

  void updateAcc() {
    if (accelerometerData == null) {
      return;
    }

    if (lastAccData.length >= lastMeasurement) {
      lastAccData.removeAt(0);
    }

    lastAccData.add(accelerometerData!);
    accelerometerData = null;
  }

  void addGpsData(GPSData data) {
    if (gpsData == null) {
      gpsData = data;
      return;
    }

    if (lastGPSData.length >= lastMeasurement) {
      lastGPSData.removeAt(0);
    }

    lastGPSData.add(gpsData!);
    gpsData = data;
  }

  GPSData getGpsData() {
    if (gpsData == null) {
      return GPSData(0, 0);
    }
    return gpsData as GPSData;
  }

  AccelerometerData getAccelerometerData() {
    if (accelerometerData == null) {
      return AccelerometerData(0, 0, 0);
    }
    return accelerometerData as AccelerometerData;
  }

  Map<GPSData, int> getDataToSend() {
    Map<GPSData, int> toRet = {};
    int severity;
    for (int i = 0; i < lastAccData.length; i++) {
      severity = measureSeverity(lastAccData[i]);
      if (severity >= severityThreshold) {
        toRet[lastGPSData[i]] = severity;
      }
    }

    lastAccData.removeRange(0, lastAccData.length);
    lastGPSData.removeRange(0, lastGPSData.length);

    return toRet;
  }

  int measureSeverity(AccelerometerData data) {
    return max((data.x - 200).round(), 0);
  }
}
