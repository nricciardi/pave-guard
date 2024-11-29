#include "device.h"
#include "led-controller.h"

#define SERIAL_SPEED 2000000

Device* device = Device::GetInstance();

void setup() {
  Serial.begin(SERIAL_SPEED);   // debug only

  device->setup();
}

void loop() {

  device->work();
}