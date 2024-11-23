#include "led-controller.h"

ArduinoLEDMatrix matrix;
bool matrixBegun = false;
bool enablePrint = true;      // set to false to prevent print on Led Matrix

void printOnLedMatrix(const char* text, unsigned long speed, bool print) {

  if(!print || !enablePrint)
    return;

  if(!matrixBegun) {

    matrix.begin();
    matrixBegun = true;
  }

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