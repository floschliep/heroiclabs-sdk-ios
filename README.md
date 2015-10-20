Heroic Labs iOS SDK Usage
=========================
Heroic Labs SDK for iOS.

### About
[Heroic Labs](https://heroiclabs.com/) is a scalable, reliable, and fast gaming service for game developers.

The service provides the features and functionality provided by game servers today. Our goal is to enable game developers to focus on being as creative as possible and building great games. By leveraging the Heroic Labs service you can easily add social login, gamer profiles, cloud game storage, and many other features.

For the full list of features check out our [main documentation](https://heroiclabs.com/docs/).

### Setup
The client SDK is available on [CocoaPods](http://cocoadocs.org/docsets/HeroicLabs/)

It is fully compatible with iOS 7, OS X 10.9, tvOS 9.0 and watchOS 2.0.

### Using [CocoaPods](http://cocoapods.org/)

```cocoapods
pod 'HeroicLabs'
```

### Getting Started

To interact with the Heroic Labs SDK, first you need to get an ApiKey. Get yours through our [Dashboard](http://dashboard.heroiclabs.com).

The SDK is asynchronous as it uses AFNetworking to make network calls. This means that you 'ask' for some information and some time later you'll get a callback with the desired data.

To interact with the SDK you need to instantiate a `HLClient` class and use that across your game. To instantiate:

```Objective-C
// MyGameHelper.m
#import <HLClient.h>

static NSString *const MYGAME_API_KEY = @"your-api-key";

+ (void)initialize {
    [HLClient setApiKey:MYGAME_API_KEY];
}
// other methods ...
```

#### Logging in

```Objective-C
// MyGameHelper.m
@implementation MyGameHelper
{
    HLSessionClient* session;
}


// let's imagine that this is the method invoked when the gamer taps on 'Sign in' in your game.
- (void)onLoginClick
{
    // Get or create a unique device ID
    UIDevice *device = [UIDevice currentDevice];
    NSString  *currentDeviceId = [[device identifierForVendor]UUIDString];
    // if you'd like to log the gamer in seamlessly...
    [HLClient loginAnonymouslyWith:currentDeviceId].then(^(HLSessionClient* newSession) {
        NSLog(@"Successfully logged in!");
        session = newSession;
    }).catch(^(NSError *error) {
        NSLog(@"Error: %@", error);
    });
}
// other methods ...
```

#### Heroic Labs Push

Heroic Labs Push is extremely simple to setup. Setup your game as you would to use APN and add the following line in the method override below:

```Objective-C
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)token
{
    HLSessionClient* session = ...;
    [session subscribePushWithDeviceToken:token].then(^(id data) {
        NSLog(@"Successfully setup push!");
    })
    .catch(^(NSError *error) {
        NSLog(@"Error: %@", error);
    });;
}

```

#### More Documentation

For more examples and more information on features in the Heroic Labs service have a look at our [main documentation](https://heroiclabs.com/docs/?ios).

#### Note

The iOS SDK is still in _flux_, we're looking for [feedback](mailto:hello@heroiclabs.com) from developers to make sure we're designing what you need to build incredible games. Please do get in touch and let us know what we can improve.

#### Test

Tests require a file called `local-config.plist`. This file needs to be in the same folder as the tests and should not be committed to the repo.

To run the SDK tests, execute the following command:

```
xcodebuild test -workspace HeroicLabs.xcworkspace -scheme heroiclabs-sdk-tests -destination "name=iPhone 4s"
```

or to see a pretty output

```
xcodebuild test -workspace HeroicLabs.xcworkspace -scheme heroiclabs-sdk-tests -destination "name=iPhone 4s" | xcpretty -c
```

### Contribute

All contributions to the documentation and the codebase are very welcome and feel free to open issues on the tracker wherever the documentation needs improving.

Lastly, pull requests are always welcome! `:)`
