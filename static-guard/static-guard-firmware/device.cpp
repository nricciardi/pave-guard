#include <sys/_intsup.h>
#include "Arduino.h"
#include "api/Common.h"
#include "device.h"

// ==== INTERRUPTs ====
void Device::onTrafficTriggerLeftTrig() {
  Device::instance->trafficTriggerLeftBucket->append(millis());
}

void Device::onTrafficTriggerRightTrig() {
  Device::instance->trafficTriggerRightBucket->append(millis());
}

void Device::onRainGaugeTrig() {
  Device::instance->rainGaugeUnhandledTrigs += 1;
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


  // === HUMIDITY & TEMPERATURE ===
  dht = new DHT(configuration.humidityTemperatureSensorPin, configuration.humidityTemperatureSensorType);
  dht->begin();

  // === TRAFFIC TRIGGERs ===
  pinMode(configuration.trafficTriggerLeftSensorPin, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(configuration.trafficTriggerLeftSensorPin), Device::onTrafficTriggerLeftTrig, LOW);

  pinMode(configuration.trafficTriggerRightSensorPin, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(configuration.trafficTriggerRightSensorPin), Device::onTrafficTriggerRightTrig, LOW);

  // === RAIN GAUGE ===
  pinMode(configuration.rainGaugeSensorPin, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(configuration.rainGaugeSensorPin), Device::onRainGaugeTrig, RISING);
  

  // === BRIDGE ===
  bool bridgeSetupOutcome = bridge->setup();

  if(!bridgeSetupOutcome) {

    Serial.println("CRITICAL: impossible to setup bridge, execution will be blocked");

    // don't continue
    while(true);
  }

  Serial.print("device OK: ");
  Serial.println(sign.deviceId);

  printOnLedMatrix("DEVICE OK", 50, configuration.ledLogEnabled);
}

// ========================== WORK ==========================
void Device::work() {

  long currentMillis;
  
  currentMillis = millis();
  if(configuration.enableTemperatureRead && (currentMillis - lastTemperatureSamplingMillis > configuration.temperatureSamplingRateInMillis)) {
    handleTemperature();

    lastTemperatureSamplingMillis = currentMillis;
  }

  currentMillis = millis();
  if(configuration.enableHumidityRead && (currentMillis - lastHumiditySamplingMillis > configuration.humiditySamplingRateInMillis)) {
    handleHumidity();

    lastHumiditySamplingMillis = currentMillis;
  }

  currentMillis = millis();
  if(configuration.enableRainGaugeRead && (currentMillis - lastRainGaugeSamplesElaborationMillis > configuration.rainSamplesElaborationRateInMillis)) {
    elaborateRainGaugeUnhandledSamples();

    lastRainGaugeSamplesElaborationMillis = currentMillis;
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

  unsigned long timestamp = bridge->getEpochTimeFromNtpServerInSeconds();

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


