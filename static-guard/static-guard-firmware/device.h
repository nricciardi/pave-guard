#ifndef DEVICE_H
#define DEVICE_H


#include <Arduino.h>
#include "DHT.h"
#include "bridge.h"
#include "temperature-telemetry.h"
#include "humidity-telemetry.h"
#include "fail-telemetry.h"
#include "led-controller.h"

// ==== DEVICE SIGN ====
// information about specific device, these information are unique for each device

struct DeviceSign {
  char* deviceId;
  double latitude;
  double longitude;
};

const DeviceSign deviceSign = {
  .deviceId = "6740fb2648b2c22e3b6970b9",
  .latitude = 42,
  .longitude = 42
};


// ==== DEVICE CONFIGURATION ====
// information about pin numbers, rates and other general configuration options

struct DeviceConfiguration {
  unsigned short delayBeforeSetupInMillis; 

  unsigned char humidityTemperatureSensorPin;
  int humidityTemperatureSensorType;
  unsigned int temperatureSamplingRateInMillis;
  unsigned int humiditySamplingRateInMillis;

  bool ledLogEnabled;
  bool debug;
};

const DeviceConfiguration deviceConfiguration = {
  .delayBeforeSetupInMillis = 2 * 1000,
  .humidityTemperatureSensorPin = 2,
  .humidityTemperatureSensorType = DHT22,
  .temperatureSamplingRateInMillis = 8 * 60 * 1000,
  .humiditySamplingRateInMillis = 8 * 60 * 1000,

  .ledLogEnabled = true,
  .debug = true,
};


class Device {

  protected:

    Bridge* bridge = Bridge::GetInstance();

    DHT* dht = nullptr;

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

    void handleTemperature();

    void handleHumidity();
};
























#endif