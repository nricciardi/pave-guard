#ifndef TEMPERATURE_TELEMETRY_H
#define TEMPERATURE_TELEMETRY_H

#include "telemetry.h"
#include <Arduino.h>

class TemperatureTelemetry: public Telemetry {

  private:
    double temperature;

  public:
    TemperatureTelemetry(String deviceId, double latitude, double longitude, float temperature): Telemetry(deviceId, latitude, longitude), temperature(temperature) {}

  String toGraphqlMutationBody() const override {

    String extraBody("tempearture: ");
    extraBody.concat(temperature);

    return Telemetry::buildGraphqlMutationBody("createTemperatureTelemetries", extraBody);
  }
};




#endif