#ifndef TELEMETRY_H
#define TELEMETRY_H

#include <Arduino.h>


class Telemetry {

  protected:
    String deviceId;

    double latitude;
    double longitude;

  public:
    Telemetry(String deviceId, double latitude, double longitude): deviceId(deviceId), latitude(latitude), longitude(longitude) {
    }

    String getDeviceId() const {
      return deviceId;
    }

    void setDeviceId(const String& id) {
      deviceId = id;
    }

    virtual String toSendableString() const = 0;
};











#endif