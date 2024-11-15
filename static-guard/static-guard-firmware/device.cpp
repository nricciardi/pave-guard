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
  Serial.println("setupping device...");

  // === HUMIDITY & TEMPERATURE ===
  dht = new DHT(configuration.humidityTemperaturePin, configuration.humidityTemperatureSensorType);
  dht->begin();
  
  // === BRIDGE ===
  bridge->setup();
}

// ========================== WORK ==========================
void Device::work() {
  
  /*delay(2000);

  // Reading temperature or humidity takes about 250 milliseconds!
  // Sensor readings may also be up to 2 seconds 'old' (its a very slow sensor)
  float h = dht->readHumidity();
  
  // Read temperature as Fahrenheit (isFahrenheit = true)
  float f = dht->readTemperature(true);

  // Check if any reads failed and exit early (to try again).
  if (isnan(h) || isnan(t) || isnan(f)) {
    Serial.println(F("Failed to read from DHT sensor!"));
    return;
  }

  // Compute heat index in Fahrenheit (the default)
  float hif = dht->computeHeatIndex(f, h);
  // Compute heat index in Celsius (isFahreheit = false)
  float hic = dht->computeHeatIndex(t, h, false);

  Serial.print(F("Humidity: "));
  Serial.print(h);
  Serial.print(F("%  Temperature: "));
  Serial.print(t);
  Serial.print(F("°C "));
  Serial.print(f);
  Serial.print(F("°F  Heat index: "));
  Serial.print(hic);
  Serial.print(F("°C "));
  Serial.print(hif);
  Serial.println(F("°F"));*/

}

void Device::handleHumidityAndTemperature() {
  
  // Read temperature as Celsius (the default)
  float t = dht->readTemperature();

  if(!isnan(t)) {

    if(configuration.verbose) {
      Serial.print("read temperature: ");
      Serial.println(t);
    }

    TemperatureTelemetry temperatureTelemetry(sign.deviceId, sign.latitude, sign.longitude, t);

    bridge->put((Telemetry*) temperatureTelemetry);

  } else {

    if(configuration.verbose) {
      Serial.println("ERROR: fail to read temperature");
    }
    
    FailTelemetry failTelemetry(sign.deviceId, sign.latitude, sign.longitude, String("HT001"), String("Fail to read humidity and temperature"));
  }

}












