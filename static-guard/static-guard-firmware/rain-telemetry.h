#ifndef RAIN_TELEMETRY_H
#define RAIN_TELEMETRY_H

#include "telemetry.h"
#include <Arduino.h>

class RainTelemetry: public Telemetry {

  private:
    float mm;

  public:
    RainTelemetry(String deviceId, unsigned long timestampInSeconds, float mm): Telemetry(deviceId, timestampInSeconds), mm(mm) {}

  String toGraphqlMutationBody() override {

    String extraBody("mm:");
    extraBody.concat(String(mm, 4));

    return buildGraphqlMutationBody("createRainTelemetry", &extraBody);
  }
};




#endif