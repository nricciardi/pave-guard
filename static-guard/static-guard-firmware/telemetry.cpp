#include "telemetry.h"

String Telemetry::buildGraphqlMutationBody(char* mutationRef, String extraBody) const {

  String body("{\"query\":");
  /*body.concat("'mutation { " + mutationRef + "("));
  body.concat("deviceId: \"" + deviceId + "\",");
  body.concat("timestamp: '2024-11-08 23:44:00',");
  body.concat("latitude: " + latitude + ",");
  body.concat("longitude: " + longitude);*/
  
  if(!extraBody.isEmpty())
    body.concat(",");

  body.concat(extraBody);

  body.concat("){id}'}");

  return body;
}