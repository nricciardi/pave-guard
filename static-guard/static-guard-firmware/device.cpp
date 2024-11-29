#include <sys/_intsup.h>
#include "Arduino.h"
#include "api/Common.h"
#include "device.h"

// ==== INTERRUPTs ====
void Device::onTransitTriggerLeftTrig() {
  Device::instance->transitTriggerLeftQueue->pushIfGreaterThanLast(micros(), Device::instance->configuration.transitTriggerTrigThresholdInMicros);
}

void Device::onTransitTriggerRightTrig() {
  Device::instance->transitTriggerRightQueue->pushIfGreaterThanLast(micros(), Device::instance->configuration.transitTriggerTrigThresholdInMicros);
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
  pinMode(configuration.transitTriggerLeftSensorPin, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(configuration.transitTriggerLeftSensorPin), Device::onTransitTriggerLeftTrig, CHANGE);

  pinMode(configuration.transitTriggerRightSensorPin, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(configuration.transitTriggerRightSensorPin), Device::onTransitTriggerRightTrig, CHANGE);

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

    handleTemperature();

    lastTemperatureSamplingMillis = currentMillis;
  }

  currentMillis = millis();
  if(configuration.enableHumiditySensor && (currentMillis - lastHumiditySamplingMillis > configuration.humiditySamplingRateInMillis)) {

    handleHumidity();

    lastHumiditySamplingMillis = currentMillis;
  }

  currentMillis = millis();
  if(configuration.enableRainGaugeSensor && (currentMillis - lastRainGaugeSamplesElaborationMillis > configuration.rainSamplesElaborationRateInMillis)) {

    elaborateRainGaugeUnhandledSamples();

    lastRainGaugeSamplesElaborationMillis = currentMillis;
  }

  if(configuration.enableTransitTriggerSensor && (transitTriggerLeftQueue->head > configuration.transitTriggerQueueElaborationThreshold) && (transitTriggerRightQueue->head > configuration.transitTriggerQueueElaborationThreshold)) {
    elaborateTransitTriggersUnhandledSamples();

    Serial.println("stop");
    while(true);
  }

  Serial.println(transitTriggerLeftQueue->head);
  transitTriggerLeftQueue->push(8);
  
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

void Device::elaborateTransitTriggersUnhandledSamples() {

  unsigned long timestamp = bridge->getEpochTimeFromNtpServerInSeconds();

  for(unsigned short i = 1; (i < transitTriggerLeftQueue->head) && (i < transitTriggerRightQueue->head); i += 2) {

    // transit is supposed: RIGHT ==> LEFT

    unsigned long microsOfRightTrig2 = transitTriggerRightQueue->popLast();
    unsigned long microsOfLeftTrig2 = transitTriggerLeftQueue->popLast();
    unsigned long microsOfRightTrig1 = transitTriggerRightQueue->popLast();
    unsigned long microsOfLeftTrig1 = transitTriggerLeftQueue->popLast();

    if(microsOfRightTrig1 > microsOfLeftTrig1 || microsOfLeftTrig1 > microsOfRightTrig2 || microsOfRightTrig2 > microsOfLeftTrig2) {

      Serial.println("ERROR: invalid trig samples");

      FailTelemetry* failTelemetry = new FailTelemetry(sign.deviceId, timestamp, sign.latitude, sign.longitude, String("TT001"), String("Invalid trig samples"));

      bridge->put(failTelemetry);
      
      continue;
    }

    double velocity1 = configuration.transitTriggersdistanceInMeters / (double) (configuration.transitTriggerInterruptOffsetInMicros + microsOfLeftTrig1 - microsOfRightTrig1);   // m/us
    double velocity2 = configuration.transitTriggersdistanceInMeters / (double) (configuration.transitTriggerInterruptOffsetInMicros * 2 + microsOfLeftTrig2 - microsOfRightTrig2);   // m/us

    if(velocity1 <= 0 || isnan(velocity1) || velocity2 <= 0 || isnan(velocity2)) {

      Serial.println("ERROR: trouble during velocity computation");
      Serial.println("WARNING: queues will be cleared");
      transitTriggerRightQueue->clear();
      transitTriggerLeftQueue->clear();

      FailTelemetry* failTelemetry = new FailTelemetry(sign.deviceId, timestamp, sign.latitude, sign.longitude, String("TT002"), String("Computed velocities is less or equal to zero"));

      bridge->put(failTelemetry);
      
      continue;
    }

    velocity1 = velocity1 * 1000000.0;  // m/us -> m/s
    velocity2 = velocity2 * 1000000.0;  // m/us -> m/s

    double meanVelocity = (velocity1 + velocity2) / 2.0;  // m/s

    double transitTimeInSeconds = (configuration.transitTriggerInterruptOffsetInMicros * 2 + microsOfLeftTrig2 - microsOfRightTrig1) / 1000000.0; // us -> s

    if(transitTimeInSeconds <= 0 || isnan(transitTimeInSeconds)) {

      Serial.println("ERROR: trouble during transit time computation");

      FailTelemetry* failTelemetry = new FailTelemetry(sign.deviceId, timestamp, sign.latitude, sign.longitude, String("TT003"), String("Transit time is less or equal to zero"));

      bridge->put(failTelemetry);
      
      continue;
    }

    double vehicleLength = meanVelocity * transitTimeInSeconds;   // m/s * s = m
    meanVelocity = meanVelocity * 3.6;    // m/s * 3.6 = km/h

    if(configuration.debug) {
      Serial.print("transit: length -> ");
      Serial.print(vehicleLength);
      Serial.print("m; velocity -> ");
      Serial.print(meanVelocity);
      Serial.print("km/h (");
      Serial.print(meanVelocity / 3.6);
      Serial.println("m/s)");
    }

    if(vehicleLength <= 0 || isnan(vehicleLength) || meanVelocity <= 0 || isnan(meanVelocity)) {

      Serial.println("ERROR: trouble during transit computation");

      String msg("Vehicle length or velocity is less or equal to zero or inf. Length: ");
      msg.concat(vehicleLength);
      msg.concat("; velocity: ");
      msg.concat(meanVelocity);

      FailTelemetry* failTelemetry = new FailTelemetry(sign.deviceId, timestamp, sign.latitude, sign.longitude, String("TT004"), msg);

      bridge->put(failTelemetry);
      
      continue;
    }

    Telemetry* transitTelemetry = new TransitTelemetry(sign.deviceId, timestamp, sign.latitude, sign.longitude, vehicleLength, meanVelocity);

    bridge->put(transitTelemetry);
  }
}



































