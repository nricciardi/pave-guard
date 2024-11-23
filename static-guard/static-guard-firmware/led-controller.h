#ifndef LED_CONTROLLER_H
#define LED_CONTROLLER_H

#include <Arduino.h>
#include "ArduinoGraphics.h"
#include "Arduino_LED_Matrix.h"

extern ArduinoLEDMatrix matrix;
extern bool matrixBegun;
extern bool enablePrint;

void printOnLedMatrix(const char* text, unsigned long speed = 30, bool print = true);

#endif