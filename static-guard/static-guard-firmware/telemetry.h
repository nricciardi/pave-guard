#ifndef TELEMETRY_H
#define TELEMETRY_H

#include <Arduino.h>


class Telemetry {

  protected:
    String deviceId;
    unsigned long timestampInSeconds;
    double latitude;
    double longitude;

    String buildGraphqlMutationBody(char* mutationRef, String* extraBody);

  public:
    Telemetry(String deviceId, unsigned long timestampInSeconds, double latitude, double longitude): deviceId(deviceId), timestampInSeconds(timestampInSeconds), latitude(latitude), longitude(longitude) {
    }

    String* getDeviceId() {
      return &deviceId;
    }

    virtual String toGraphqlMutationBody() = 0;
};











#endif