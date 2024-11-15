#ifndef BRIDGE_H
#define BRIDGE_H

#include <Arduino.h>
#include "WiFiS3.h"
#include "telemetry.h"


#define QUEUE_LENGTH 20


// ==== BRIDGE CONFIGURATION ====
struct BridgeConfiguration {
  unsigned short queueLength;

  char* wifiSsid;
  char* wifiPassword;
  char* serverUrl;
  unsigned short serverPort;
  unsigned int connectionRetryDelayInMillis;
  unsigned int maxConnectionAttempts;
};

const BridgeConfiguration bridgeConfiguration = {
  .queueLength = QUEUE_LENGTH,

  .wifiSsid = "Martin Router King Guest 2.4GHz",
  .wifiPassword = "GuestWifi123!",
  .serverUrl = "127.0.0.1",
  .serverPort = 3000,
  .connectionRetryDelayInMillis = 2 * 1000,
  .maxConnectionAttempts = 300
};

class Bridge {

  protected:

    const BridgeConfiguration configuration;

    Telemetry* queue[QUEUE_LENGTH];

    static Bridge* instance;

    WiFiClient* client = nullptr;
    int status = WL_IDLE_STATUS;

    Bridge(): configuration(bridgeConfiguration) {
    }

    void printWifiStatus();

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