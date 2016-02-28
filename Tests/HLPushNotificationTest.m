/*
 Copyright 2015-2016 Heroic Labs
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <UIKit/UIKit.h>
#import "HLClient.h"
#import "HLSessionClient.h"

@interface HLPushNotificationTest : NSObject 
@end

@implementation HLPushNotificationTest
{
    HLSessionClient* sessionClient;
}

- (void)setupPushNotificationWithAPNS
{
    Class uiUserNotificationSettings = NSClassFromString(@"UIUserNotificationSettings");
    [[UIApplication sharedApplication] registerUserNotificationSettings:[uiUserNotificationSettings settingsForTypes:7 categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication* )application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)token
{
    [sessionClient subscribePushWithDeviceToken:token toSegments:@[]].then(^{
        NSLog(@"Registered device with Heroic Labs");
    })
    .catch(^(NSError *error) {
        NSLog(@"Could not register device with Heroic Labs: %@", error);
    });
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Error registering for Apple push notifications. Error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)data
{
    NSString* body = [[data objectForKey:@"aps"] objectForKey:@"alert"];
    NSMutableString* message = [NSMutableString stringWithString:body];
    [message appendString:@": "];
    NSDictionary* custom = [data objectForKey:@"custom"];
    NSDictionary* a = [custom objectForKey:@"a"];
    if (a != nil) {
        for (NSString* key in a) {
            [message appendString:key];
            [message appendString:@"="];
            [message appendString:[a objectForKey:key]];
        }
    }
    
    if (application.applicationState == UIApplicationStateActive ) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.userInfo = data;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.alertBody = message;
        localNotification.fireDate = [NSDate date];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Push Notification"
                                  message:message
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        
        [alertView show];
    }
}

@end
