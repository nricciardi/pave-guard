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


#define TRANSIT_TRIGGER_BUCKET_SIZE 12  // must be even (e.g. 40)
#define TRANSIT_TRIGGER_BUCKET_CLEANING_THRESHOLD 6   // must be even (e.g. 20)


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

  bool enableTrafficTriggerSensor;
  unsigned char trafficTriggerLeftSensorPin;
  unsigned char trafficTriggerRightSensorPin;
  double trafficTriggersdistanceInMeters;
  unsigned short trafficTriggerBucketSize;
  unsigned short trafficTriggerBucketCleaningThreshold;
  unsigned long trafficTriggerTrigThresholdInMillis;

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
  .humiditySamplingRateInMillis = 8 * 1000,

  .enableTrafficTriggerSensor = true,
  .trafficTriggerLeftSensorPin = 2,
  .trafficTriggerRightSensorPin = 3,
  .trafficTriggersdistanceInMeters = 0.180,
  .trafficTriggerBucketSize = TRANSIT_TRIGGER_BUCKET_SIZE,
  .trafficTriggerBucketCleaningThreshold = TRANSIT_TRIGGER_BUCKET_CLEANING_THRESHOLD,
  .trafficTriggerTrigThresholdInMillis = 10,

  .enableRainGaugeSensor = true,
  .rainGaugeSensorPin = 8,
  .rainTriggerMultiplierInMm = 1.0,
  .rainSamplesElaborationRateInMillis = 2 * 1000,
  .rainGaugeTrigThresholdInMillis = 50,

  .ledLogEnabled = true,
  .debug = true,
};

class UnsignedLongBucket {

  public:
    unsigned long* bucket;
    unsigned short size;
    unsigned short index;

    UnsignedLongBucket(unsigned short size) {
      this->size = size;
      bucket = new unsigned long[size];
      index = 0;

      for(unsigned short i=0; i < size; i++) {
        bucket[i] = 0;
      }
    }

    void append(unsigned long item) {
      bucket[index] = item;
      index = (index + 1) % size;
    }

    void appendIfGreaterThanLast(unsigned long item, unsigned long threshold) {

      if(abs(getLast() - item) > threshold)
        append(item);
      
    }

    unsigned long getLast() {
      return bucket[max(index - 1, 0)];
    }

    unsigned long get(unsigned short i) {
      return bucket[i];
    }

    void print() {
      Serial.print("(");
      Serial.print(index);
      Serial.print(") [ ");
      for(unsigned short i=0; i < index; i++) {
        Serial.print(bucket[i]);
        Serial.print(" ");
      }
      Serial.println("]");
    }

    void clear() {
      index = 0;
    }
};

class Device {

  protected:

    Bridge* bridge = Bridge::GetInstance();

    DHT* dht = nullptr;

    unsigned long lastTemperatureSamplingMillis = 0;
    unsigned long lastHumiditySamplingMillis = 0;

    UnsignedLongBucket* trafficTriggerLeftBucket = new UnsignedLongBucket(deviceConfiguration.trafficTriggerBucketSize);
    UnsignedLongBucket* trafficTriggerRightBucket = new UnsignedLongBucket(deviceConfiguration.trafficTriggerBucketSize);

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

    void elaborateTrafficTriggersUnhandledSamples();

    // === INTERRUPT CALLBACKs ===
    static void onTrafficTriggerLeftTrig();

    static void onTrafficTriggerRightTrig();

    static void onRainGaugeTrig();
};




















#endif