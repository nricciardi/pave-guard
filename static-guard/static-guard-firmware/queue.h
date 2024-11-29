#ifndef QUEUE_H
#define QUEUE_H


class UnsignedLongQueue {

  public:
    unsigned long* queue;
    unsigned short size;
    unsigned short head;   // next index of head item

    UnsignedLongQueue(unsigned short size) {
      this->size = size;
      queue = new unsigned long[size];
      head = 0;

      clear();
    }

    unsigned long shift() {

      unsigned long poppedItem = queue[size-1];

      for(unsigned short i=size-1; i >= 1; i++) {
        queue[i] = queue[i-1];
      }

      queue[0] = nullValue();   // clear first item
      
      head = min(head + 1, size);

      return poppedItem;
    }

    unsigned long push(unsigned long item) {

      unsigned long poppedItem = shift();

      queue[0] = item;

      return poppedItem;
    }

    unsigned long pushIfGreaterThanLast(unsigned long item, unsigned long threshold) {

      if(item - getLast() > threshold)
        return push(item);
      
      return nullValue();
    }

    unsigned long getLast() {
      return queue[max(head - 1, 0)];
    }

    unsigned long popLast() {
      unsigned long item = getLast();

      head = max(head - 1, 0);
      queue[head] = nullValue();

      return item;
    }

    unsigned long get(unsigned short i) {
      return queue[i];
    }

    void print() {
      Serial.print("(");
      Serial.print(head - 1);
      Serial.print(") [ ");
      for(unsigned short i=0; i < size; i++) {
        Serial.print(queue[i]);
        Serial.print(" ");
      }
      Serial.println("]");
    }

    void clear() {
      for(unsigned short i=0; i < size; i++) {
        queue[i] = nullValue();
      }

      head = 0;
    }

    bool isFull() {
      return head == size;
    }

    unsigned long nullValue() {
      return 0;
    }
};








#endif