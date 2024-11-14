#include "device.h"

Device* Device::instance = nullptr;

Device* Device::GetInstance() {
  if(instance == nullptr) {
    instance = new Device();
  }

  return instance;
}

void Device::setup() {
  Serial.println("setupping device...");

  // === PINs ===
  pinMode(configuration.temperaturePin, INPUT);
  pinMode(configuration.humidityPin, INPUT);
  
  // === BRIDGE ===
  bridge->setup();
}

void Device::work() {
  Serial.println("device working...");
}