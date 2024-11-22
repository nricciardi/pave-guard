#include "device.h"

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
  
  // === BRIDGE ===
  bool bridgeSetupOutcome = bridge->setup();

  if(!bridgeSetupOutcome) {

    Serial.println("CRITICAL: impossible to setup bridge, execution will be blocked");

    // don't continue
    while(true);
  }
}

// ========================== WORK ==========================
void Device::work() {

  long currentMillis;
  
  currentMillis = millis();
  if(currentMillis - lastTemperatureSamplingMillis > configuration.temperatureSamplingRateInMillis) {
    handleTemperature();

    lastTemperatureSamplingMillis = currentMillis;
  }

  currentMillis = millis();
  if(currentMillis - lastHumiditySamplingMillis > configuration.humiditySamplingRateInMillis) {
    handleHumidity();

    lastHumiditySamplingMillis = currentMillis;
  }
  
  bridge->work();
}

void Device::handleHumidity() {
  
  float h = dht->readHumidity();

  if(!isnan(h)) {

    Serial.print("read humidity: ");
    Serial.println(h);

    HumidityTelemetry humidityTelemetry(sign.deviceId, sign.latitude, sign.longitude, h);

    bridge->put(&humidityTelemetry);

  } else {

    Serial.println("ERROR: fail to read humidity");
    
    FailTelemetry failTelemetry(sign.deviceId, sign.latitude, sign.longitude, String("HT001"), String("Fail to read humidity"));

    bridge->put(&failTelemetry);
  }

}

void Device::handleTemperature() {
  
  // Read temperature as Celsius (the default)
  float t = dht->readTemperature();

  if(!isnan(t)) {

    Serial.print("read temperature: ");
    Serial.println(t);

    TemperatureTelemetry temperatureTelemetry(sign.deviceId, sign.latitude, sign.longitude, t);

    bridge->put(&temperatureTelemetry);

  } else {

    Serial.println("ERROR: fail to read temperature");
    
    FailTelemetry failTelemetry(sign.deviceId, sign.latitude, sign.longitude, String("HT002"), String("Fail to read temperature"));

    bridge->put(&failTelemetry);
  }

}












