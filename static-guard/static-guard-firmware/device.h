#include <sys/_intsup.h>
#ifndef DEVICE_H
#define DEVICE_H


#include <Arduino.h>
#include "DHT.h"
#include "bridge.h"
#include "temperature-telemetry.h"
#include "humidity-telemetry.h"
#include "fail-alert.h"
#include "rain-telemetry.h"
#include "transit-telemetry.h"
#include "led-controller.h"
#include "queue.h"

// ==== DEVICE CONFIGURATION ====
// information about device, pin numbers, rates and other general configuration options

struct DeviceConfiguration {
  char* deviceId;

  unsigned short delayBeforeSetupInMillis; 

  bool enableHumiditySensor;
  bool enableTemperatureSensor;
  unsigned char humidityTemperatureSensorPin;
  int humidityTemperatureSensorType;
  unsigned int temperatureSamplingRateInMillis;
  unsigned int humiditySamplingRateInMillis;
  float temperatureOffset;
  float humidityOffset;

  bool enableTransitTriggerSensor;
  unsigned char transitTriggerLeftSensorPin;
  unsigned char transitTriggerRightSensorPin;
  double transitTriggersdistanceInMeters;
  unsigned short transitTriggerQueueSize;
  unsigned long transitTriggerTrigThresholdInMicros;
  unsigned long transitTriggerInterruptOffsetInMicros;      // fix miss increment of timer during interrupt

  bool enableRainGaugeSensor;
  unsigned char rainGaugeSensorPin;
  float rainTriggerMultiplierInMm;
  unsigned int rainSamplesElaborationRateInMillis;
  unsigned long rainGaugeTrigThresholdInMillis;

  bool ledLogEnabled;
  bool debug;
};

const DeviceConfiguration deviceConfiguration = {

  .deviceId = "6769255b374b0ea6b2e92882",

  .delayBeforeSetupInMillis = 2 * 1000,

  .enableHumiditySensor = true,
  .enableTemperatureSensor = true,
  .humidityTemperatureSensorPin = 7,
  .humidityTemperatureSensorType = DHT22,
  .temperatureSamplingRateInMillis = 5 * 60 * 1000,
  .humiditySamplingRateInMillis = 5 * 60 * 1000,
  .temperatureOffset = 0,
  .humidityOffset = 0,

  .enableTransitTriggerSensor = true,
  .transitTriggerLeftSensorPin = 2,
  .transitTriggerRightSensorPin = 3,
  .transitTriggersdistanceInMeters = 0.186,
  .transitTriggerQueueSize = 40,
  .transitTriggerTrigThresholdInMicros = 50 * 1000,
  .transitTriggerInterruptOffsetInMicros = 100,

  .enableRainGaugeSensor = true,
  .rainGaugeSensorPin = 8,
  .rainTriggerMultiplierInMm = 0.3,
  .rainSamplesElaborationRateInMillis = 2 * 1000,
  .rainGaugeTrigThresholdInMillis = 150,

  .ledLogEnabled = true,
  .debug = true,
};


class Device {

  protected:

    Bridge* bridge = Bridge::GetInstance();

    DHT* dht = nullptr;

    unsigned long lastTemperatureSamplingMillis = 0;
    unsigned long lastHumiditySamplingMillis = 0;

    UnsignedLongQueue* transitTriggerLeftQueue = new UnsignedLongQueue(deviceConfiguration.transitTriggerQueueSize);
    UnsignedLongQueue* transitTriggerRightQueue = new UnsignedLongQueue(deviceConfiguration.transitTriggerQueueSize);

    unsigned int rainGaugeUnhandledTrigs = 0;
    unsigned int lastRainGaugeTrig = 0;
    unsigned long lastRainGaugeSamplesElaborationMillis = 0;

    static Device* instance;

    Device(): configuration(deviceConfiguration) {
    }

  public:

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

    void elaborateRainGaugeUnhandledSamples();

    void elaborateTransitTriggersUnhandledSamples();

    // === INTERRUPT CALLBACKs ===
    static void onTransitTriggerLeftTrig();

    static void onTransitTriggerRightTrig();

    static void onRainGaugeTrig();
};




















#endif