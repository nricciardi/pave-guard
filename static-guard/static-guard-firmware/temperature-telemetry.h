#ifndef TEMPERATURE_TELEMETRY_H
#define TEMPERATURE_TELEMETRY_H

#include "telemetry.h"
#include <Arduino.h>

class TemperatureTelemetry: public Telemetry {

  private:
    double temperature;

  public:
    TemperatureTelemetry(char* deviceId, double latitude, double longitude, float temperature): Telemetry(deviceId, latitude, longitude), temperature(temperature) {}

    String toGraphqlMutationBody() override {

      Serial.println("temperatura!!!!");

      String extraBody("tempearture: ");
      extraBody.concat(temperature);

      return extraBody;//buildGraphqlMutationBody("createTemperatureTelemetries", &extraBody);
    }
};




#endif