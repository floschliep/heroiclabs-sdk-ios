Heroic Labs iOS SDK
===================
The iOS SDK for the Heroic Labs service.

[SDK Guide](https://heroiclabs.com/docs/guide/ios/) | [SDK Reference](http://cocoadocs.org/docsets/HeroicLabs/0.6.0/)

---

Heroic Labs is AWS for game developers. Easily add social, multiplayer, and competitive features to any kind of game. The platform handles all server infrastructure required to power games built for desktop, mobile, browser, or web. The goal is to help game studios build beautiful social and multiplayer games which work at massive scale.

For a full list of the API have a look at the [features](https://heroiclabs.com/features).

### Install
The client SDK is available on [CocoaPods](http://cocoadocs.org/docsets/HeroicLabs/)

It is fully compatible with iOS 7, OS X 10.9, tvOS 9.0 and watchOS 2.0.

Simply add this to your `Podfile`:

```cocoapods
pod 'HeroicLabs'
```

Once the SDK is installed, import `<HeroicLabs/HLClient.h>` into your Objective-C code and Copy and paste this code in your file:

```objc
[HLClient setApiKey:@"1fb234d5678948199cb858ab0905f657"];

[HLClient ping].then(^ {
    NSLog(@"Ping was successful.");
}).catch(^(NSError* error) {
    NSLog(@"Could not connect to the API %@", [error description]);
});
```

The API key shown above __must be replaced__ with one of your own from the [Developer Dashboard](https://dashboard.heroiclabs.com/). Run your game. A request will be sent to the Game API which will verify your API key is valid and the service is reachable.

### SDK Guide

You can find the full guide for the iOS SDK [online](https://heroiclabs.com/docs/guide/ios/).

### Contribute

To develop on the codebase you'll need:

* [Xcode](https://developer.apple.com/xcode) The Xcode Editor.
* [CocoaPods](http://cocoapods.org) Objective-C/Swift Dependency Manager

#### Setup

1. Open terminal, navigate to the root folder of the project and execute `pod install`.
2. Open Xcode and choose to open an existing project - choose `HeroicLabs.xcworkspace` file.
3. Once open, set the active scheme to `heroiclabs-sdk`.
4. Click on the `Product` menu bar, and then `Build`.

All contributions to the documentation and the codebase are very welcome and feel free to open issues on the tracker wherever the documentation needs enhancements.

Pull requests are always welcome! `:)`

#### Test

Tests require a file called `local-config.plist`. This file needs to be in the same folder as the tests and should not be committed to the repo.

To run the SDK tests, execute the following command:

```
xcodebuild test -workspace HeroicLabs.xcworkspace -scheme heroiclabs-sdk-tests -destination "name=iPhone 4s"
```

or to see a pretty output:

```
xcodebuild test -workspace HeroicLabs.xcworkspace -scheme heroiclabs-sdk-tests -destination "name=iPhone 4s" | xcpretty -c
```
