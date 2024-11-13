
#include "temperature-telemetry.h"



void setup() {
  Serial.begin(9600);

  // TemperatureTelemetry temperatureTelemetry(String("testId"), 6);

  TemperatureTelemetry temperatureTelemetry(String("testId"), 42);

  Serial.println(temperatureTelemetry.getDeviceId());
}

void loop() {
}