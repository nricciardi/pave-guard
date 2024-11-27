#include <sys/_intsup.h>
#include "Arduino.h"
#include "api/Common.h"
#include "device.h"

// ==== INTERRUPTs ====
void Device::onTrafficTriggerLeftTrig() {
  Device::instance->trafficTriggerLeftBucket->appendIfGreaterThanLast(millis(), Device::instance->configuration.trafficTriggerTrigThresholdInMillis);
}

void Device::onTrafficTriggerRightTrig() {
  Device::instance->trafficTriggerRightBucket->appendIfGreaterThanLast(millis(), Device::instance->configuration.trafficTriggerTrigThresholdInMillis);
}

void Device::onRainGaugeTrig() {

  if(abs(Device::instance->lastRainGaugeTrig - millis()) <= Device::instance->configuration.rainGaugeTrigThresholdInMillis)
    return;

  Device::instance->rainGaugeUnhandledTrigs += 1;
  Device::instance->lastRainGaugeTrig = millis();
}


Device* Device::instance = nullptr;

Device* Device::GetInstance() {
  if(instance == nullptr) {
    instance = new Device();
  }

  return instance;
}


// ========================== SETUP ==========================
void Device::setup() {

  if(configuration.delayBeforeSetupInMillis > 0) {
    Serial.print("setup delayed of ");
    Serial.println(configuration.delayBeforeSetupInMillis);
    delay(configuration.delayBeforeSetupInMillis);
  }

  Serial.println("setupping device...");

  // === BRIDGE ===
  bool bridgeSetupOutcome = bridge->setup();

  if(!bridgeSetupOutcome) {

    Serial.println("CRITICAL: impossible to setup bridge, execution will be blocked");

    // don't continue
    while(true);
  }


  // === HUMIDITY & TEMPERATURE ===
  dht = new DHT(configuration.humidityTemperatureSensorPin, configuration.humidityTemperatureSensorType);
  dht->begin();

  // === TRAFFIC TRIGGERs ===
  pinMode(configuration.trafficTriggerLeftSensorPin, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(configuration.trafficTriggerLeftSensorPin), Device::onTrafficTriggerLeftTrig, CHANGE);

  pinMode(configuration.trafficTriggerRightSensorPin, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(configuration.trafficTriggerRightSensorPin), Device::onTrafficTriggerRightTrig, CHANGE);

  // === RAIN GAUGE ===
  pinMode(configuration.rainGaugeSensorPin, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(configuration.rainGaugeSensorPin), Device::onRainGaugeTrig, RISING);
  


  Serial.print("device OK: ");
  Serial.println(sign.deviceId);

  printOnLedMatrix("DEVICE OK", 50, configuration.ledLogEnabled);
}

// ========================== WORK ==========================
void Device::work() {

  long currentMillis;
  
  currentMillis = millis();
  if(configuration.enableTemperatureSensor && (currentMillis - lastTemperatureSamplingMillis > configuration.temperatureSamplingRateInMillis)) {

    noInterrupts();

    handleTemperature();

    interrupts();

    lastTemperatureSamplingMillis = currentMillis;
  }

  currentMillis = millis();
  if(configuration.enableHumiditySensor && (currentMillis - lastHumiditySamplingMillis > configuration.humiditySamplingRateInMillis)) {

    noInterrupts();

    handleHumidity();

    interrupts();

    lastHumiditySamplingMillis = currentMillis;
  }

  currentMillis = millis();
  if(configuration.enableRainGaugeSensor && (currentMillis - lastRainGaugeSamplesElaborationMillis > configuration.rainSamplesElaborationRateInMillis)) {

    noInterrupts();

    elaborateRainGaugeUnhandledSamples();

    interrupts();

    lastRainGaugeSamplesElaborationMillis = currentMillis;
  }

  if(configuration.enableTrafficTriggerSensor && (trafficTriggerLeftBucket->index > configuration.trafficTriggerBucketCleaningThreshold) && (trafficTriggerRightBucket->index > configuration.trafficTriggerBucketCleaningThreshold)) {
    elaborateTrafficTriggersUnhandledSamples();
  }
  
  bridge->work();
}

void Device::handleHumidity() {
  
  float h = dht->readHumidity();

  unsigned long timestamp = bridge->getEpochTimeFromNtpServerInSeconds();

  if(!isnan(h)) {

    if(configuration.debug) {
      Serial.print("read humidity: ");
      Serial.println(h);
    }

    HumidityTelemetry* humidityTelemetry = new HumidityTelemetry(sign.deviceId, timestamp, sign.latitude, sign.longitude, h);

    bridge->put(humidityTelemetry);

  } else {

    Serial.println("ERROR: fail to read humidity");
    
    FailTelemetry* failTelemetry = new FailTelemetry(sign.deviceId, timestamp, sign.latitude, sign.longitude, String("HT001"), String("Fail to read humidity"));

    bridge->put(failTelemetry);
  }
}

void Device::handleTemperature() {
  
  // Read temperature as Celsius (the default)
  float t = dht->readTemperature();

  interrupts();

  unsigned long timestamp = bridge->getEpochTimeFromNtpServerInSeconds();

  if(!isnan(t)) {

    if(configuration.debug) {
      Serial.print("read temperature: ");
      Serial.println(t);
    }
    
    Telemetry* temperatureTelemetry = new TemperatureTelemetry(sign.deviceId, timestamp, sign.latitude, sign.longitude, t);

    bridge->put(temperatureTelemetry);

  } else {

    Serial.println("ERROR: fail to read temperature");
    
    FailTelemetry* failTelemetry = new FailTelemetry(sign.deviceId, timestamp, sign.latitude, sign.longitude, String("HT002"), String("Fail to read temperature"));

    bridge->put(failTelemetry);
  }
}

void Device::elaborateRainGaugeUnhandledSamples() {

  if(rainGaugeUnhandledTrigs <= 0)
    return;

  unsigned long timestamp = bridge->getEpochTimeFromNtpServerInSeconds() - ((millis() - lastRainGaugeTrig) / 1000);

  unsigned long totalMm = (float) rainGaugeUnhandledTrigs * configuration.rainTriggerMultiplierInMm;

  if(configuration.debug) {
    Serial.print("elaborate rain gauge unhandled samples: ");
    Serial.print(rainGaugeUnhandledTrigs);
    Serial.print(" => ");
    Serial.println(totalMm);
  }
    
  Telemetry* rainTelemetry = new RainTelemetry(sign.deviceId, timestamp, sign.latitude, sign.longitude, totalMm);

  bridge->put(rainTelemetry);

  rainGaugeUnhandledTrigs = 0;
}

void Device::elaborateTrafficTriggersUnhandledSamples() {

  unsigned long timestamp = bridge->getEpochTimeFromNtpServerInSeconds();

  for(unsigned short i = 1; (i < trafficTriggerLeftBucket->index) && (i < trafficTriggerRightBucket->index); i += 2) {

    unsigned long millisOfLeftTrig1 = trafficTriggerLeftBucket->get(i-1);
    unsigned long millisOfRightTrig1 = trafficTriggerRightBucket->get(i-1);
    unsigned long millisOfLeftTrig2 = trafficTriggerLeftBucket->get(i);
    unsigned long millisOfRightTrig2 = trafficTriggerRightBucket->get(i);

    double velocity1 = configuration.trafficTriggersdistanceInMeters / (double) (millisOfRightTrig1 - millisOfLeftTrig1);
    double velocity2 = configuration.trafficTriggersdistanceInMeters / (double) (millisOfRightTrig2 - millisOfLeftTrig2);

    if(velocity1 <= 0 || velocity2 <= 0) {

      Serial.println("ERROR: trouble during velocity computation");

      FailTelemetry* failTelemetry = new FailTelemetry(sign.deviceId, timestamp, sign.latitude, sign.longitude, String("TT001"), String("Computed velocity is less or equal to zero"));

      bridge->put(failTelemetry);
      
      continue;
    }

    double meanVelocity = (velocity1 + velocity2) / 2.0 * 1000.0;  // m/s

    double transitTimeInSeconds = (millisOfRightTrig2 - millisOfLeftTrig1) / 1000.0;

    if(transitTimeInSeconds <= 0) {

      Serial.println("ERROR: trouble during transit time computation");

      FailTelemetry* failTelemetry = new FailTelemetry(sign.deviceId, timestamp, sign.latitude, sign.longitude, String("TT001"), String("Transit time is less or equal to zero"));

      bridge->put(failTelemetry);
      
      continue;
    }

    double vehicleLength = meanVelocity * transitTimeInSeconds;

    if(configuration.debug) {
      Serial.print("transit: length -> ");
      Serial.print(vehicleLength);
      Serial.print("m; velocity -> ");
      Serial.print(meanVelocity);
      Serial.print("m/s = ");
      Serial.print(meanVelocity * 3.6);
      Serial.println("km/s");
    }

    Telemetry* transitTelemetry = new TransitTelemetry(sign.deviceId, timestamp, sign.latitude, sign.longitude, vehicleLength, meanVelocity);

    bridge->put(transitTelemetry);
  }

  trafficTriggerLeftBucket->clear();
  trafficTriggerRightBucket->clear();
}



































