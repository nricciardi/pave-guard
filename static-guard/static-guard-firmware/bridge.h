#ifndef BRIDGE_H
#define BRIDGE_H

#include <Arduino.h>
#include <WiFiS3.h>
#include <ArduinoHttpClient.h>
#include "telemetry.h"


#define QUEUE_LENGTH 5


// ==== BRIDGE CONFIGURATION ====
struct BridgeConfiguration {
  unsigned short queueLength;
  unsigned short queueSendingThreshold;

  char* wifiSsid;
  char* wifiPassword;
  char* serverUrl;
  unsigned short serverPort;

  unsigned int connectionRetryDelayInMillis;
  unsigned int maxConnectionAttempts;
  unsigned int sendRetryDelayInMillis;
  unsigned int maxSendAttempts;
};

const BridgeConfiguration bridgeConfiguration = {
  .queueLength = QUEUE_LENGTH,
  .queueSendingThreshold = (unsigned short) (QUEUE_LENGTH * 0.6),

  .wifiSsid = "Martin Router King Guest 2.4GHz",
  .wifiPassword = "GuestWifi123!",
  .serverUrl = "192.168.0.11",
  .serverPort = 3000,

  .connectionRetryDelayInMillis = 2 * 1000,
  .maxConnectionAttempts = 300,
  .sendRetryDelayInMillis = 2 * 1000,
  .maxSendAttempts = 3
};

class Bridge {

  protected:

    const BridgeConfiguration configuration;

    Telemetry* queue[QUEUE_LENGTH];
    unsigned short telemetriesInQueue = 0;

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

    /**
    * Send telemetries with retry system
    */
    bool sendWithRetry();

    /**
    * Actual send telemetries method
    */
    bool send();
};



#endif