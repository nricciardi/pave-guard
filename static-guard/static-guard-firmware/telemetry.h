#ifndef TELEMETRY_H
#define TELEMETRY_H

#include <Arduino.h>


class Telemetry {
  protected:
    String deviceId;

  public:
    Telemetry(const String& id) : deviceId(id) {}

    String getDeviceId() const {
      return deviceId;
    }

    void setDeviceId(const String& id) {
      deviceId = id;
    }

    virtual String toSendableString() const = 0;
};











#endif