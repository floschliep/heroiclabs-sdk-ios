// This script expects no payload.

// Get the current user from their session.
var session = Heroic.Request.currentSession(),
    subject = "Subject",
    body    = {},
    tags    = ["ios"],
    expiry  = 2 * 60 * 60 * 1000; // 2 hour TTL.

var promise1 = Heroic.Mailbox.send(session, subject, body, tags, expiry),
    promise2 = Heroic.Mailbox.send(session, subject, body, tags, expiry);

return Promise.all([promise1, promise2])
  .then(function (mailboxStatus) {
    var response = {
      "mailbox_full": mailboxStatus[0]
    };
    return Heroic.Response.success(response);
  })
  .catch(Heroic.Response['error']);

