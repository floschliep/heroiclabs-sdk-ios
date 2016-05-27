Changelog
=========

### v0.8.2

* Add support for total leaderboard ranks.

### v0.8.1

* Add option to delete public shared storage.

### v0.8.0

* Upgrade AFNetworking to 3.1.x.
* Update PromiseKit to 1.7.0.
* Add support for tvOS.

### v0.7.2

* Fix typo in Shared Storage Search sort type.

### v0.7.1

* Change HLgzipRequestSerializer to use AFNetworking frameworks.

### v0.7.0

* Add Game Center integration.
* GZip outgoing requests. Incoming requests were already transparently gzipped.
* Removal of UIWebView dependency to get UserAgent.
* Updated Copyright info.

### v0.6.1

* Fix for badly URL encoded characters.
* Add support for WhoamIGamerId field.

### v0.6.0

* Support for direct matchmaking with gamer IDs.
* Update to AFNetworking 3.0.x

### v0.5.2

* Temporarily removed retry logic.

### v0.5.1

* Fix bug where ActiveGamers should have been an array of dictionary objects.

### v0.5.0

* Support for multi-match status update
* Additional match and match turn fields
* Deprecation of gamer nickname for matches

### v0.4.0

* Support for account linking/unlinking/checking
* Support for Tango authentication
* Support for multiple account profiles
* Support for chain multiplayer match updates
* Updated to AFN 3.0.0-beta2, PromiseKit 1.6
* Taking advantage of typed generics in XCode 7

### v0.3.1

* Add support for multiplayer match filters

### v0.3.0

* Add support for Mailboxes
* Add support for Shared Storage
* Add support for Leaderboards Scoretags
* Add support for setting Nicknames when registering.
* Removed support for iOS 6
* Updated to AFN 3.0.0-beta1
* Dropped Base64nl dependency

### v0.2.0

* Add support for Cloud Script API.
* Fix bug in retry attempts not fulfiling promise.

### v0.1.0

* Initial release.
