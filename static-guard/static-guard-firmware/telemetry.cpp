#include "telemetry.h"

String Telemetry::buildGraphqlMutationBody(char* mutationRef, String* extraBody) {

  String body(mutationRef);
  body.concat("(deviceId:\\\"");
  body.concat(deviceId);
  body.concat("\\\",timestamp:\\\"");
  body.concat(timestampInSeconds);
  body.concat("000\\\"");    // timestamp in millis
  
  if(!extraBody->isEmpty())
    body.concat(",");

  body.concat(*extraBody);

  body.concat("){id}");

  return body;
}