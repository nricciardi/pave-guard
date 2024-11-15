#include "bridge.h"

Bridge* Bridge::instance = nullptr;

Bridge* Bridge::GetInstance() {
  if(instance == nullptr) {
    instance = new Bridge();
  }

  return instance;
}

bool Bridge::setup() {

  Serial.println("setupping bridge...");

  if (WiFi.status() == WL_NO_MODULE) {
    Serial.println("CRITICAL: communication with WiFi module failed!");

    return false;
  }

  String fv = WiFi.firmwareVersion();
  if (fv < WIFI_FIRMWARE_LATEST_VERSION) {
    Serial.println("please upgrade the firmware");
  }

  unsigned int attempts = 0;
  // attempt to connect to WiFi network:
  while (status != WL_CONNECTED) {
    Serial.print("attempting to connect to SSID: ");
    Serial.println(configuration.wifiSsid);

    // Connect to WPA/WPA2 network. Change this line if using open or WEP network:
    status = WiFi.begin(configuration.wifiSsid, configuration.wifiPassword);

    attempts += 1;

    if(attempts > configuration.maxConnectionAttempts) {
      Serial.println("max connection attempts");

      return false;
    }

    // wait for new connection:
    delay(configuration.connectionRetryDelayInMillis);
  }

  // connected now, so print out the status:
  printWifiStatus();

  return true;
}

bool Bridge::work() {
  // Serial.println("bridge working...");

  return true;
}

void Bridge::put(Telemetry* telemetry) {
  Serial.println("put new telemetry");
}

void Bridge::printWifiStatus() {

  // print the SSID of the network you're attached to:
  Serial.print("SSID: ");
  Serial.println(WiFi.SSID());

  // print your board's IP address:
  IPAddress ip = WiFi.localIP();
  Serial.print("IP Address: ");
  Serial.println(ip);

  // print the received signal strength:
  long rssi = WiFi.RSSI();
  Serial.print("signal strength (RSSI):");
  Serial.print(rssi);
  Serial.println(" dBm");
}

















