#include <cmath>
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

  if(abs(millis() - Device::instance->lastRainGaugeTrig) <= Device::instance->configuration.rainGaugeTrigThresholdInMillis)
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
  Serial.println(configuration.deviceId);

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
  
  float humidity = dht->readHumidity() + configuration.humidityOffset;

  unsigned long timestamp = bridge->getEpochTimeFromNtpServerInSeconds();

  if(!isnan(humidity)) {

    if(configuration.debug) {
      Serial.print("read humidity: ");
      Serial.print(humidity);
      Serial.print(" (offset: ");
      Serial.print(configuration.humidityOffset);
      Serial.println(")");
    }

    HumidityTelemetry* humidityTelemetry = new HumidityTelemetry(configuration.deviceId, timestamp, humidity);

    bridge->put(humidityTelemetry);

  } else {

    Serial.println("ERROR: fail to read humidity");
    
    FailAlert* failAlert = new FailAlert(configuration.deviceId, timestamp, "HT001", "Fail to read humidity");

    bridge->put(failAlert);
  }
}

void Device::handleTemperature() {
  
  // Read temperature as Celsius (the default)
  float temperature = dht->readTemperature() + configuration.temperatureOffset;

  unsigned long timestamp = bridge->getEpochTimeFromNtpServerInSeconds();

  if(!isnan(temperature)) {

    if(configuration.debug) {
      Serial.print("read temperature: ");
      Serial.print(temperature);
      Serial.print(" (offset: ");
      Serial.print(configuration.temperatureOffset);
      Serial.println(")");
    }
    
    Telemetry* temperatureTelemetry = new TemperatureTelemetry(configuration.deviceId, timestamp, temperature);

    bridge->put(temperatureTelemetry);

  } else {

    Serial.println("ERROR: fail to read temperature");
    
    FailAlert* failAlert = new FailAlert(configuration.deviceId, timestamp, "HT002", "Fail to read temperature");

    bridge->put(failAlert);
  }
}

void Device::elaborateRainGaugeUnhandledSamples() {

  if(rainGaugeUnhandledTrigs <= 0)
    return;

  unsigned long timestamp = bridge->getEpochTimeFromNtpServerInSeconds() - ((millis() - lastRainGaugeTrig) / 1000);

  noInterrupts();

  unsigned int trigs = rainGaugeUnhandledTrigs;
  rainGaugeUnhandledTrigs = 0;

  interrupts();

  float totalMm = (float) trigs * configuration.rainTriggerMultiplierInMm;

  if(configuration.debug) {
    Serial.print("elaborate rain gauge unhandled samples: ");
    Serial.print(trigs);
    Serial.print(" => ");
    Serial.println(totalMm);
  }
    
  Telemetry* rainTelemetry = new RainTelemetry(configuration.deviceId, timestamp, totalMm);

  bridge->put(rainTelemetry);
}

void Device::elaborateTransitTriggersUnhandledSamples() {

  unsigned long timestamp = bridge->getEpochTimeFromNtpServerInSeconds();

  if(abs(transitTriggerLeftQueue->nItems() - transitTriggerRightQueue->nItems()) > 1) {

    Serial.println("ERROR: inconsistent queues");

    Serial.println("WARNING: queues will be cleared");
    transitTriggerRightQueue->clear();
    transitTriggerLeftQueue->clear();

    FailAlert* failAlert = new FailAlert(configuration.deviceId, timestamp, "TT003", "Inconsistent queues");

    bridge->put(failAlert);
    
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

  if(
      microsOfRightTrig1 == microsOfLeftTrig1
      || microsOfRightTrig2 == microsOfLeftTrig2
      || abs(microsOfRightTrig1 - microsOfLeftTrig1) > configuration.transitResetTimeoutInMicros
      || abs(microsOfRightTrig2 - microsOfLeftTrig2) > configuration.transitResetTimeoutInMicros
    ) {

    Serial.println("ERROR: same time in transit samples or delta time greater than timeout");

    Serial.println("WARNING: queues will be cleared");
    transitTriggerRightQueue->clear();
    transitTriggerLeftQueue->clear();

    FailAlert* failAlert = new FailAlert(configuration.deviceId, timestamp, "TT003", "Same time in transit samples or delta time greater than timeout");

    bridge->put(failAlert);
    
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

    Serial.println("ERROR: trouble during velocity computation, computed velocities is less or equal to zero");
    
    Serial.println("WARNING: queues will be cleared");
    transitTriggerRightQueue->clear();
    transitTriggerLeftQueue->clear();

    FailAlert* failAlert = new FailAlert(configuration.deviceId, timestamp, "TT002", "Computed velocities is less or equal to zero");

    bridge->put(failAlert);
    
    return;
  }

  double meanVelocity = (double) (velocity1 + velocity2) / 2.0;  // m/s
  meanVelocity *= 1000000.0;  // m/us -> m/s

  if(transitTimeInSeconds <= 0 || isnan(transitTimeInSeconds) || partialTransitTimeInSeconds <= 0 || isnan(partialTransitTimeInSeconds) ) {

    Serial.println("ERROR: trouble during transit time computation");

    Serial.println("WARNING: queues will be cleared, transit time is less or equal to zero");
    transitTriggerRightQueue->clear();
    transitTriggerLeftQueue->clear();

    FailAlert* failAlert = new FailAlert(configuration.deviceId, timestamp, "TT003", "Transit time is less or equal to zero");

    bridge->put(failAlert);
    
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

    Serial.println("ERROR: vehicle length or velocity is less or equal to zero or inf");

    Serial.println("WARNING: queues will be cleared");
    transitTriggerRightQueue->clear();
    transitTriggerLeftQueue->clear();

    FailAlert* failAlert = new FailAlert(configuration.deviceId, timestamp, "TT004", "Vehicle length or velocity is less or equal to zero or inf");

    bridge->put(failAlert);
    
    return;
  }

  Telemetry* transitTelemetry = new TransitTelemetry(configuration.deviceId, timestamp, vehicleLength, meanVelocity, transitTimeInSeconds);

  bridge->put(transitTelemetry);
}



































