#ifndef DEVICE_H
#define DEVICE_H


#include <Arduino.h>
#include "DHT.h"
#include "bridge.h"
#include "temperature-telemetry.h"
#include "fail-telemetry.h"

// ==== DEVICE SIGN ====
// information about specific device, these information are unique for each device

struct DeviceSign {
  String deviceId;
  double latitude;
  double longitude;
};

const DeviceSign deviceSign = {
  .deviceId = String("testId"),
  .latitude = 42,
  .longitude = 42
};


// ==== DEVICE CONFIGURATION ====
// information about pin numbers, rates and other general configuration options

struct DeviceConfiguration {
  bool verbose;
  unsigned char humidityTemperaturePin;
  int humidityTemperatureSensorType;
  unsigned int temperatureSamplingRateInMillis;
  unsigned int humiditySamplingRateInMillis;
};

const DeviceConfiguration deviceConfiguration = {
  .verbose = true,
  .humidityTemperaturePin = 2,
  .humidityTemperatureSensorType = DHT22,
  .temperatureSamplingRateInMillis = 3 * 1000,
  .humiditySamplingRateInMillis = 4 * 1000,
};


class Device {

  protected:

    const Bridge* bridge = Bridge::GetInstance();

    DHT* dht;

    unsigned long lastTemperatureSamplingMillis = 0;
    unsigned long lastHumiditySamplingMillis = 0;

    static Device* instance;

    Device(): sign(deviceSign), configuration(deviceConfiguration) {
    }

  public:

    const DeviceSign sign;
    const DeviceConfiguration configuration;

    /**
    * Singletons should not be cloneable.
    */
    Device(Device &other) = delete;

    /**
    * Singletons should not be assignable.
    */
    void operator=(const Device &) = delete;

    static Device* GetInstance();
    
    /**
    * Setup
    */
    void setup();

    /**
    * Work
    */
    void work();

    void handleHumidityAndTemperature();
};
























#endif