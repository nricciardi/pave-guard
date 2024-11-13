#ifndef TEMPERATURE_TELEMETRY_H
#define TEMPERATURE_TELEMETRY_H

#include "telemetry.h"
#include <Arduino.h>

class TemperatureTelemetry: public Telemetry {
  private:
    double temperature;

  public:
    TemperatureTelemetry(const String& id, float temp) : Telemetry(id), temperature(temp) {}

  String toSendableString() const override {
    return String("prova");
  }
};














#endif