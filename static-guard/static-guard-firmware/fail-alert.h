#ifndef FAIL_TELEMETRY_H
#define FAIL_TELEMETRY_H

#include "telemetry.h"
#include <Arduino.h>

class FailAlert: public Telemetry {

  private:

    String code;

    String message;

  public:
    FailAlert(String deviceId, unsigned long timestampInSeconds, String code, String message): Telemetry(deviceId, timestampInSeconds), code(code), message(message) {}

  String toGraphqlMutationBody() override {

    String body("mutation{createFailAlert(deviceId:\\\"");
    body.concat(deviceId);
    body.concat("\\\",timestamp:\\\"");
    body.concat(timestampInSeconds);
    body.concat("000\\\",");    // timestamp in millis
    body.concat("code:\\\"" + code + "\\\",");
    body.concat("message:\\\"" + message + "\\\"){id}}");
  }
};




#endif