/*
 Copyright 2014-2015 Heroic Labs
 
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
#import <XCTest/XCTest.h>
#import <Expecta/Expecta.h>
#import "HLClient.h"
#import "HLSessionClient.h"
#import "HLHttpClient.h"

@interface HLMultiplayerSampleTest : XCTestCase
@end

@implementation HLMultiplayerSampleTest
{
    void (^failure)(NSError *error);
    id anonymousId1;
    id anonymousId2;
    HLSessionClient* session1;
    HLSessionClient* session2;
    HLGamer* gamer1;
    HLGamer* gamer2;
    id filters;
    id mostRecentUpdatedMatch;
}

- (void)startMultiplayerTest {
    failure = ^(NSError *error) {
        NSDictionary* json = [[error userInfo] objectForKey:HLHttpErrorResponseDataKey];
        NSLog(@"%@",[NSString stringWithFormat:@"%@ %@: %@ %@", [json objectForKey:@"status"], [json objectForKey:@"message"], [[json objectForKey:@"request"] objectForKey:@"method"], [[error userInfo] objectForKey:@"NSErrorFailingURLKey"]]);
    };
    
    NSString *path = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"local-config.plist"];
    NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:path];

    anonymousId1 = [config valueForKey:@"anonId"];
    anonymousId2 = [config valueForKey:@"anonId2"];
    filters = @[@"device=ios", @"player=tag"];
    
    [HLClient setApiKey:[config valueForKey:@"apikey"]];
    
    [HLClient loginAnonymouslyWith:anonymousId1].then(^(HLSessionClient* session) {
        session1 = session;
        return [HLClient loginAnonymouslyWith:anonymousId2];
    }).then(^(HLSessionClient* session) {
        session2 = session;
        return [session1 getGamerProfile];
    }).then(^(HLGamer* gamer) {
        gamer1 = gamer;
        return [session2 getGamerProfile];
    }).then(^(HLGamer* gamer) {
        gamer2 = gamer;
        [self startMultiplayerMatch];
    }).then(failure);
}

- (void)startMultiplayerMatch {
    // we are assuming that you've never had a multiplayer match
    // to get the list of matches you have, please refer to
    // [HLSessionClient getMatches]
    
    [session1 createMatchFor:@2 withFilters:filters].then(^(HLMatch* match){
        if ([match matchId] != nil) {
            // for the purposes of this sample,
            // we are going to assume that you are going to be queued,s
            // have a look below for how to handle the situation for when you are not queued
            // see submitTurnForMatch:forGamer:withSession
        } else {
            // start polling for updates for gamer1
            // to see when gamer1 will have an active match
            [self startPollingForMatchUpdatesForSession:session1];
        }
        return [session2 createMatchFor:@2 withFilters:filters];
    }).then(^(HLMatch* match){
        // now gamer1 and gamer2 have been matched...
        // let's submit the turn for gamer2, since he is the turn taker
        
        id someData = @"some-multiplayer-data";
        [session2 submitTurn:@0 withData:someData toNextGamerId:[gamer1 gamerId] forMatchWithId:[match matchId]].then(^{
            // now that gamer1 is the turn taker, let's end the match
            [session1 endMatchWithId:[match matchId]].catch(failure);
        }).catch(failure);
    }).catch(failure);
}

- (void)startPollingForMatchUpdatesForSession:(HLSessionClient*)session {
    // this method should be invoked for all your matches
    // you should cache the data that you get back
    // please assume that this method is running in a timer,
    // to periodically update all match and turn data
    
    id timestamp = @0; // if 0, then all match data is returned to you
    if (mostRecentUpdatedMatch != nil) {
        timestamp = [mostRecentUpdatedMatch updatedAt];
    }
    
    // this will give you any new match data since the timestamp provided
    // it will include new turn data for all the matches too
    [session getChangedMatchesSince:timestamp].then(^(NSArray<HLMatchChange*>* matchChanges) {
        // display changes, update your cache,
        // as well as find the most updated match and set the mostRecentUpdatedMatch to that match
        
        for (HLMatchChange* matchChange in matchChanges) {
            // note that non-active matches could appear here too
            if ([[matchChange match] active]) {
                [self updateMostRecentUpdatedMatch:[matchChange match]];
            }
        }
    }).then(failure);
}

- (void) updateMostRecentUpdatedMatch:(HLMatch*)match {
    if (mostRecentUpdatedMatch == nil || [mostRecentUpdatedMatch updatedAt] < [match updatedAt]) {
        mostRecentUpdatedMatch = match;
    }
}

@end