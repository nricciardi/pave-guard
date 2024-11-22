#ifndef HUMIDITY_TELEMETRY_H
#define HUMIDITY_TELEMETRY_H

#include "telemetry.h"
#include <Arduino.h>

class HumidityTelemetry: public Telemetry {

  private:
    double humidity;

  public:
    HumidityTelemetry(char* deviceId, double latitude, double longitude, float humidity): Telemetry(deviceId, latitude, longitude), humidity(humidity) {}

  String toGraphqlMutationBody() override {

    Serial.println("in to graph body");
  
    String extraBody("humidity: ");
    extraBody.concat(humidity);

    Serial.println("pre return");

    return extraBody; //buildGraphqlMutationBody("createHumidityTelemetries", &extraBody);
  }
};




#endif