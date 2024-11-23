#ifndef TELEMETRY_H
#define TELEMETRY_H

#include <Arduino.h>


class Telemetry {

  protected:
    String deviceId;
    
    double latitude;
    double longitude;

    String buildGraphqlMutationBody(char* mutationRef, String* extraBody);

  public:
    Telemetry(String deviceId, double latitude, double longitude): deviceId(deviceId), latitude(latitude), longitude(longitude) {
    }

    String* getDeviceId() {
      return &deviceId;
    }

    void setDeviceId(String id) {
      deviceId = id;
    }

    virtual String toGraphqlMutationBody() = 0;
};











#endif