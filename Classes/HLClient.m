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

#import "HLClient.h"
#import "HLSessionClient.h"
#import "HLHttpClient.h"
#import "HLDefaultRequestRetryHandler.h"
#import "HLPing.h"
#import "HLServer.h"
#import "HLGame.h"
#import "HLAchievement.h"
#import "HLLeaderboard.h"
#import "HLLeaderboardRank.h"

@implementation HLClient
id<HLRequestRetryHandlerProtocol> retryHandler;
NSString* apiKey;
void (^successLoginBlock)(NSNumber* statusCode, id data, PMKResolver resolver);

+ (void)initialize
{
    retryHandler = [[HLDefaultRequestRetryHandler alloc] initWithDefaultRetryAttempts];
    successLoginBlock = ^(NSNumber* statusCode, id data, PMKResolver resolver) {
        resolver([[HLSessionClient alloc] initWithApiKey:apiKey andToken:[data objectForKey:@"token"] withRetryHandler:retryHandler]);
    };
}

+ (void)setApiKey:(NSString *)key
{
    apiKey = key;
}

+ (void)setRetryHandler:(id<HLRequestRetryHandlerProtocol>)handler
{
    retryHandler = handler;
}

+ (HLSessionClient*)restoreSession:(NSString*)gamerToken
{
    return [[HLSessionClient alloc] initWithApiKey:apiKey andToken:gamerToken withRetryHandler:retryHandler];
}

+ (PMKPromise*)ping
{
    return [HLClient sendApiRequest:@"/v0/"
                         withMethod:GET
                         withEntity:@""
                   withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                       resolver([[HLPing alloc] initWithDictionary:data]);
                   }];
}

+ (PMKPromise*)getServerInfo
{
    return [HLClient sendApiRequest:@"/v0/server/"
                         withMethod:GET
                         withEntity:@""
                   withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                       resolver([[HLServer alloc] initWithDictionary:data]);
                   }];
}

+ (PMKPromise*)getGameDetails
{
    return [HLClient sendApiRequest:@"/v0/game/"
                         withMethod:GET
                         withEntity:@""
                   withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                       resolver([[HLGame alloc] initWithDictionary:data]);
                   }];
}

+(PMKPromise*)getAchievements
{
    return [HLClient sendApiRequest:@"/v0/game/achievement/"
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

+(PMKPromise*)getLeaderboards
{
    return [HLClient sendApiRequest:@"/v0/game/leaderboard/"
                         withMethod:GET
                         withEntity:@""
                   withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                       id result = [[NSMutableArray alloc] init];
                       for (id leaderboard in [data objectForKey:@"leaderboards"]) {
                           [result addObject:[[HLLeaderboard alloc] initWithDictionary:leaderboard]];
                       }
                       resolver([[NSArray alloc] initWithArray:result]);
                   }];
}

+(PMKPromise*)getLeaderboardWithId:(NSString*)leaderboardId
{
    id endpoint = [NSString stringWithFormat:@"/v0/game/leaderboard/%@",leaderboardId];
    return [HLClient sendApiRequest:endpoint
                         withMethod:GET
                         withEntity:@""
                   withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                       resolver([[HLLeaderboard alloc] initWithDictionary:data]);
                   }];
}

+ (PMKPromise*)executeScript:(NSString*)scriptId withPayload:(id)json
{
    id endpoint = [NSString stringWithFormat:@"/v0/game/script/%@",scriptId];
    return [HLClient sendApiRequest:endpoint
                         withMethod:POST
                         withEntity:json
                   withSuccessBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                       resolver(data);
                   }];
}

+(PMKPromise*)loginAnonymouslyWith:(NSString*)deviceId
{
    id entity = @{@"id" : deviceId};
    id endpoint = [NSString stringWithFormat:@"/v0/gamer/login/%@",@"anonymous"];
    return [HLHttpClient sendAccountsRequestTo:endpoint
                                    withMethod:POST
                                        apiKey:apiKey
                                         token:@""
                                        entity:entity
                                  retryHandler:retryHandler
                                  successBlock:successLoginBlock];
}
+(PMKPromise*)loginWithFacebook:(NSString*)accessToken
{
    return [HLClient sendLoginRequest:@"facebook" withAccessToken:accessToken withSession:nil];
}
+(PMKPromise*)loginWithFacebook:(NSString*)accessToken andLink:(HLSessionClient*)session
{
    return [HLClient sendLoginRequest:@"facebook" withAccessToken:accessToken withSession:session];
}
+(PMKPromise*)loginWithGoogle:(NSString*)accessToken
{
    return [HLClient sendLoginRequest:@"google" withAccessToken:accessToken withSession:nil];
}
+(PMKPromise*)loginWithGoogle:(NSString*)accessToken andLink:(HLSessionClient*)session
{
    return [HLClient sendLoginRequest:@"google" withAccessToken:accessToken withSession:session];
}
+(PMKPromise*)sendLoginRequest:(NSString*)provider
               withAccessToken:(NSString*)accessToken
                   withSession:(HLSessionClient*)session
{
    id token = @"";
    if (session != nil) {
        token = [session getGamerToken];
    }
    
    NSDictionary* entity = @{@"type" : provider, @"access_token": accessToken};
    return [HLHttpClient sendAccountsRequestTo:@"v0/gamer/login/oauth2"
                                    withMethod:POST
                                        apiKey:apiKey
                                         token:token
                                        entity:entity
                                  retryHandler:retryHandler
                                  successBlock:successLoginBlock];
}

+(PMKPromise*)loginWithEmail:(NSString*)email andPassword:(NSString*)password
{
    return [HLClient loginWithEmail:email andPassword:password andLink:nil];
}
+(PMKPromise*)loginWithEmail:(NSString*)email andPassword:(NSString*)password andLink:(HLSessionClient*)session
{
    id entity = @{@"email" : email, @"password" : password};
    id token = @"";
    if (session != nil) {
        token = [session getGamerToken];
    }
    
    id endpoint = [NSString stringWithFormat:@"/v0/gamer/login/%@",@"gameup"];
    return [HLHttpClient sendAccountsRequestTo:endpoint
                                    withMethod:POST
                                        apiKey:apiKey
                                         token:token
                                        entity:entity
                                  retryHandler:retryHandler
                                  successBlock:successLoginBlock];
}

+(PMKPromise*)createAccountWithEmail:(NSString*)email andPassword:(NSString*)password andConfirm:(NSString*)passwordConfirmation
{
    return [HLClient createAccountWithEmail:email andPassword:password andConfirm:passwordConfirmation andName:nil];
}
+(PMKPromise*)createAccountWithEmail:(NSString*)email andPassword:(NSString*)password andConfirm:(NSString*)passwordConfirmation andName:(NSString*)name
{
    return [HLClient createAccountWithEmail:email andPassword:password andConfirm:passwordConfirmation andName:nil andLink:nil];
}
+(PMKPromise*)createAccountWithEmail:(NSString*)email andPassword:(NSString*)password andConfirm:(NSString*)passwordConfirmation andName:(NSString*)name andLink:(HLSessionClient*)session
{
    id entity = @{@"email" : email,
                  @"password" : password,
                  @"confirm_password" : passwordConfirmation};
    
    if (name != nil) {
        entity = [[NSMutableDictionary alloc] initWithDictionary:entity];
        [entity setObject:name forKey:@"name"];
    }
    
    id token = @"";
    if (session != nil) {
        token = [session getGamerToken];
    }
    
    return [HLHttpClient sendAccountsRequestTo:@"/v0/gamer/account/gameup/create"
                                    withMethod:POST
                                        apiKey:apiKey
                                         token:token
                                        entity:entity
                                  retryHandler:retryHandler
                                  successBlock:successLoginBlock];
}

+(PMKPromise*)sendLoginReset:(NSString*)email
{
    id entity = @{@"email" : email};
    return [HLHttpClient sendAccountsRequestTo:@"/v0/gamer/account/gameup/reset/send"
                                    withMethod:POST
                                        apiKey:apiKey
                                         token:@""
                                        entity:entity
                                  retryHandler:retryHandler
                                  successBlock:successLoginBlock];
}

+(PMKPromise*)sendApiRequest:(NSString*)endpoint
                  withMethod:(enum HLRequestMethod)method
                  withEntity:(id)entity
            withSuccessBlock:(void(^)(NSNumber* statusCode, id data, PMKResolver resolver))successCallback
{
    return [HLHttpClient sendApiRequestTo:endpoint
                               withMethod:method
                                   apiKey:apiKey
                                    token:@""
                                   entity:entity
                             retryHandler:retryHandler
                             successBlock:successCallback];
}
@end
