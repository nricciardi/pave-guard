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

  // === PINs ===
  pinMode(configuration.temperaturePin, INPUT);
  pinMode(configuration.humidityPin, INPUT);
  
  // === BRIDGE ===
  bridge->setup();
}

// ========================== WORK ==========================
void Device::work() {
  Serial.println("device working...");
}

int Device::readTemperature() {

  int temperature = 0;

  Serial.print("temperature read: ");
  Serial.println(temperature);
}















