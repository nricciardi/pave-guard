#include <DHT.h>
#include <DHT_U.h>

#include "device.h"



const Device* device = Device::GetInstance();

void setup() {
  Serial.begin(9600);   // debug only

  device->setup();
}

void loop() {

  device->work();
}