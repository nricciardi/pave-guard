#ifndef RAIN_TELEMETRY_H
#define RAIN_TELEMETRY_H

#include "telemetry.h"
#include <Arduino.h>

class RainTelemetry: public Telemetry {

  private:
    float mm;

  public:
    RainTelemetry(String deviceId, unsigned long timestampInSeconds, double latitude, double longitude, float mm): Telemetry(deviceId, timestampInSeconds, latitude, longitude), mm(mm) {}

  String toGraphqlMutationBody() override {

    String extraBody("mm:");
    extraBody.concat(mm);

    return buildGraphqlMutationBody("createRainTelemetry", &extraBody);
  }
};




#endif