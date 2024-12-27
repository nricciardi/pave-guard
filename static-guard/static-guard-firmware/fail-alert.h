#ifndef FAIL_TELEMETRY_H
#define FAIL_TELEMETRY_H

#include "telemetry.h"
#include <Arduino.h>

class FailAlert: public Telemetry {

  private:

    char* code;

    char* message;

  public:
    FailAlert(char* deviceId, unsigned long timestampInSeconds, char* code, char* message): Telemetry(deviceId, timestampInSeconds), code(code), message(message) {}

  String toGraphqlMutationBody() override {

    String body("createFailAlert(deviceId:\\\"");
    body.concat(deviceId);
    body.concat("\\\",timestamp:\\\"");
    body.concat(timestampInSeconds);
    body.concat("000\\\",");    // timestamp in millis
    body.concat("code:\\\"");
    body.concat(code);
    body.concat("\\\",");
    body.concat("message:\\\"");
    body.concat(message);
    body.concat("\\\"){id}");

    return body;
  }
};




#endif