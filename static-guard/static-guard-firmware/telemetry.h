#ifndef TELEMETRY_H
#define TELEMETRY_H

#include <Arduino.h>


class Telemetry {

  protected:
    char* deviceId;
    
    double latitude;
    double longitude;

    String buildGraphqlMutationBody(char* mutationRef, String* extraBody);

  public:
    Telemetry(char* deviceId, double latitude, double longitude): deviceId(deviceId), latitude(latitude), longitude(longitude) {
    }

    char* getDeviceId() const {
      return deviceId;
    }

    void setDeviceId(char* id) {
      deviceId = id;
    }

    virtual String toGraphqlMutationBody() = 0;
};











#endif