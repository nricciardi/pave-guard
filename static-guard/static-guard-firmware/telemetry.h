#ifndef TELEMETRY_H
#define TELEMETRY_H

#include <Arduino.h>


class Telemetry {

  protected:
    char* deviceId;
    unsigned long timestampInSeconds;

    String buildGraphqlMutationBody(char* mutationRef, String* extraBody);

  public:
    Telemetry(char* deviceId, unsigned long timestampInSeconds): deviceId(deviceId), timestampInSeconds(timestampInSeconds) {
    }

    char* getDeviceId() {
      return deviceId;
    }

    virtual String toGraphqlMutationBody() = 0;
};











#endif