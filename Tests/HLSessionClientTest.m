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
#import "HLHttpClient.h"
#import "HLClient.h"
#import "HLSessionClient.h"
#import "HLPing.h"
#import "HLGamer.h"
#import "HLAchievement.h"
#import "HLLeaderboard.h"
#import "HLLeaderboardRank.h"
#import "HLMatch.h"
#import "HLMatchTurn.h"

@interface HLSessionClientTest : XCTestCase
@end

@implementation HLSessionClientTest
{
    XCTestExpectation* expectation;
    void (^errorHandler)(NSError *error);
}
HLSessionClient* session;
HLMatch* match;
HLGamer* gamer;
NSInteger nextTurnNumber;
id hlapikey = @"";
id anonId = @"";
id gamerEmail = @"";
id gamerPassword = @"";
id gamerName = @"";
id gamerNickname = @"";
id storageKey = @"HeroicKey";
id storageData;
id gameAchievementId = @"ec6764eadd274b9298887de9f5da0a5e";
id gameLeaderboardId = @"5141dd1c31354741967e77f409ce755e";
id matchTurnData = @"MatchTurnData";
id productId = @"some.purchased.product.id";

+ (void)setUp {
    NSString *path = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"local-config.plist"];
    NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    hlapikey = [config valueForKey:@"apikey"];
    anonId = [config valueForKey:@"anonId2"];
    gamerEmail = [config valueForKey:@"email"];
    gamerPassword = [config valueForKey:@"password"];
    gamerName = [config valueForKey:@"name"];
    gamerNickname = [config valueForKey:@"nickname"];
    storageData = @{@"key": @"value"};
    [HLClient setApiKey:hlapikey];
    [HLClient loginWithEmail:gamerEmail andPassword:gamerPassword].then(^(id newSession) {
        session = newSession;
        NSLog(@"Gamer Token: %@", [session getGamerToken]);
    }).catch(^(NSError *error) {
        NSLog(@"Could not login. Error: %@", error);
    });
    // HACK: block all tests until we are logged in...
    expect(session).will.notTo.beNil();
}

- (void)setUp {
    [super setUp];
    expectation = [self expectationWithDescription:@"expectation"];
    __block HLSessionClientTest *blockSelf = self;
    errorHandler = ^(NSError *error) {
        [blockSelf checkError:error];
    };
}

- (void)checkError:(NSError*) error
{
    XCTAssertTrue(error == nil, @"%@", [self convertErrorToString:error]);
}

- (id)convertErrorToString:(NSError*) error
{
    id method = [[[[error userInfo] objectForKey:HLHttpErrorResponseDataKey] objectForKey:@"request"] objectForKey:@"method"];
    return [NSString stringWithFormat:@"%ld %@ ([%@] %@)", (long)[error code], [error localizedDescription], method, [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]];
}

- (void)checkPromise:(PMKPromise*)promise
           withBlock:(void(^)(id data))testBlock
      withErrorBlock:(void(^)(NSError *error))errorBlock
{
    promise.then(^(id data) {
        expect(data).toNot.beNil();
        return data;
    }).then(testBlock).catch(errorBlock).finally(^() {
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)checkPromise:(PMKPromise*)promise
      withErrorBlock:(void(^)(NSError *error))errorBlock
{
    promise.catch(errorBlock).finally(^() {
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)testPing {
    NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
    [self checkPromise:[session ping] withBlock:(^(HLPing* data) {
        expect([data time]).toNot.beLessThan(currentTimestamp);
        expect([data time]).to.beGreaterThan(currentTimestamp);
    }) withErrorBlock:errorHandler];
}

- (void)testGamerNicknameUpdate {
    [self checkPromise:[session updateGamerProfile:gamerNickname] withErrorBlock:errorHandler];
}

- (void)testGamerProfile {
    [self checkPromise:[session getGamerProfile] withBlock:(^(HLGamer* data) {
        gamer = data;
        expect([data name]).to.match(gamerName);
        expect([data nickname]).to.match(gamerNickname);
        expect([data createdAt]).to.beGreaterThan(0);
    }) withErrorBlock:errorHandler];
}

- (void)testStorage_1_Delete {
    [self checkPromise:[session deleteStoredDataWithKey:storageKey] withErrorBlock:(^(NSError *error) {
        expect([self convertErrorToString:error]).to.contain(@"404");
    })];
}

- (void)testStorage_2_Put {
    [self checkPromise:[session storeData:storageData withKey:storageKey]withErrorBlock:errorHandler];
}

- (void)testStorage_3_Get {
    [self checkPromise:[session getStoredDataWithKey:storageKey] withBlock:(^(id data) {
        expect(data).to.beSupersetOf(storageData);
    }) withErrorBlock:errorHandler];
}

- (void)testAchievement_1_UpdateOrUnlock {
    [self checkPromise:[session updateAchievementWithId:gameAchievementId withCount:[NSNumber numberWithInt:10]]withErrorBlock:errorHandler];
}

- (void)testAchievements_2_Get {
    [self checkPromise:[session getAchievements] withBlock:(^(NSArray* data) {
        expect([data count]).to.equal(1);
        HLAchievement* achievement = data[0];
        expect([achievement progressAt]).to.beGreaterThan(1442057823695);
        expect([achievement completedAt]).to.beGreaterThan(1442057823695);
        expect([achievement count]).to.beGreaterThanOrEqualTo(5);
        expect([achievement isAchievementUnlocked]).to.beTruthy();
    }) withErrorBlock:errorHandler];
}

- (void)testLeaderboard_1_Update {
    NSNumber* score = [NSNumber numberWithInt:1442260566];
    NSDictionary* scoreTags = @{@"key": @"scoretag"};
    
    [self checkPromise:[session updateRankWithId:gameLeaderboardId withScore:score andScoretags:scoreTags] withBlock:(^(HLLeaderboardRank* data) {
        expect([data score]).to.beGreaterThanOrEqualTo(score);
        expect([data scoreTags]).to.beSupersetOf(scoreTags);
    }) withErrorBlock:errorHandler];
}

- (void)testLeaderboard_2_AndRank {
    [session getLeaderboardAndRankWithId:gameLeaderboardId].then(^(HLLeaderboard* leaderboard, HLLeaderboardRank* rank) {
        expect(leaderboard).toNot.beNil();
        expect(rank).toNot.beNil();
        expect([[leaderboard entries] count]).to.beGreaterThanOrEqualTo(1);
        HLLeaderboardEntry* entry = [leaderboard entries][0];
        expect([[entry name] length]).toNot.equal(0);
        expect([entry score]).to.beGreaterThan(0);
        expect([entry scoreAt]).to.beGreaterThan(0);
    }).catch(errorHandler).finally(^() {
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)testMatch_1_Create {
    [HLClient loginAnonymouslyWith:anonId].then(^(id anonSession) {
        [anonSession createMatchFor:[NSNumber numberWithInt:2]].then(^(id data) {
            [session createMatchFor:[NSNumber numberWithInt:2]].then(^(HLMatch* newMatch) {
                match = newMatch;
            }).catch(errorHandler).finally(^() {
                [expectation fulfill];
            });
        });
    }).catch(^(NSNumber* statusCode, NSError* error) {
        [self checkError:error];
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)testMatch_2_List {
    [self checkPromise:[session getMatches] withBlock:(^(NSArray* data) {
        expect([data count]).to.beGreaterThan(0);
    }) withErrorBlock:errorHandler];
}

- (void)testMatch_3_Get {
    [self checkPromise:[session getMatchWithId:[match matchId]] withBlock:(^(HLMatch* data) {
        expect([match whoami]).to.match(gamerNickname);
        expect([match turn]).to.match(gamerNickname);
        expect([match matchId]).to.match([match matchId]);
        expect([[match gamers] count]).to.equal(2);
        expect([match createdAt]).to.beGreaterThan(0);
        expect([match active]).to.beTruthy();
    }) withErrorBlock:errorHandler];
}

- (void)testMatch_4_SubmitTurn {
    [self checkPromise:[session submitTurn:[NSNumber numberWithInt:0]
                                  withData:matchTurnData
                               toNextGamer:[gamer nickname]
                            forMatchWithId:[match matchId]]
        withErrorBlock:errorHandler];
}

- (void)testMatch_5_ListTurns {
    [self checkPromise:[session getDataForTurn:[NSNumber numberWithInteger:0] withMatchId:[match matchId]] withBlock:(^(NSArray* data) {
        expect([data count]).to.beGreaterThan(0);
        HLMatchTurn* turn = data[0];
        expect([turn type]).to.match(@"data");
        expect([turn turn_number]).to.equal(1);
        expect([turn gamer]).to.match(gamerNickname);
        expect([turn data]).to.match(matchTurnData);
        expect([turn createdAt]).to.beGreaterThan(0);
    }) withErrorBlock:errorHandler];
}

- (void)testMatch_6_End {
    [self checkPromise:[session endMatchWithId:[match matchId]] withErrorBlock:errorHandler];
}

- (void)testPushSubscription {
    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSData* badDeviceToken = [deviceId dataUsingEncoding:NSUTF8StringEncoding];
    id segments = @[@"heroiciossegment"];
    
    [self checkPromise:[session subscribePushWithDeviceToken:badDeviceToken toSegments:segments] withErrorBlock:(^(NSError *error) {
        expect([error code]).to.equal(400);
    })];
}

- (void)testPurchaseVerification {
    NSData* badPurchase = [@"bad_purchase" dataUsingEncoding:NSUTF8StringEncoding];
    
    [self checkPromise:[session verifyPurchase:badPurchase ofProduct:productId] withErrorBlock:(^(NSError *error) {
        expect([error code]).to.equal(400);
    })];
}

@end
