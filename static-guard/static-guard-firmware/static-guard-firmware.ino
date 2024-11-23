#include "device.h"
#include "led-controller.h"


Device* device = Device::GetInstance();

void setup() {
  Serial.begin(9600);   // debug only

  device->setup();
}

void loop() {

  device->work();
}