#include "led-controller.h"


bool matrixBegun = false;     // DO NOT TOUCH THIS! (it is used by internal logic)

ArduinoLEDMatrix matrix;
bool enablePrint = true;      // set to false to prevent print on Led Matrix
float showTimeMultiplier = 1.2;

void printOnLedMatrix(const char* text, unsigned long speed, bool print) {

  if(!print || !enablePrint)
    return;

  if(!matrixBegun) {

    matrix.begin();
    matrixBegun = true;
  }

  speed *= showTimeMultiplier;

  matrix.beginDraw();

  matrix.stroke(0xFFFFFFFF);
  matrix.textScrollSpeed(speed);

  matrix.textFont(Font_5x7);
  matrix.beginText(0, 1, 0xFFFFFF);
  matrix.print("   ");
  matrix.print(text);
  matrix.println(" ");
  matrix.endText(SCROLL_LEFT);

  matrix.endDraw();
}