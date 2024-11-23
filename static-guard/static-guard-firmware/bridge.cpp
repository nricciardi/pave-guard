#include "Arduino.h"
#include "api/Common.h"
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
  while (true) {
    Serial.print("attempting to connect to SSID: '");
    Serial.print(configuration.wifiSsid);
    Serial.print("'... ");

    // Connect to WPA/WPA2 network. Change this line if using open or WEP network:
    status = WiFi.begin(configuration.wifiSsid, configuration.wifiPassword);

    if(status == WL_CONNECTED) {
      
      Serial.println("done!");
      break;

    } else {

      Serial.print("FAILED");
    }

    attempts += 1;

    if(attempts > configuration.maxConnectionAttempts) {
      Serial.println("\n\nCRITICAL: max connection attempts\n\n");

      return false;
    }

    Serial.println(" (but retrying)");

    // wait for new connection:
    delay(configuration.connectionRetryDelayInMillis);
  }
  
  // connected now, so print out the status:
  printWifiStatus();

  // initialize http client
  httpClient = new HttpClient(wifiClient, configuration.serverAddress, configuration.serverPort);


  return true;
}

bool Bridge::work() {
  
  if(telemetriesInBucket >= configuration.bucketSendingThreshold) {

    printWifiStatus();

    Serial.println("telemetries will be sent before that queue reaches a critical state");

    sendWithRetry();   // ignore outcome, it will be retried later
  }

  return true;
}

void Bridge::put(Telemetry* telemetry) {
  Serial.println("putting new telemetry...");

  if(telemetriesInBucket + 1 >= configuration.bucketLength) {
    Serial.println("WARNING: queue is full, it will be empty before any other actions");

    bool areSent = sendWithRetry();
    
    if(!areSent)
      Serial.println("CRITICAL: error during sending phase, telemetries in queue will be lost");

    cleanBucket();
  }

  bucket[telemetriesInBucket] = telemetry;
  telemetriesInBucket += 1;

  Serial.print("new telemetry was correctly saved in queue (");
  Serial.print(telemetriesInBucket);
  Serial.print("/");
  Serial.print(configuration.bucketLength);
  Serial.println(")");
}

void Bridge::cleanBucket() {
  for(unsigned short i=0; i < telemetriesInBucket; i++) {
    // delete bucket[i];
  }

  telemetriesInBucket = 0;
}

bool Bridge::send() {

  Serial.println("sending telemetries...");

  String body = buildRequestBody();
  
  Serial.print("opening POST connection to server... ");
  httpClient->beginRequest();

  int connectionResult = httpClient->post("/graphql");
  if (connectionResult == 0) {

    Serial.println("opened!");

  } else {

    Serial.println("FAILED");

    return false;
  }

  httpClient->sendHeader("Content-Type", "application/json");
  httpClient->sendHeader("Content-Length", body.length());
  httpClient->sendHeader("X-Custom-Header", "custom-header-value");
  httpClient->beginBody();
  httpClient->print(body);
  httpClient->endRequest();

  Serial.println("request having body: \n" + body);    // too many characters... it should not be printed

  Serial.print("sending... ");

  // read the status code and body of the response
  int statusCode = httpClient->responseStatusCode();
  String response = httpClient->responseBody();

  Serial.print("SENT status code: ");
  Serial.println(statusCode);

  if(statusCode < 200 || statusCode > 299) {

    Serial.println("telemetry NOT sent");

    Serial.print("response: ");
    Serial.println(response);

    return false;
  }

  cleanBucket();

  Serial.println("telemetry sent!");

  return true;
}

String Bridge::buildRequestBody() const {
  String body("{\"query\":\"mutation{");

  for(unsigned short i=0; i < telemetriesInBucket; i++) {
    body.concat("update");
    body.concat(i);
    body.concat(":");
    body.concat(bucket[i]->toGraphqlMutationBody()); 
    body.concat(",");
  }
  
  body.concat("}\"}");

  return body;
}

bool Bridge::sendWithRetry() {
  Serial.println("sending telemetries (with retry system)...");

  unsigned int attempts = 0;
  bool sendSuccess = false;

  while(attempts < configuration.maxSendAttempts) {
    
    sendSuccess = send();

    attempts += 1;

    if(sendSuccess)
      break;

    Serial.println("ERROR: error occurs during sending...");

    delay(configuration.sendRetryDelayInMillis);      // execution must be blocked
  }

  if(!sendSuccess) {
    Serial.println("ERROR: telemetries are not sent");
    return false;
  }

  Serial.println("telemetries sent successfully");

  return true;
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

















