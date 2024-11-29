#include <sys/_intsup.h>
#ifndef DEVICE_H
#define DEVICE_H


#include <Arduino.h>
#include "DHT.h"
#include "bridge.h"
#include "temperature-telemetry.h"
#include "humidity-telemetry.h"
#include "fail-telemetry.h"
#include "rain-telemetry.h"
#include "transit-telemetry.h"
#include "led-controller.h"
#include "queue.h"


#define TRANSIT_TRIGGER_QUEUE_SIZE 12  // must be even (e.g. 40)
#define TRANSIT_TRIGGER_QUEUE_ELABORATION_THRESHOLD 2   // must be >= 2


// ==== DEVICE SIGN ====
// information about specific device, these information are unique for each device

struct DeviceSign {
  char* deviceId;
  double latitude;
  double longitude;
};

const DeviceSign deviceSign = {
  .deviceId = "67236c0933a3695fb68e81db",
  .latitude = 42,
  .longitude = 42
};


// ==== DEVICE CONFIGURATION ====
// information about pin numbers, rates and other general configuration options

struct DeviceConfiguration {
  unsigned short delayBeforeSetupInMillis; 

  bool enableHumiditySensor;
  bool enableTemperatureSensor;
  unsigned char humidityTemperatureSensorPin;
  int humidityTemperatureSensorType;
  unsigned int temperatureSamplingRateInMillis;
  unsigned int humiditySamplingRateInMillis;

  bool enableTransitTriggerSensor;
  unsigned char transitTriggerLeftSensorPin;
  unsigned char transitTriggerRightSensorPin;
  double transitTriggersdistanceInMeters;
  unsigned short transitTriggerQueueSize;
  unsigned short transitTriggerQueueElaborationThreshold;
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
  .delayBeforeSetupInMillis = 2 * 1000,

  .enableHumiditySensor = false,
  .enableTemperatureSensor = false,
  .humidityTemperatureSensorPin = 7,
  .humidityTemperatureSensorType = DHT22,
  .temperatureSamplingRateInMillis = 8 * 1000,
  .humiditySamplingRateInMillis = 9 * 1000,

  .enableTransitTriggerSensor = true,
  .transitTriggerLeftSensorPin = 2,
  .transitTriggerRightSensorPin = 3,
  .transitTriggersdistanceInMeters = 0.186,
  .transitTriggerQueueSize = TRANSIT_TRIGGER_QUEUE_SIZE,
  .transitTriggerQueueElaborationThreshold = TRANSIT_TRIGGER_QUEUE_ELABORATION_THRESHOLD,
  .transitTriggerTrigThresholdInMicros = 50 * 1000,
  .transitTriggerInterruptOffsetInMicros = 0,

  .enableRainGaugeSensor = true,
  .rainGaugeSensorPin = 8,
  .rainTriggerMultiplierInMm = 0.3,
  .rainSamplesElaborationRateInMillis = 2 * 1000,
  .rainGaugeTrigThresholdInMillis = 50,

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

    void elaborateRainGaugeUnhandledSamples();

    void elaborateTransitTriggersUnhandledSamples();

    // === INTERRUPT CALLBACKs ===
    static void onTransitTriggerLeftTrig();

    static void onTransitTriggerRightTrig();

    static void onRainGaugeTrig();
};




















#endif