#ifndef BRIDGE_H
#define BRIDGE_H

#include <Arduino.h>
#include <WiFiS3.h>
#include <HttpClient.h>
#include <NTPClient.h>
#include <WiFiUdp.h>
#include "telemetry.h"
#include "led-controller.h"


#define BUCKET_SIZE 30      // MAX 30
#define BUCKET_THRESHOLD 4


// ==== BRIDGE CONFIGURATION ====
struct BridgeConfiguration {
  bool wifiConnectionNeeded;

  unsigned short bucketSize;
  unsigned short bucketSendingThreshold;

  char* wifiSsid;
  char* wifiPassword;
  char* serverAddress;
  unsigned short serverPort;

  char* ntpServerUrl;
  int ntpTimeOffset;
  unsigned int ntpTimeUpdateIntervalInMillis;

  unsigned int connectionRetryDelayInMillis;
  unsigned int maxConnectionAttempts;
  unsigned int sendRetryDelayInMillis;
  unsigned int maxSendAttempts;

  bool ledLogEnabled;
  bool debug;
};

const BridgeConfiguration bridgeConfiguration = {
  .wifiConnectionNeeded = true,

  .bucketSize = BUCKET_SIZE,
  .bucketSendingThreshold = BUCKET_THRESHOLD,

  .wifiSsid = "ncla",
  .wifiPassword = "Omegone!",
  .serverAddress = "192.168.137.178",
  .serverPort = 3000,

  .ntpServerUrl = "it.pool.ntp.org",
  .ntpTimeOffset = 0,
  .ntpTimeUpdateIntervalInMillis = 60 * 1000,

  .connectionRetryDelayInMillis = 2 * 1000,
  .maxConnectionAttempts = 500,
  .sendRetryDelayInMillis = 2 * 1000,
  .maxSendAttempts = 3,

  .ledLogEnabled = true,
  .debug = true,
};

class Bridge {

  protected:

    const BridgeConfiguration configuration;

    Telemetry** bucket = new Telemetry*[bridgeConfiguration.bucketSize];
    unsigned short telemetriesInBucket = 0;

    static Bridge* instance;

    WiFiClient wifiClient;
    WiFiUDP wifiUdp;
    int status = WL_IDLE_STATUS;

    HttpClient* httpClient = nullptr;
    NTPClient* ntpClient = nullptr;

    Bridge(): configuration(bridgeConfiguration) {
    }

    void printWifiStatus();

    String buildRequestBody() const;

    void cleanBucket();

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

    unsigned long getEpochTimeFromNtpServerInSeconds(bool forceUpdate = false) const;
};



#endif