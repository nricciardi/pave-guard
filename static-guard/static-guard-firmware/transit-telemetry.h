#ifndef TRANSIT_TELEMETRY_H
#define TRANSIT_TELEMETRY_H

#include "telemetry.h"
#include <Arduino.h>

class TransitTelemetry: public Telemetry {

  private:
    double length;
    double velocity;
    double transitTime;

  public:
    TransitTelemetry(char* deviceId, unsigned long timestampInSeconds, double length, double velocity, double transitTime): Telemetry(deviceId, timestampInSeconds), length(length), velocity(velocity), transitTime(transitTime) {}

  String toGraphqlMutationBody() override {

    String extraBody("length:");
    extraBody.concat(String(length, 3));
    extraBody.concat(",velocity:");
    extraBody.concat(String(velocity, 3));
    extraBody.concat(",transitTime:");
    extraBody.concat(String(transitTime, 3));


    return buildGraphqlMutationBody("createTransitTelemetry", &extraBody);
  }
};




#endif