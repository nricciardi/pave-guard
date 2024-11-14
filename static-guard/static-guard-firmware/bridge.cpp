#include "bridge.h"

Bridge* Bridge::instance = nullptr;

Bridge* Bridge::GetInstance() {
  if(instance == nullptr) {
    instance = new Bridge();
  }

  return instance;
}

bool Bridge::setup() {
  Serial.println("setupping bridge...");

  return true;
}

bool Bridge::work() {
  Serial.println("bridge working...");

  return true;
}

/*bool Bridge::put(Telemetry* telemetry) {
  Serial.println("put new telemetry");

  return true;
}*/



















