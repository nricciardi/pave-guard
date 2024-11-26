#ifndef BRIDGE_H
#define BRIDGE_H

#include <Arduino.h>
#include <WiFiS3.h>
#include <HttpClient.h>
#include <NTPClient.h>
#include <WiFiUdp.h>
#include "telemetry.h"
#include "led-controller.h"


#define BUCKET_LENGTH 10      // MAX 30


// ==== BRIDGE CONFIGURATION ====
struct BridgeConfiguration {
  bool wifiConnectionNeeded;

  unsigned short bucketLength;
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
  .wifiConnectionNeeded = false,

  .bucketLength = BUCKET_LENGTH,
  .bucketSendingThreshold = (unsigned short) (BUCKET_LENGTH * 0.6),

  .wifiSsid = "Not eduroam",
  .wifiPassword = "celestecarbone",
  .serverAddress = "192.168.91.3",
  .serverPort = 3001,

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

    Telemetry** bucket = new Telemetry*[bridgeConfiguration.bucketLength];
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