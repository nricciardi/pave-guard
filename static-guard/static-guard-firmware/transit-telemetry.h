#ifndef TRANSIT_TELEMETRY_H
#define TRANSIT_TELEMETRY_H

#include "telemetry.h"
#include <Arduino.h>

class TransitTelemetry: public Telemetry {

  private:
    double length;
    double velocity;

  public:
    TransitTelemetry(String deviceId, unsigned long timestampInSeconds, double latitude, double longitude, double length, double velocity): Telemetry(deviceId, timestampInSeconds, latitude, longitude), length(length), velocity(velocity) {}

  String toGraphqlMutationBody() override {

    String extraBody("length:");
    extraBody.concat(length);
    extraBody.concat("velocity: ");
    extraBody.concat(velocity);

    return buildGraphqlMutationBody("createTransitTelemetry", &extraBody);
  }
};




#endif