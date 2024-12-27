#ifndef HUMIDITY_TELEMETRY_H
#define HUMIDITY_TELEMETRY_H

#include "telemetry.h"
#include <Arduino.h>

class HumidityTelemetry: public Telemetry {

  private:
    float humidity;

  public:
    HumidityTelemetry(char* deviceId, unsigned long timestampInSeconds, float humidity): Telemetry(deviceId, timestampInSeconds), humidity(humidity) {}

  String toGraphqlMutationBody() override {

    String extraBody("humidity:");
    extraBody.concat(humidity);

    return buildGraphqlMutationBody("createHumidityTelemetry", &extraBody);
  }
};




#endif