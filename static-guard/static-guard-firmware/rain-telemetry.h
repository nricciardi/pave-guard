#ifndef RAIN_TELEMETRY_H
#define RAIN_TELEMETRY_H

#include "telemetry.h"
#include <Arduino.h>

class RainTelemetry: public Telemetry {

  private:
    float litres;

  public:
    RainTelemetry(String deviceId, unsigned long timestampInSeconds, double latitude, double longitude, float litres): Telemetry(deviceId, timestampInSeconds, latitude, longitude), litres(litres) {}

  String toGraphqlMutationBody() override {

    String extraBody("litres:");
    extraBody.concat(litres);

    return buildGraphqlMutationBody("createRainTelemetry", &extraBody);
  }
};




#endif