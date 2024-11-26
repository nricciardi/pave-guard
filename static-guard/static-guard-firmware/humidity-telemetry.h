#ifndef HUMIDITY_TELEMETRY_H
#define HUMIDITY_TELEMETRY_H

#include "telemetry.h"
#include <Arduino.h>

class HumidityTelemetry: public Telemetry {

  private:
    float humidity;

  public:
    HumidityTelemetry(String deviceId, unsigned long timestampInSeconds, double latitude, double longitude, float humidity): Telemetry(deviceId, timestampInSeconds, latitude, longitude), humidity(humidity) {}

  String toGraphqlMutationBody() override {

    String extraBody("humidity:");
    extraBody.concat(humidity);

    return buildGraphqlMutationBody("createHumidityTelemetry", &extraBody);
  }
};




#endif