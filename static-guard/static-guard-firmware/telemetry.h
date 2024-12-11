#ifndef TELEMETRY_H
#define TELEMETRY_H

#include <Arduino.h>


class Telemetry {

  protected:
    String deviceId;
    unsigned long timestampInSeconds;

    String buildGraphqlMutationBody(char* mutationRef, String* extraBody);

  public:
    Telemetry(String deviceId, unsigned long timestampInSeconds): deviceId(deviceId), timestampInSeconds(timestampInSeconds) {
    }

    String* getDeviceId() {
      return &deviceId;
    }

    virtual String toGraphqlMutationBody() = 0;
};











#endif