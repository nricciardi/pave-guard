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

  if(configuration.enableTransitTriggerSensor) {
    elaborateTransitTriggersUnhandledSamples();
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

  if(abs(transitTriggerLeftQueue->nItems() - transitTriggerRightQueue->nItems()) > 1) {

    Serial.println("ERROR: inconsistent queues");

    Serial.println("WARNING: queues will be cleared");
    transitTriggerRightQueue->clear();
    transitTriggerLeftQueue->clear();

    FailTelemetry* failTelemetry = new FailTelemetry(sign.deviceId, timestamp, sign.latitude, sign.longitude, String("TT003"), String("Inconsistent queues"));

    bridge->put(failTelemetry);
    
    return;
  }

  if((transitTriggerLeftQueue->nItems() < 2) || (transitTriggerRightQueue->nItems() < 2))
    return;

  
  if(configuration.debug) {
    Serial.println("transit samples:");
    Serial.print("left: ");
    transitTriggerLeftQueue->print();
    Serial.print("right: ");
    transitTriggerRightQueue->print();
  }

  noInterrupts();
  
  unsigned long microsOfRightTrig1 = transitTriggerRightQueue->pop();
  unsigned long microsOfLeftTrig1 = transitTriggerLeftQueue->pop();
  unsigned long microsOfRightTrig2 = transitTriggerRightQueue->pop();
  unsigned long microsOfLeftTrig2 = transitTriggerLeftQueue->pop();

  interrupts();

  if(microsOfRightTrig1 == microsOfLeftTrig1 || microsOfRightTrig2 == microsOfLeftTrig2) {

    Serial.println("ERROR: same time in transit samples");

    Serial.println("WARNING: queues will be cleared");
    transitTriggerRightQueue->clear();
    transitTriggerLeftQueue->clear();

    FailTelemetry* failTelemetry = new FailTelemetry(sign.deviceId, timestamp, sign.latitude, sign.longitude, String("TT003"), String("Same time in transit samples"));

    bridge->put(failTelemetry);
    
    return;
  }

  unsigned long deltaTime1InMicros = configuration.transitTriggerInterruptOffsetInMicros;

  if(microsOfRightTrig1 > microsOfLeftTrig1)
    deltaTime1InMicros += microsOfRightTrig1 - microsOfLeftTrig1;
  else
    deltaTime1InMicros += microsOfLeftTrig1 - microsOfRightTrig1;

  unsigned long deltaTime2InMicros = configuration.transitTriggerInterruptOffsetInMicros;   // 3 offset - 2 offset

  if(microsOfRightTrig2 > microsOfLeftTrig2)
    deltaTime2InMicros += microsOfRightTrig2 - microsOfLeftTrig2;
  else
    deltaTime2InMicros += microsOfLeftTrig2 - microsOfRightTrig2;

  double transitTimeInMicros = configuration.transitTriggerInterruptOffsetInMicros * 3; // us

  if(microsOfLeftTrig2 > microsOfRightTrig1)
    transitTimeInMicros += microsOfLeftTrig2 - microsOfRightTrig1;
  else
    transitTimeInMicros += microsOfRightTrig2 - microsOfLeftTrig1;

  double partialTransitTimeInMicros = configuration.transitTriggerInterruptOffsetInMicros * 2 + min(microsOfRightTrig2 - microsOfRightTrig1, microsOfLeftTrig2 - microsOfLeftTrig1); // us

  double transitTimeInSeconds = transitTimeInMicros / 1000000.0; // us -> s
  double partialTransitTimeInSeconds = partialTransitTimeInMicros / 1000000.0; // us -> s


  double velocity1 = configuration.transitTriggersdistanceInMeters / ((double) deltaTime1InMicros);   // m/us
  double velocity2 = configuration.transitTriggersdistanceInMeters / ((double) deltaTime2InMicros);   // m/us

  if(velocity1 <= 0 || isnan(velocity1) || velocity2 <= 0 || isnan(velocity2)) {

    Serial.println("ERROR: trouble during velocity computation");
    
    Serial.println("WARNING: queues will be cleared");
    transitTriggerRightQueue->clear();
    transitTriggerLeftQueue->clear();

    FailTelemetry* failTelemetry = new FailTelemetry(sign.deviceId, timestamp, sign.latitude, sign.longitude, String("TT002"), String("Computed velocities is less or equal to zero"));

    bridge->put(failTelemetry);
    
    return;
  }

  double meanVelocity = (double) (velocity1 + velocity2) / 2.0;  // m/s
  meanVelocity *= 1000000.0;  // m/us -> m/s

  if(transitTimeInSeconds <= 0 || isnan(transitTimeInSeconds) || partialTransitTimeInSeconds <= 0 || isnan(partialTransitTimeInSeconds) ) {

    Serial.println("ERROR: trouble during transit time computation");

    Serial.println("WARNING: queues will be cleared");
    transitTriggerRightQueue->clear();
    transitTriggerLeftQueue->clear();

    FailTelemetry* failTelemetry = new FailTelemetry(sign.deviceId, timestamp, sign.latitude, sign.longitude, String("TT003"), String("Transit time is less or equal to zero"));

    bridge->put(failTelemetry);
    
    return;
  }

  double vehicleLength = meanVelocity * partialTransitTimeInSeconds;   // m/s * s = m
  meanVelocity *= 3.6;    // m/s * 3.6 = km/h

  if(configuration.debug) {
    Serial.print("transit: length -> ");
    Serial.print(vehicleLength, 3);
    Serial.print("m; velocity -> ");
    Serial.print(meanVelocity, 3);
    Serial.print("km/h (");
    Serial.print(meanVelocity / 3.6, 3);
    Serial.println("m/s)");
  }

  if(vehicleLength <= 0 || isnan(vehicleLength) || meanVelocity <= 0 || isnan(meanVelocity)) {

    Serial.println("ERROR: trouble during transit computation");

    String msg("Vehicle length or velocity is less or equal to zero or inf. Length: ");
    msg.concat(vehicleLength);
    msg.concat("; velocity: ");
    msg.concat(meanVelocity);

    Serial.println("WARNING: queues will be cleared");
    transitTriggerRightQueue->clear();
    transitTriggerLeftQueue->clear();

    FailTelemetry* failTelemetry = new FailTelemetry(sign.deviceId, timestamp, sign.latitude, sign.longitude, String("TT004"), msg);

    bridge->put(failTelemetry);
    
    return;
  }

  Telemetry* transitTelemetry = new TransitTelemetry(sign.deviceId, timestamp, sign.latitude, sign.longitude, vehicleLength, meanVelocity, transitTimeInSeconds);

  bridge->put(transitTelemetry);
}



































