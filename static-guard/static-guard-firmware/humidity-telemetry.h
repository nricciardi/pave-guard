#ifndef HUMIDITY_TELEMETRY_H
#define HUMIDITY_TELEMETRY_H

#include "telemetry.h"
#include <Arduino.h>

class HumidityTelemetry: public Telemetry {

  private:
    double humidity;

  public:
    HumidityTelemetry(String deviceId, double latitude, double longitude, float humidity): Telemetry(deviceId, latitude, longitude), humidity(humidity) {}

  String toSendableString() const override {
    return String("HumidityTelemetry");
  }
};




#endif