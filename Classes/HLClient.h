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

#import <Foundation/Foundation.h>
#import <PromiseKit/Promise.h>
#import "HLSessionClient.h"
#import "HLRequestRetryHandlerProtocol.h"
#import "HLDefaultRequestRetryHandler.h"
#import "HLPing.h"
#import "HLServer.h"
#import "HLGame.h"
#import "HLAchievement.h"
#import "HLLeaderboard.h"
#import "HLLeaderboardRank.h"

/**
 Represents interface for interacting with the Heroic Labs service
 */
@interface HLClient : NSObject

/**
 Sets an API Key.
 */
+(void)setApiKey:(NSString*)key;

/**
 Sets a custom retry handler.
 */
+(void)setRetryHandler:(id<HLRequestRetryHandlerProtocol>)handler;

/**
 Restores a Heroic Labs Session with a Gamer Token. Validate Gamer Token with [HLSessionClient ping].
 @param gamerToken Token to restore the session with.
 */
+(HLSessionClient*)restoreSession:(NSString*)gamerToken;

/**
 Ping the Heroic Labs service with the given API Key to check it is reachable and ready to handle
 requests.
 */
+(PMKPromise*)ping;

/**
 Retrieve Heroic Labs global service and/or server instance data.
 */
+(PMKPromise*)getServerInfo;

/**
 Retrieve information about the game the given API key corresponds to, as
 configured in the remote service.
 */
+(PMKPromise*)getGameDetails;

/**
 Get a list of achievements available for the game, excluding any gamer
 data such as progress or completed timestamps.
 */
+(PMKPromise*)getAchievements;

/**
 Get the metadata including leaderboard enteries for all leaderboards.
 */
+(PMKPromise*)getLeaderboards;

/**
 Executes a script on the server, with the current player authenticated.
 
 @param scriptId The Script ID to use.
 @param json The Payload to send to the server. Can be nil or NSDictionary or NSString.
 */
+(PMKPromise*)executeScript:(NSString*)scriptId withPayload:(id)json;

/**
 Get the metadata including leaderboard enteries for given leaderboard.
 
 @param leaderboardId The Leadeboard ID to use.
 */
+(PMKPromise*)getLeaderboardWithId:(NSString*)leaderboardId;

/**
 Get the metadata including leaderboard enteries for given leaderboard.
 
 @param leaderboardId The Leadeboard ID to use.
 @param limit Number of entries to return. Default is 50.
 @param offset Entries to start from with the leaderboard list. Default is 0.
 @param withScoretags Include Scoretags in the leaderboard entries.
 */
+(PMKPromise*)getLeaderboardWithId:(NSString*)leaderboardId limit:(NSNumber*)limit offset:(NSNumber*)offset includingScoretags:(BOOL)withScoretags;

/**
 Perform an anonymous login
 @param deviceId An identifier to use to create a gamerToken. Using Device ID is recommended.
 */
+(PMKPromise*)loginAnonymouslyWith:(NSString*)deviceId;

/**
 Perform OAuth passthrough login for Facebook.
 @param accessToken The Facebook access token to send to Heroic Labs.
 */
+(PMKPromise*)loginWithFacebook:(NSString*)accessToken;

/**
 Perform OAuth passthrough login for Facebook.
 @param accessToken The Facebook access token to send to Heroic Labs.
 @param session A session pointing to an existing account, on
 successful login the new social profile will be
 bound to this same account if possible, data will
 be migrated from the given account to the new one
 otherwise.
 */
+(PMKPromise*)loginWithFacebook:(NSString*)accessToken andLink:(HLSessionClient*)session;

/**
 Perform OAuth passthrough login for Google.
 @param accessToken The Google access token to send to Heroic Labs.
 */
+(PMKPromise*)loginWithGoogle:(NSString*)accessToken;

/**
 Perform OAuth passthrough login for Google.
 @param accessToken The Google access token to send to Heroic Labs.
 @param session A session pointing to an existing account, on
 successful login the new social profile will be
 bound to this same account if possible, data will
 be migrated from the given account to the new one
 */
+(PMKPromise*)loginWithGoogle:(NSString*)accessToken andLink:(HLSessionClient*)session;

/**
 Perform Login with a Heroic Labs Account.
 @param email Email to login to Heroic Labs.
 @param password Password of the account.
 */
+(PMKPromise*)loginWithEmail:(NSString*)email andPassword:(NSString*)password;

/**
 Creates a new Heroic Labs account with the supplied info.
 @param email Email to login to Heroic Labs.
 @param password Password of the account.
 @param session A session pointing to an existing account, on
 successful login the profile will be bound to this same account
 if possible, data will be migrated from the given account to the new one.
 */
+(PMKPromise*)loginWithEmail:(NSString*)email andPassword:(NSString*)password andLink:(HLSessionClient*)session;

/**
 Creates a new Heroic Labs account with the supplied info.
 @param email Email to login to Heroic Labs.
 @param password Password of the account.
 @param passwordConfirmation Password of the account.
 */
+(PMKPromise*)createAccountWithEmail:(NSString*)email andPassword:(NSString*)password andConfirm:(NSString*)passwordConfirmation;

/**
 Creates a new Heroic Labs account with the supplied info.
 @param email Email to login to Heroic Labs.
 @param password Password of the account.
 @param passwordConfirmation Password of the account.
 @param name Name of the gamer.
 */
+(PMKPromise*)createAccountWithEmail:(NSString*)email andPassword:(NSString*)password andConfirm:(NSString*)passwordConfirmation andName:(NSString*)name;

/**
 Creates a new Heroic Labs account with the supplied info.
 @param email Email to login to Heroic Labs.
 @param password Password of the account.
 @param passwordConfirmation Password of the account.
 @param name Name of the gamer.
 @param session A session pointing to an existing account, on
 successful login the profile will be bound to this same account
 if possible, data will be migrated from the given account to the new one.
 */
+(PMKPromise*)createAccountWithEmail:(NSString*)email andPassword:(NSString*)password andConfirm:(NSString*)passwordConfirmation andName:(NSString*)name andLink:(HLSessionClient*)session;

/**
 Creates a new Heroic Labs account with the supplied info.
 @param email Email to login to Heroic Labs.
 @param password Password of the account.
 @param passwordConfirmation Password of the account.
 @param name Name of the gamer.
 @param nickname Nickname of the gamer. Can be nil.
 */
+(PMKPromise*)createAccountWithEmail:(NSString*)email andPassword:(NSString*)password andConfirm:(NSString*)passwordConfirmation andName:(NSString*)name andNickname:(NSString*) nickname;

/**
 Creates a new Heroic Labs account with the supplied info.
 @param email Email to login to Heroic Labs.
 @param password Password of the account.
 @param passwordConfirmation Password of the account.
 @param name Name of the gamer.
 @param nickname Nickname of the gamer. Can be nil.
 @param session A session pointing to an existing account, on
 successful login the profile will be bound to this same account
 if possible, data will be migrated from the given account to the new one.
 */
+(PMKPromise*)createAccountWithEmail:(NSString*)email andPassword:(NSString*)password andConfirm:(NSString*)passwordConfirmation andName:(NSString*)name andNickname:(NSString*)nickname andLink:(HLSessionClient*)session;

/**
 Sends a password reset email to the gamer with a token to reset the password.
 @param email Email used to login to Heroic Labs.
 */
+(PMKPromise*)sendLoginReset:(NSString*)email;

@end
