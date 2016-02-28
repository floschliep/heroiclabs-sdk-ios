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

#import "HLSessionClient.h"
#import "HLHttpClient.h"

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
                     withEntity:nil
               withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                   resolver([[HLPing alloc] initWithDictionary:data]);
               }];
}

- (PMKPromise*)getGamerProfile
{
    return [HLHttpClient sendAccountsRequestTo:@"/v0/gamer/"
                                    withMethod:GET
                                        apiKey:apiKey
                                         token:token
                                        entity:nil
                                  retryHandler:retryHandler
                                  successBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
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
                     withEntity:nil
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
                     withEntity:nil];
}

-(PMKPromise*)getAchievements
{
    return [self sendApiRequest:@"/v0/gamer/achievement/"
                     withMethod:GET
                     withEntity:nil
               withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                   NSMutableArray* result = [[NSMutableArray alloc] init];
                   
                   NSArray* achievements = [data objectForKey:@"achievements"];
                   for (id jsonAchievement in achievements) {
                       HLAchievement* achievement = [[HLAchievement alloc] initWithDictionary:jsonAchievement];
                       [result addObject:achievement];
                   }
                   resolver([NSArray arrayWithArray:result]);
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
                     withEntity:nil
               withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                   resolver(PMKManifold(
                                        [[HLLeaderboard alloc] initWithDictionary:[data objectForKey:@"leaderboard"]],
                                        [[HLLeaderboardRank alloc] initWithDictionary:[data objectForKey:@"rank"]])
                            );
               }];
}

-(PMKPromise*)getLeaderboardAndRankWithId:(NSString*)leaderboardId
                                    limit:(NSNumber*)limit
                                   offset:(NSNumber*)offset
                       includingScoretags:(BOOL)withScoretags
{
    NSString * booleanString = (withScoretags) ? @"true" : @"false";
    NSString * autoOffset = (offset < 0) ? @"true" : @"false";
    
    id query = [[NSString stringWithFormat:@"offset=%@&limit=%@&auto_offset=%@&with_scoretags=%@",offset, limit, autoOffset, booleanString] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    
    id endpoint = [NSString stringWithFormat:@"/v0/gamer/leaderboard/%@/?%@", leaderboardId, query];
    return [self sendApiRequest:endpoint
                     withMethod:GET
                     withEntity:nil
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

-(PMKPromise*)updateRankWithId:(NSString*)leaderboardId withScore:(NSNumber*)score andScoretags:(NSDictionary*)scoretags
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
                     withEntity:nil
               withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                   id result = [[NSMutableArray alloc] init];
                   for (id turn in [data objectForKey:@"matches"]) {
                       [result addObject:[[HLMatch alloc] initWithDictionary:turn]];
                   }
                   resolver([NSArray arrayWithArray:result]);
               }];
}

-(PMKPromise*)getChangedMatchesSince:(NSNumber*)timestamp
{
    id query = [[NSString stringWithFormat:@"since=%@",timestamp] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    id endpoint = [NSString stringWithFormat:@"/v0/gamer/matches/?%@", query];
    return [self sendApiRequest:endpoint
                     withMethod:GET
                     withEntity:nil
               withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                   id result = [[NSMutableArray alloc] init];
                   for (id matchChanges in [data objectForKey:@"matches"]) {
                       [result addObject:[[HLMatchChange alloc] initWithDictionary:matchChanges]];
                   }
                   resolver([NSArray arrayWithArray:result]);
               }];
}

-(PMKPromise*)getMatchWithId:(NSString*) matchId
{
    id endpoint = [NSString stringWithFormat:@"/v0/gamer/match/%@",matchId];
    return [self sendApiRequest:endpoint
                     withMethod:GET
                     withEntity:nil
               withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                   resolver([[HLMatch alloc] initWithDictionary:data]);
               }];
}

-(PMKPromise*)getDataForTurn:(NSNumber*)turnNumber withMatchId:(NSString*) matchId
{
    id endpoint = [NSString stringWithFormat:@"/v0/gamer/match/%@/turn/%@", matchId, [turnNumber stringValue]];
    return [self sendApiRequest:endpoint
                     withMethod:GET
                     withEntity:nil
               withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                   id result = [[NSMutableArray alloc] init];
                   for (id turn in [data objectForKey:@"turns"]) {
                       [result addObject:[[HLMatchTurn alloc] initWithDictionary:turn]];
                   }
                   resolver([NSArray arrayWithArray:result]);
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

-(PMKPromise*)submitTurn:(NSNumber*)turn
                withData:(NSString*)data
           toNextGamerId:(NSString*)nextGamerId
          forMatchWithId:(NSString*)matchId
{
    id endpoint = [NSString stringWithFormat:@"/v0/gamer/match/%@/turn/", matchId];
    id submission = @{@"last_turn": turn,
                      @"next_gamer_id": nextGamerId,
                      @"data": data};
    
    return [self sendApiRequest:endpoint
                     withMethod:POST
                     withEntity:submission];
}

-(PMKPromise*)createMatchWithGamers:(NSArray<NSString*>*)gamers
{
    return [self createMatchWithGamers:gamers filters:nil];
}

-(PMKPromise*)createMatchWithGamers:(NSArray<NSString*>*)gamers filters:(NSArray*)matchFilters
{
    id entity = @{@"gamers": gamers};
    if (matchFilters != nil) {
        entity = @{@"gamers": gamers, @"filters": matchFilters};
    }
    return [self sendApiRequest:@"/v0/gamer/match/"
                     withMethod:PUT
                     withEntity:entity
               withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                   resolver([[HLMatch alloc] initWithDictionary:data]);
               }];
}

-(PMKPromise*)createMatchFor:(NSNumber*)requiredGamers
{
    return [self createMatchFor:requiredGamers withFilters:nil];
}

-(PMKPromise*)createMatchFor:(NSNumber*)requiredGamers withFilters:(NSArray*)matchFilters;
{
    id entity = @{@"players": requiredGamers};
    if (matchFilters != nil) {
        entity = @{@"players": requiredGamers, @"filters": matchFilters};
    }
    return [self sendApiRequest:@"/v0/gamer/match/"
                     withMethod:POST
                     withEntity:entity
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
    NSString* receiptString = [receipt base64EncodedStringWithOptions:0];
    
    return [self sendApiRequest:@"/v0/gamer/purchase/verify/apple/"
                     withMethod:POST
                     withEntity:@{@"receipt_data": receiptString, @"product_id": productId}
               withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                   resolver([[HLPurchaseVerification alloc] initWithDictionary:data]);
               }];
}

- (PMKPromise*)executeScript:(NSString*)scriptId withPayload:(id)json
{
    id endpoint = [NSString stringWithFormat:@"/v0/game/script/%@",scriptId];
    return [self sendApiRequest:endpoint
                     withMethod:POST
                     withEntity:json
               withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                   resolver(data);
               }];
}

- (PMKPromise*)getMessagesWithBody:(BOOL)body
{
    return [self getMessagesWithBody:body newerSince:[NSNumber numberWithInt:0]];
    
}
- (PMKPromise*)getMessagesWithBody:(BOOL)body newerSince:(NSNumber*)utcMilliTimestamp
{
    NSString * booleanString = (body) ? @"true" : @"false";
    
    id query = [[NSString stringWithFormat:@"with_body=%@&since=%@", booleanString, utcMilliTimestamp] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    
    id endpoint = [NSString stringWithFormat:@"/v0/gamer/message/?%@", query];
    return [self sendApiRequest:endpoint
                     withMethod:GET
                     withEntity:nil
               withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                   id result = [[NSMutableArray alloc] init];
                   for (id message in [data objectForKey:@"messages"]) {
                       [result addObject:[[HLMessage alloc] initWithDictionary:message]];
                   }
                   resolver([NSArray arrayWithArray:result]);

               }];
}

- (PMKPromise*)getMessageWithId:(NSString*)messageId withBody:(BOOL)body
{
    NSString * booleanString = (body) ? @"true" : @"false";
    
    id query = [[NSString stringWithFormat:@"with_body=%@", booleanString] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    
    id endpoint = [NSString stringWithFormat:@"/v0/gamer/message/%@/?%@", messageId, query];
    return [self sendApiRequest:endpoint
                     withMethod:GET
                     withEntity:nil
               withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                   resolver([[HLMessage alloc] initWithDictionary:data]);
               }];
}

- (PMKPromise*)deleteMessageWithId:(NSString*)messageId
{
    id endpoint = [NSString stringWithFormat:@"/v0/gamer/message/%@", messageId];
    return [self sendApiRequest:endpoint
                     withMethod:DELETE
                     withEntity:nil
               withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                   resolver(data);
               }];
}


- (PMKPromise*)searchSharedStorageWithQuery:(NSString*)luceneQuery
{
    return [self searchSharedStorageWithQuery:luceneQuery andFilter:nil sort:nil limit:@10 offset:@0];
}

- (PMKPromise*)searchSharedStorageWithQuery:(NSString*)luceneQuery andFilter:(NSString*)key
{
    return [self searchSharedStorageWithQuery:luceneQuery andFilter:key sort:nil limit:@10 offset:@0];
}

- (PMKPromise*)searchSharedStorageWithQuery:(NSString*)luceneQuery andFilter:(NSString*)key sort:(NSNumber*)sortKey
{
    return [self searchSharedStorageWithQuery:luceneQuery andFilter:key sort:sortKey limit:@10 offset:@0];
}

- (PMKPromise*)searchSharedStorageWithQuery:(NSString*)luceneQuery andFilter:(NSString*)key sort:(NSNumber*)sortKey limit:(NSNumber*)limit
{
    return [self searchSharedStorageWithQuery:luceneQuery andFilter:key sort:sortKey limit:limit offset:@0];
}

- (PMKPromise*)searchSharedStorageWithQuery:(NSString*)luceneQuery andFilter:(NSString*)key sort:(NSNumber*)sortKey limit:(NSNumber*)limit offset:(NSNumber*)offset
{
    
    id optionalParams = [NSMutableString stringWithString:@""];
    if (key) {
        [optionalParams appendFormat:@"filter_key=%@", key];
    }
    if (key && sortKey) {
        [optionalParams appendString:@"&"];
    }
    if (sortKey) {
        [optionalParams appendFormat:@"sort=%@", sortKey];
    }
    
    id query = [NSString stringWithFormat:@"query=%@&limit=%@&offset=%@&%@", luceneQuery, limit, offset, optionalParams];
    
    NSLog(@"query: %@", query);

    id endpoint = [NSString stringWithFormat:@"/v0/gamer/shared/?%@", query];
    return [self sendApiRequest:endpoint
                     withMethod:GET
                     withEntity:nil
               withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                   resolver([[HLSharedStorageSearchResults alloc] initWithDictionary:data]);
               }];
}

- (PMKPromise*)getSharedDataWithKey:(NSString*)key
{
    id endpoint = [NSString stringWithFormat:@"/v0/gamer/shared/%@", key];
    return [self sendApiRequest:endpoint
                     withMethod:GET
                     withEntity:nil
               withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                   resolver([[HLSharedStorageObject alloc] initWithDictionary:data]);
               }];
}

- (PMKPromise*)storeSharedData:(NSDictionary*)data withKey:(NSString*)key
{
    id endpoint = [NSString stringWithFormat:@"/v0/gamer/shared/%@/public", key];
    return [self sendApiRequest:endpoint
                     withMethod:PUT
                     withEntity:data
               withSuccessBlock:^(NSNumber* statusCode, id result, PMKResolver resolver) {
                   resolver(result);
               }];
}

- (PMKPromise*)partialUpdateSharedData:(NSDictionary*)data withKey:(NSString*)key
{
    id endpoint = [NSString stringWithFormat:@"/v0/gamer/shared/%@/public", key];
    return [self sendApiRequest:endpoint
                     withMethod:PATCH
                     withEntity:data
               withSuccessBlock:^(NSNumber* statusCode, id result, PMKResolver resolver) {
                   resolver(result);
               }];
}

@end