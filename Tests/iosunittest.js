// This script expects the payload in the following format:
// {
//   "a": 1,
//   "b": 2
// }

var payload = Heroic.Request.body(),
    session = Heroic.Request.currentSession();

if (session === null) {
  return Heroic.Response.error(401, "Script must be called with a user session.");
}

// Deep clone the payload object.
var responsePayload = JSON.parse(JSON.stringify(payload));

// Swap values for test assertions.
responsePayload.a = responsePayload.a + responsePayload.b;
responsePayload.b = responsePayload.a - responsePayload.b;
responsePayload.a = responsePayload.a - responsePayload.b;

// Return 200 with payload.
return Heroic.Response.success(responsePayload);
