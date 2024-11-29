#ifndef QUEUE_H
#define QUEUE_H

#include <Arduino.h>

class UnsignedLongQueue {

  public:
    unsigned long* queue;
    unsigned int size;
    int nextIndex = 0;

    UnsignedLongQueue(unsigned int size) {
      this->size = size;
      queue = new unsigned long[size];

      clear();
    }

    ~UnsignedLongQueue() {
      delete[] queue;
    }

    void push(unsigned long item) {

      for(int i=nextIndex; i >= 1; i -= 1) {
        queue[nextIndex] = queue[nextIndex - 1];
      }

      queue[0] = item;
      nextIndex = min(nextIndex + 1, size);
    }

    void pushIfGreaterThanLast(unsigned long item, unsigned long threshold) {

      if(item - getLastInserted() > threshold)
        push(item);
    }

    unsigned long getFirstInserted() {
      return queue[max(nextIndex - 1, 0)];
    }

    unsigned long getLastInserted() {
      return queue[0];
    }

    unsigned long pop() {

      unsigned long item = getFirstInserted();

      queue[max(nextIndex - 1, 0)] = nullValue();
      nextIndex = max(nextIndex - 1, 0);

      return item;
    }

    unsigned long get(unsigned short i) {
      return queue[i];
    }

    void print() {
      Serial.print("(");
      Serial.print(nItems());
      Serial.print(") [ ");
      for(unsigned short i=0; i < nextIndex; i++) {
        Serial.print(queue[i]);
        Serial.print(" ");
      }
      Serial.println("]");
    }

    void clear() {
      for(unsigned short i=0; i < size; i++) {
        queue[i] = nullValue();
      }

      nextIndex = 0;
    }

    bool isFull() {
      return nextIndex == size;
    }
  
    unsigned long nullValue() {
      return 0;
    }

    unsigned short nItems() {
      return nextIndex;
    }
};








#endif