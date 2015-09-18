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

#import <Base64nl/Base64.h>
#import "HLSessionClient.h"
#import "HLHttpClient.h"
#import "HLRequestRetryHandlerProtocol.h"
#import "HLPing.h"
#import "HLServer.h"
#import "HLGame.h"
#import "HLGamer.h"
#import "HLAchievement.h"
#import "HLLeaderboard.h"
#import "HLLeaderboardRank.h"
#import "HLMatch.h"
#import "HLMatchTurn.h"
#import "HLPurchaseVerification.h"

@implementation HLSessionClient
{
    id<HLRequestRetryHandlerProtocol> retryHandler;
    NSString* apiKey;
    NSString* token;
}

- (id)initWithApiKey:(id)apikeyToUse
            andToken:(id)tokenToUse
    withRetryHandler:(id<HLRequestRetryHandlerProtocol>)handler
{
    self = [super init];
    if (self) {
        apiKey = apikeyToUse;
        token = tokenToUse;
        retryHandler = handler;
    }
    return self;
}

- (id)getGamerToken
{
    return token;
}

- (PMKPromise*)sendApiRequest:(NSString*)endpoint
                   withMethod:(enum HLRequestMethod)method
                   withEntity:(id)entity
{
    return [HLHttpClient sendApiRequestTo:endpoint
                               withMethod:method
                               apiKey:apiKey
                                token:token
                               entity:entity
                         retryHandler:retryHandler];
}

- (PMKPromise*)sendApiRequest:(NSString*)endpoint
                   withMethod:(enum HLRequestMethod)method
                   withEntity:(id)entity
             withSuccessBlock:(void(^)(NSNumber* statusCode, id data, PMKResolver resolver))successCallback
{
    return [HLHttpClient sendApiRequestTo:endpoint
                               withMethod:method
                               apiKey:apiKey
                                token:token
                               entity:entity
                         retryHandler:retryHandler
                         successBlock:successCallback];
}

- (PMKPromise*)ping
{
    return [self sendApiRequest:@"/v0/"
                     withMethod:GET
                     withEntity:@""
               withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                   resolver([[HLPing alloc] initWithDictionary:data]);
               }];
}

- (PMKPromise*)getGamerProfile
{
    return [self sendApiRequest:@"/v0/gamer/"
                     withMethod:GET
                     withEntity:@""
               withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                   resolver([[HLGamer alloc] initWithDictionary:data]);
               }];
}

-(PMKPromise*)updateGamerProfile:(NSString*)nickname
{
    id entity = @{@"nickname" : nickname};
    return [HLHttpClient sendAccountsRequestTo:@"/v0/gamer/"
                                    withMethod:POST
                                    apiKey:apiKey
                                     token:token
                                    entity:entity
                              retryHandler:retryHandler
                              successBlock:nil];
}

- (PMKPromise*)getStoredDataWithKey:(NSString*)key
{
    id endpoint = [NSString stringWithFormat:@"/v0/gamer/storage/%@",key];
    return [self sendApiRequest:endpoint
                     withMethod:GET
                     withEntity:@""
               withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                   NSString* jsonString = [data objectForKey:@"value"];
                   NSData *encData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                   
                   resolver([NSJSONSerialization JSONObjectWithData:encData options:0 error:nil]);
               }];
}

- (PMKPromise*)storeData:(NSDictionary*)value withKey:(NSString*)storageKey
{
    id endpoint = [NSString stringWithFormat:@"/v0/gamer/storage/%@",storageKey];
    return [self sendApiRequest:endpoint
                     withMethod:PUT
                     withEntity:value];
}

- (PMKPromise*)deleteStoredDataWithKey:(NSString*)key
{
    id endpoint = [NSString stringWithFormat:@"/v0/gamer/storage/%@",key];
    return [self sendApiRequest:endpoint
                     withMethod:DELETE
                     withEntity:@""];
}

-(PMKPromise*)getAchievements
{
    return [self sendApiRequest:@"/v0/gamer/achievement/"
                     withMethod:GET
                     withEntity:@""
               withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                   NSMutableArray* result = [[NSMutableArray alloc] init];
                   
                   NSArray* achievements = [data objectForKey:@"achievements"];
                   for (id jsonAchievement in achievements) {
                       HLAchievement* achievement = [[HLAchievement alloc] initWithDictionary:jsonAchievement];
                       [result addObject:achievement];
                   }
                   resolver([[NSArray alloc] initWithArray:result]);
               }];
}

-(PMKPromise*)unlockAchievementWithId:(NSString*)achievementId
{
    return [self updateAchievementWithId:achievementId withCount:[NSNumber numberWithInt:1]];
}

-(PMKPromise*)updateAchievementWithId:(NSString*)achievementId withCount:(NSNumber*)count
{
    id endpoint = [NSString stringWithFormat:@"/v0/gamer/achievement/%@",achievementId];
    return [self sendApiRequest:endpoint
                     withMethod:POST
                     withEntity:@{@"count": count}
               withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                   if ([statusCode intValue] == 200) {
                       resolver([[HLAchievement alloc] initWithDictionary:data]);
                   } else {
                       resolver(data);
                   }
               }];
}

-(PMKPromise*)getLeaderboardAndRankWithId:(id)leaderboardId
{
    id endpoint = [NSString stringWithFormat:@"/v0/gamer/leaderboard/%@",leaderboardId];
    return [self sendApiRequest:endpoint
                     withMethod:GET
                     withEntity:@""
               withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                   resolver(PMKManifold(
                                        [[HLLeaderboard alloc] initWithDictionary:[data objectForKey:@"leaderboard"]],
                                        [[HLLeaderboardRank alloc] initWithDictionary:[data objectForKey:@"rank"]])
                            );
               }];
}

-(PMKPromise*)updateRankWithId:(NSString*)leaderboardId withScore:(NSNumber*)score
{
    id endpoint = [NSString stringWithFormat:@"/v0/gamer/leaderboard/%@",leaderboardId];
    return [self sendApiRequest:endpoint
                     withMethod:POST
                     withEntity:@{@"score":score}
               withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                   resolver([[HLLeaderboardRank alloc] initWithDictionary:data]);
               }];
}

-(PMKPromise*)updateRankWithId:(NSString*)leaderboardId withScore:(NSNumber*) score andScoretags:(NSDictionary*)scoretags
{
    id endpoint = [NSString stringWithFormat:@"/v0/gamer/leaderboard/%@",leaderboardId];
    id update = @{@"score": score,
                  @"scoretags": scoretags};
    return [self sendApiRequest:endpoint
                     withMethod:POST
                     withEntity:update
               withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                   resolver([[HLLeaderboardRank alloc] initWithDictionary:data]);
               }];
}

-(PMKPromise*)getMatches
{
    return [self sendApiRequest:@"/v0/gamer/match/"
                     withMethod:GET
                     withEntity:@""
               withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                   id result = [[NSMutableArray alloc] init];
                   for (id turn in [data objectForKey:@"matches"]) {
                       [result addObject:[[HLMatch alloc] initWithDictionary:turn]];
                   }
                   resolver(result);
               }];
}
-(PMKPromise*)getMatchWithId:(NSString*) matchId
{
    id endpoint = [NSString stringWithFormat:@"/v0/gamer/match/%@",matchId];
    return [self sendApiRequest:endpoint
                     withMethod:GET
                     withEntity:@""
               withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                   resolver([[HLMatch alloc] initWithDictionary:data]);
               }];
}
-(PMKPromise*)getDataForTurn:(NSNumber*)turnNumber withMatchId:(NSString*) matchId
{
    id endpoint = [NSString stringWithFormat:@"/v0/gamer/match/%@/turn/%@", matchId, [turnNumber stringValue]];
    return [self sendApiRequest:endpoint
                     withMethod:GET
                     withEntity:@""
               withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                   id result = [[NSMutableArray alloc] init];
                   for (id turn in [data objectForKey:@"turns"]) {
                       [result addObject:[[HLMatchTurn alloc] initWithDictionary:turn]];
                   }
                   resolver(result);
               }];
}
-(PMKPromise*)submitTurn:(NSNumber*)turn
                withData:(NSString*)data
             toNextGamer:(NSString*)nextGamerNickname
          forMatchWithId:(NSString*)matchId
{
    id endpoint = [NSString stringWithFormat:@"/v0/gamer/match/%@/turn/", matchId];
    id submission = @{@"last_turn": turn,
                      @"next_gamer": nextGamerNickname,
                      @"data": data};
    
    return [self sendApiRequest:endpoint
                     withMethod:POST
                     withEntity:submission];
}

-(PMKPromise*)createMatchFor:(NSNumber*)requiredGamers
{
    return [self sendApiRequest:@"/v0/gamer/match/"
                     withMethod:POST
                     withEntity:@{@"players": requiredGamers}
               withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                   resolver([[HLMatch alloc] initWithDictionary:data]);
               }];
}

-(PMKPromise*)endMatchWithId:(NSString*)matchId
{
    id endpoint = [NSString stringWithFormat:@"/v0/gamer/match/%@", matchId];
    return [self sendApiRequest:endpoint
                     withMethod:POST
                     withEntity:@{@"action": @"end"}];
}

-(PMKPromise*)leaveMatchWithId:(NSString*)matchId
{
    id endpoint = [NSString stringWithFormat:@"/v0/gamer/match/%@", matchId];
    return [self sendApiRequest:endpoint
                     withMethod:POST
                     withEntity:@{@"action": @"leave"}];
}

- (PMKPromise*)subscribePushWithDeviceToken:(NSData*)inDeviceToken toSegments:(NSArray*)segments
{
    NSString* trimmedDeviceToken = [[inDeviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    NSString* parsedDeviceToken = [[trimmedDeviceToken componentsSeparatedByString:@" "] componentsJoinedByString:@""];
    NSLog(@"didRegisterForRemoteNotifications device token %@", parsedDeviceToken);
    
    id payload = @{
                   @"platform":@"ios",
                   @"id":[[NSString alloc] initWithString:parsedDeviceToken],
                   @"multiplayer": @NO,
                   @"segments":segments
                   };
    
    return [HLHttpClient sendApiRequestTo:@"/v0/gamer/push/"
                               withMethod:PUT
                               apiKey:apiKey
                                token:token
                               entity:payload
                         retryHandler:retryHandler];
}

- (PMKPromise*)verifyPurchase:(NSData*)receipt ofProduct:(NSString*)productId
{
    NSString* receiptString = [[[NSString alloc] initWithData:receipt encoding:NSUTF8StringEncoding] base64EncodedString];
    
    return [self sendApiRequest:@"/v0/gamer/purchase/verify/apple/"
                     withMethod:POST
                     withEntity:@{@"receipt_data": receiptString, @"product_id": productId}
               withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                   resolver([[HLPurchaseVerification alloc] initWithDictionary:data]);
               }];
}

@end