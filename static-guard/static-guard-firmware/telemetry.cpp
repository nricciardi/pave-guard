#include "telemetry.h"

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

    virtual float getData() const = 0;
};

class TemperatureTelemetry: public Telemetry {
  private:
    double temperature;

  public:
    TemperatureTelemetry(const String& id, float temp) : Telemetry(id), temperature(temp) {}

    float getTemperature() const {
      return temperature;
    }

    void setTemperature(float temp) {
      temperature = temp;
    }

    float getData() const override {
      return temperature;
    }
};