#ifndef FAIL_TELEMETRY_H
#define FAIL_TELEMETRY_H

#include "telemetry.h"
#include <Arduino.h>

class FailTelemetry: public Telemetry {

  private:

    String code;

    String message;

  public:
    FailTelemetry(String deviceId, double latitude, double longitude, String code, String message): Telemetry(deviceId, latitude, longitude), code(code), message(message) {}

  String toGraphqlMutationBody() const override {

    String extraBody("");

    return buildGraphqlMutationBody("createTemperatureTelemetries", extraBody);
  }
};




#endif