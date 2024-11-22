#ifndef TELEMETRY_H
#define TELEMETRY_H

#include <Arduino.h>


class Telemetry {

  protected:
    String deviceId;
    
    double latitude;
    double longitude;

    String buildGraphqlMutationBody(const char* mutationRef, String extraBody) const;

  public:
    Telemetry(String deviceId, double latitude, double longitude): deviceId(deviceId), latitude(latitude), longitude(longitude) {
    }

    String getDeviceId() const {
      return deviceId;
    }

    void setDeviceId(const String& id) {
      deviceId = id;
    }

    virtual String toGraphqlMutationBody() const = 0;
};











#endif