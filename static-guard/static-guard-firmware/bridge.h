#ifndef BRIDGE_H
#define BRIDGE_H

#include <Arduino.h>
#include "telemetry.h"

const unsigned short QUEUE_LENGTH = 20;


class Bridge {

  protected:

    // Telemetry* queue[QUEUE_LENGTH];

    static Bridge* instance;

    Bridge() {
    }

  public:

    /**
    * Singletons should not be cloneable.
    */
    Bridge(Bridge &other) = delete;

    /**
    * Singletons should not be assignable.
    */
    void operator=(const Bridge &) = delete;

    static Bridge* GetInstance();

    /**
    * Setup bridge: instance comunication with server
    */
    bool setup();

    /**
    * Verify and send if queue is full
    */
    bool work();

    /**
    * Used by other components to delegate telemetry sent
    */
    void put(Telemetry* telemetry);

};



#endif