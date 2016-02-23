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

#import "HLClient.h"
#import "HLHttpClient.h"

@implementation HLClient
id<HLRequestRetryHandlerProtocol> retryHandler;
NSString* apiKey;
void (^successLoginBlock)(NSNumber* statusCode, id data, PMKResolver resolver);
void (^successCheckBlock)(NSNumber* statusCode, id data, PMKResolver resolver);

+ (void)initialize
{
    retryHandler = [[HLDefaultRequestRetryHandler alloc] initWithDefaultRetryAttempts];
    successLoginBlock = ^(NSNumber* statusCode, id data, PMKResolver resolver) {
        resolver([[HLSessionClient alloc] initWithApiKey:apiKey andToken:[data objectForKey:@"token"] withRetryHandler:retryHandler]);
    };
    successCheckBlock = ^(NSNumber* statusCode, id data, PMKResolver resolver) {
        resolver(PMKManifold(
                             [data objectForKey:@"exists"],
                             [data objectForKey:@"current_gamer"])
                 );
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
                         entity:nil
                   successBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                       resolver([[HLPing alloc] initWithDictionary:data]);
                   }];
}

+ (PMKPromise*)getServerInfo
{
    return [HLClient sendApiRequest:@"/v0/server/"
                         withMethod:GET
                         entity:nil
                   successBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                       resolver([[HLServer alloc] initWithDictionary:data]);
                   }];
}

+ (PMKPromise*)getGameDetails
{
    return [HLClient sendApiRequest:@"/v0/game/"
                         withMethod:GET
                         entity:nil
                   successBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                       resolver([[HLGame alloc] initWithDictionary:data]);
                   }];
}

+(PMKPromise*)getAchievements
{
    return [HLClient sendApiRequest:@"/v0/game/achievement/"
                         withMethod:GET
                         entity:nil
                   successBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
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
                         entity:nil
                   successBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
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
                         entity:nil
                   successBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                       resolver([[HLLeaderboard alloc] initWithDictionary:data]);
                   }];
}

+(PMKPromise*)getLeaderboardWithId:(NSString*)leaderboardId
                             limit:(NSNumber*)limit
                            offset:(NSNumber*)offset
                includingScoretags:(BOOL)withScoretags
{
    NSString * booleanString = (withScoretags) ? @"true" : @"false";
    id query = [[NSString stringWithFormat:@"offset=%@&limit=%@&with_scoretags=%@", offset, limit, booleanString] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    id endpoint = [NSString stringWithFormat:@"/v0/game/leaderboard/%@/?%@",leaderboardId, query];
    return [HLClient sendApiRequest:endpoint
                         withMethod:GET
                         entity:nil
                   successBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                       resolver([[HLLeaderboard alloc] initWithDictionary:data]);
                   }];
}

+ (PMKPromise*)executeScript:(NSString*)scriptId withPayload:(id)json
{
    id endpoint = [NSString stringWithFormat:@"/v0/game/script/%@",scriptId];
    return [HLClient sendApiRequest:endpoint
                         withMethod:POST
                         entity:json
                   successBlock:^(NSNumber* statusCode, id data, PMKResolver resolver) {
                       resolver(data);
                   }];
}

+(PMKPromise*)loginAnonymouslyWith:(NSString*)deviceId
{
    return [HLClient sendAccountRequest:@"login" withProvider:@"anonymous" entity:@{@"id" : deviceId} session:nil successBlock:successLoginBlock];
}
+(PMKPromise*)loginWithEmail:(NSString*)email andPassword:(NSString*)password
{
    id entity = @{@"email" : email, @"password" : password};
    return [HLClient sendAccountRequest:@"login" withProvider:@"email" entity:entity session:nil successBlock:successLoginBlock];
}
+(PMKPromise*)loginWithEmail:(NSString*)email andPassword:(NSString*)password andLink:(HLSessionClient*)session
{
    id entity = @{@"email" : email, @"password" : password};
    return [HLClient sendAccountRequest:@"login" withProvider:@"email" entity:entity session:session successBlock:successLoginBlock];
}
+(PMKPromise*)loginWithFacebook:(NSString*)accessToken
{
    return [HLClient sendAccountRequest:@"login" withProvider:@"facebook" entity:@{@"access_token": accessToken} session:nil successBlock:successLoginBlock];
}
+(PMKPromise*)loginWithFacebook:(NSString*)accessToken andLink:(HLSessionClient*)session
{
    return [HLClient sendAccountRequest:@"login" withProvider:@"facebook" entity:@{@"access_token": accessToken} session:session successBlock:successLoginBlock];
}
+(PMKPromise*)loginWithGoogle:(NSString*)accessToken
{
    return [HLClient sendAccountRequest:@"login" withProvider:@"google" entity:@{@"access_token": accessToken} session:nil successBlock:successLoginBlock];
}
+(PMKPromise*)loginWithGoogle:(NSString*)accessToken andLink:(HLSessionClient*)session
{
    return [HLClient sendAccountRequest:@"login" withProvider:@"google" entity:@{@"access_token": accessToken} session:session successBlock:successLoginBlock];
}
+(PMKPromise*)loginWithTango:(NSString*)accessToken
{
    return [HLClient sendAccountRequest:@"login" withProvider:@"tango" entity:@{@"access_token": accessToken} session:nil successBlock:successLoginBlock];
}
+(PMKPromise*)loginWithGameCenter:(HLGameCenterCredentials*)credentials
{
    return [HLClient sendAccountRequest:@"login" withProvider:@"gamecenter" entity:[credentials toDictionary] session:nil successBlock:successLoginBlock];
}

+(PMKPromise*)createAccountWithEmail:(NSString*)email andPassword:(NSString*)password andConfirm:(NSString*)passwordConfirmation
{
    return [HLClient createEmailAccount:email andPassword:password andConfirm:passwordConfirmation andName:nil andNickname:nil andLink:nil];
}
+(PMKPromise*)createAccountWithEmail:(NSString*)email andPassword:(NSString*)password andConfirm:(NSString*)passwordConfirmation andName:(NSString*)name
{
    return [HLClient createEmailAccount:email andPassword:password andConfirm:passwordConfirmation andName:nil andNickname:nil andLink:nil];
}
+(PMKPromise*)createAccountWithEmail:(NSString*)email andPassword:(NSString*)password andConfirm:(NSString*)passwordConfirmation andName:(NSString*)name andLink:(HLSessionClient*)session
{
    return [HLClient createEmailAccount:email andPassword:password andConfirm:passwordConfirmation andName:name andNickname:nil andLink:session];
}
+(PMKPromise*)createAccountWithEmail:(NSString*)email andPassword:(NSString*)password andConfirm:(NSString*)passwordConfirmation andName:(NSString*)name andNickname:(NSString*) nickname
{
    return [HLClient createEmailAccount:email andPassword:password andConfirm:passwordConfirmation andName:name andNickname:nickname andLink:nil];
}
+(PMKPromise*)createAccountWithEmail:(NSString*)email andPassword:(NSString*)password andConfirm:(NSString*)passwordConfirmation andName:(NSString*)name andNickname:(NSString*)nickname andLink:(HLSessionClient*)session
{
    return [HLClient createEmailAccount:email andPassword:password andConfirm:passwordConfirmation andName:name andNickname:nickname andLink:session];
}

+(PMKPromise*)createEmailAccount:(NSString*)email andPassword:(NSString*)password andConfirm:(NSString*)passwordConfirmation andName:(NSString*)name andNickname:(NSString*)nickname andLink:(HLSessionClient*)session {
    
    id entity = @{@"email" : email,
                  @"password" : password,
                  @"confirm_password" : passwordConfirmation};
    
    
    entity = [[NSMutableDictionary alloc] initWithDictionary:entity];
    if (name != nil) {
        [entity setObject:name forKey:@"name"];
    }
    if (nickname != nil) {
        [entity setObject:nickname forKey:@"nickname"];
    }
    
    id token = @"";
    if (session != nil) {
        token = [session getGamerToken];
    }
    
    return [HLHttpClient sendAccountsRequestTo:@"/v0/gamer/account/email/create"
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
    return [HLHttpClient sendAccountsRequestTo:@"/v0/gamer/account/email/reset/send"
                                    withMethod:POST
                                        apiKey:apiKey
                                         token:@""
                                        entity:entity
                                  retryHandler:retryHandler
                                  successBlock:successLoginBlock];
}

+(PMKPromise*)linkSession:(HLSessionClient*)session withAnonymousId:(NSString*)anonymousId
{
    return [HLClient sendAccountRequest:@"link" withProvider:@"anonymous" entity:@{@"id": anonymousId} session:session successBlock:nil];
}
+(PMKPromise*)linkSession:(HLSessionClient*)session withFacebookProfile:(NSString*)accessToken
{
    return [HLClient sendAccountRequest:@"link" withProvider:@"facebook" entity:@{@"access_token": accessToken} session:session successBlock:nil];
}
+(PMKPromise*)linkSession:(HLSessionClient*)session withGoogleAccount:(NSString*)accessToken
{
    return [HLClient sendAccountRequest:@"link" withProvider:@"google" entity:@{@"access_token": accessToken} session:session successBlock:nil];
}
+(PMKPromise*)linkSession:(HLSessionClient*)session withTangoAccount:(NSString*)accessToken
{
    return [HLClient sendAccountRequest:@"link" withProvider:@"tango" entity:@{@"access_token": accessToken} session:session successBlock:nil];
}
+(PMKPromise*)linkSession:(HLSessionClient*)session withGameCenterPlayerId:(HLGameCenterCredentials*)credentials
{
    return [HLClient sendAccountRequest:@"link" withProvider:@"gamecenter" entity:[credentials toDictionary] session:session successBlock:nil];
}

+(PMKPromise*)unlinkSession:(HLSessionClient*)session fromAnonymousId:(NSString*)anonymousId
{
    return [HLClient sendAccountRequest:@"unlink" withProvider:@"anonymous" entity:@{@"id": anonymousId} session:session successBlock:nil];
}
+(PMKPromise*)unlinkSession:(HLSessionClient*)session fromEmail:(NSString*)emailAddress
{
    return [HLClient sendAccountRequest:@"unlink" withProvider:@"email" entity:@{@"email": emailAddress} session:session successBlock:nil];
}
+(PMKPromise*)unlinkSession:(HLSessionClient*)session fromFacebookProfile:(NSString*)facebookProfileId
{
    return [HLClient sendAccountRequest:@"unlink" withProvider:@"facebook" entity:@{@"id": facebookProfileId} session:session successBlock:nil];
}
+(PMKPromise*)unlinkSession:(HLSessionClient*)session fromGoogleAccount:(NSString*)googleAccountId
{
    return [HLClient sendAccountRequest:@"unlink" withProvider:@"google" entity:@{@"id": googleAccountId} session:session successBlock:nil];
}
+(PMKPromise*)unlinkSession:(HLSessionClient*)session fromTangoAccount:(NSString*)tangoAccountId
{
    return [HLClient sendAccountRequest:@"unlink" withProvider:@"tango" entity:@{@"id": tangoAccountId} session:session successBlock:nil];
}
+(PMKPromise*)unlinkSession:(HLSessionClient*)session fromGameCenter:(NSString*)gameCenterPlayerId
{
    return [HLClient sendAccountRequest:@"unlink" withProvider:@"gamecenter" entity:@{@"player_id": gameCenterPlayerId} session:session successBlock:nil];
}

+(PMKPromise*)checkAnonymousId:(NSString*)anonymousId
{
    return [HLClient sendAccountRequest:@"check" withProvider:@"anonymous" entity:@{@"id": anonymousId} session:nil successBlock:successCheckBlock];
}
+(PMKPromise*)checkEmail:(NSString*)emailAddress
{
    return [HLClient sendAccountRequest:@"check" withProvider:@"email" entity:@{@"email": emailAddress} session:nil successBlock:successCheckBlock];
}
+(PMKPromise*)checkFacebookProfileId:(NSString*)facebookProfileId
{
    return [HLClient sendAccountRequest:@"check" withProvider:@"facebook" entity:@{@"access_token": facebookProfileId} session:nil successBlock:successCheckBlock];
}
+(PMKPromise*)checkGoogleAccountId:(NSString*)googleAccountId
{
    return [HLClient sendAccountRequest:@"check" withProvider:@"google" entity:@{@"access_token": googleAccountId} session:nil successBlock:successCheckBlock];
}
+(PMKPromise*)checkTangoId:(NSString*)tangoId
{
    return [HLClient sendAccountRequest:@"check" withProvider:@"tango" entity:@{@"access_token": tangoId} session:nil successBlock:successCheckBlock];
}
+(PMKPromise*)checkGameCenterId:(NSString*)playerId
{
    return [HLClient sendAccountRequest:@"check" withProvider:@"gamecenter" entity:@{@"id": playerId} session:nil successBlock:successCheckBlock];
}

+(PMKPromise*)checkAnonymousId:(NSString*)anonymousId withSession:(HLSessionClient*) session
{
    return [HLClient sendAccountRequest:@"check" withProvider:@"anonymous" entity:@{@"id": anonymousId} session:session successBlock:successCheckBlock];
}
+(PMKPromise*)checkEmail:(NSString*)emailAddress withSession:(HLSessionClient*) session
{
    return [HLClient sendAccountRequest:@"check" withProvider:@"email" entity:@{@"email": emailAddress} session:session successBlock:successCheckBlock];
}
+(PMKPromise*)checkFacebookProfileId:(NSString*)facebookProfileId withSession:(HLSessionClient*) session
{
    return [HLClient sendAccountRequest:@"check" withProvider:@"facebook" entity:@{@"access_token": facebookProfileId} session:session successBlock:successCheckBlock];
}
+(PMKPromise*)checkGoogleAccountId:(NSString*)googleAccountId withSession:(HLSessionClient*) session
{
    return [HLClient sendAccountRequest:@"check" withProvider:@"google" entity:@{@"access_token": googleAccountId} session:session successBlock:successCheckBlock];
}
+(PMKPromise*)checkTangoId:(NSString*)tangoId withSession:(HLSessionClient*) session
{
    return [HLClient sendAccountRequest:@"check" withProvider:@"tango" entity:@{@"access_token": tangoId} session:session successBlock:successCheckBlock];
}
+(PMKPromise*)checkGameCenterId:(HLGameCenterCredentials*)credentials withSession:(HLSessionClient*) session
{
    return [HLClient sendAccountRequest:@"check" withProvider:@"gamecenter" entity:[credentials toDictionary] session:session successBlock:successCheckBlock];
}


+(PMKPromise*)sendAccountRequest:(NSString*)type
                    withProvider:(NSString*)provider
                          entity:(NSDictionary*)entity
                         session:(HLSessionClient*)session
                    successBlock:(void(^)(NSNumber* statusCode, id data, PMKResolver resolver))successCallback
{
    id token = @"";
    if (session != nil) {
        token = [session getGamerToken];
    }
    
    id endpoint = [NSString stringWithFormat:@"/v0/gamer/%@/%@", type, provider];
    return [HLHttpClient sendAccountsRequestTo:endpoint
                                    withMethod:POST
                                        apiKey:apiKey
                                         token:token
                                        entity:entity
                                  retryHandler:retryHandler
                                  successBlock:successCallback];
}

+(PMKPromise*)sendApiRequest:(NSString*)endpoint
                  withMethod:(enum HLRequestMethod)method
                      entity:(id)entity
                successBlock:(void(^)(NSNumber* statusCode, id data, PMKResolver resolver))successCallback
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
