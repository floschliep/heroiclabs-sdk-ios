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
#import "HLGameCenterCredentials.h"

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
 Executes a Cloud Code function on the server, without sending input data.
 
 @param scriptId The Script ID to use.
 @param json The Payload to send to the server. Can be nil or NSDictionary or NSString.
 */
+(PMKPromise*)executeScript:(NSString*)scriptId withPayload:(id)json DEPRECATED_ATTRIBUTE DEPRECATED_MSG_ATTRIBUTE("use CloudCode Functions");

/**
 Executes a Cloud Code function on the server, without sending input data.
 
 @param function Function to be executed
 @param module Module name that the function belongs to
 */
+ (PMKPromise*)executeCloudCodeFunction:(NSString*)function inModule:(NSString*)module;

/**
 Executes a Cloud Code function on the server.
 
 @param function Function to be executed
 @param module Module name that the function belongs to
 @param json The Payload to send to the server. Can be nil or NSDictionary or NSString.
 */
+ (PMKPromise*)executeCloudCodeFunction:(NSString*)function inModule:(NSString*)module withPayload:(id)json;

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
 successful login the profile will be bound to this same account.
 */
+(PMKPromise*)loginWithEmail:(NSString*)email andPassword:(NSString*)password andLink:(HLSessionClient*)session DEPRECATED_ATTRIBUTE DEPRECATED_MSG_ATTRIBUTE("use explicit link method");

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
 bound to this same account.
 */
+(PMKPromise*)loginWithFacebook:(NSString*)accessToken andLink:(HLSessionClient*)session DEPRECATED_ATTRIBUTE DEPRECATED_MSG_ATTRIBUTE("use explicit link method");;

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
 bound to this same account.
 */
+(PMKPromise*)loginWithGoogle:(NSString*)accessToken andLink:(HLSessionClient*)session DEPRECATED_ATTRIBUTE DEPRECATED_MSG_ATTRIBUTE("use explicit link method");

/**
 Perform OAuth passthrough login for Tango. You need prior authentication with Tango.
 @param accessToken The Tango access token to send to Heroic Labs.
 */
+(PMKPromise*)loginWithTango:(NSString*)accessToken;

/**
 Perform login using GameCenter PlayerID. You need prior authentication with GameCenter.
 @param credentials The GameCenter Credentials to send to Heroic Labs.
 */
+(PMKPromise*)loginWithGameCenter:(HLGameCenterCredentials*)credentials;

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

/**
 Links the given session with an anonymous Id, resulting in the ability of future logins to the same account from multiple anonymous Ids
 @param session Current session to link to.
 @param anonymousId New Id to associate to the given session
 */
+(PMKPromise*)linkSession:(HLSessionClient*)session withAnonymousId:(NSString*)anonymousId;

/**
 Links the given session with an Facebook Account, resulting in the ability of future logins to the same account from multiple Facebook Accounts
 @param session Current session to link to.
 @param accessToken Facebook Account to associate to the given session.
 */
+(PMKPromise*)linkSession:(HLSessionClient*)session withFacebookProfile:(NSString*)accessToken;

/**
 Links the given session with an Google Account, resulting in the ability of future logins to the same account from multiple Google Accounts
 @param session Current session to link to.
 @param accessToken Google Account to associate to the given session.
 */
+(PMKPromise*)linkSession:(HLSessionClient*)session withGoogleAccount:(NSString*)accessToken;

/**
 Links the given session with an Tango Account, resulting in the ability of future logins to the same account from multiple Tango Accounts
 @param session Current session to link to.
 @param accessToken Tango Account to associate to the given session.
 */
+(PMKPromise*)linkSession:(HLSessionClient*)session withTangoAccount:(NSString*)accessToken;

/**
 Links the given session with a GameCenter Account, resulting in the ability of future logins to the same account from multiple GameCenter Accounts
 @param session Current session to link to.
 @param credentials GameCenter Player Credentials to associate to the given session.
 */
+(PMKPromise*)linkSession:(HLSessionClient*)session withGameCenterPlayerId:(HLGameCenterCredentials*)credentials;

/**
 Unlink the given session from an existing Anonymous ID.
 @param session Current session to unlink from.
 @param anonymousId Anonymous ID to unlink from this account.
 */
+(PMKPromise*)unlinkSession:(HLSessionClient*)session fromAnonymousId:(NSString*)anonymousId;

/**
 Unlink the given session from an existing Email Address.
 @param session Current session to unlink from.
 @param emailAddress Email Address to unlink from this account.
 */
+(PMKPromise*)unlinkSession:(HLSessionClient*)session fromEmail:(NSString*)emailAddress;

/**
 Unlink the given session from an existing Facebook Account.
 @param session Current session to unlink from.
 @param facebookProfileId Facebook Account to unlink from this account.
 */
+(PMKPromise*)unlinkSession:(HLSessionClient*)session fromFacebookProfile:(NSString*)facebookProfileId;

/**
 Unlink the given session from an existing GameCenter Account.
 @param session Current session to unlink from.
 @param googleAccountId Google Account to unlink from this account.
 */
+(PMKPromise*)unlinkSession:(HLSessionClient*)session fromGoogleAccount:(NSString*)googleAccountId;

/**
 Unlink the given session from an existing Tango Account.
 @param session Current session to unlink from.
 @param tangoAccountId Tango Account to unlink from this account.
 */
+(PMKPromise*)unlinkSession:(HLSessionClient*)session fromTangoAccount:(NSString*)tangoAccountId;

/**
 Unlink the given session from an existing Google Account.
 @param session Current session to link to.
 @param gameCenterPlayerId GameCenter Player ID to unlink from this account.
 */
+(PMKPromise*)unlinkSession:(HLSessionClient*)session fromGameCenter:(NSString*)gameCenterPlayerId;

/**
 Checks to see if the given Anonymous ID exists in the Heroic Labs platform.
 Return either 'nil', if it doesn't exist, or the current associated gamer account ID.
 @param anonymousId Anonymous ID to check.
 */
+(PMKPromise*)checkAnonymousId:(NSString*)anonymousId;

/**
 Checks to see if the given Email Address exists in the Heroic Labs platform.
 Return either 'nil', if it doesn't exist, or the current associated gamer account ID.
 @param emailAddress Email Address to check.
 */
+(PMKPromise*)checkEmail:(NSString*)emailAddress;

/**
 Checks to see if the given Facebook Profile exists in the Heroic Labs platform.
 Return either 'nil', if it doesn't exist, or the current associated gamer account ID.
 @param facebookProfileId Facebook Profile to check.
 */
+(PMKPromise*)checkFacebookProfileId:(NSString*)facebookProfileId;

/**
 Checks to see if the given Google Account exists in the Heroic Labs platform.
 Return either 'nil', if it doesn't exist, or the current associated gamer account ID.
 @param googleAccountId Google Account to check.
 */
+(PMKPromise*)checkGoogleAccountId:(NSString*)googleAccountId;

/**
 Checks to see if the given Tango Account exists in the Heroic Labs platform.
 Return either 'nil', if it doesn't exist, or the current associated gamer account ID.
 @param tangoId Tango Account to check.
 */
+(PMKPromise*)checkTangoId:(NSString*)tangoId;

/**
 Checks to see if the given GameCenter Player ID exists in the Heroic Labs platform.
 Return either 'nil', if it doesn't exist, or the current associated gamer account ID.
 @param playerId GameCenter Player ID to check.
 */
+(PMKPromise*)checkGameCenterId:(NSString*)playerId;

/**
 Checks to see if the given Anonymous ID exists in the Heroic Labs platform.
 Return either 'nil', if it doesn't exist, or the current associated gamer account ID.
 @param anonymousId Anonymous ID to check.
 @param session Session to additionally check against.
 */
+(PMKPromise*)checkAnonymousId:(NSString*)anonymousId withSession:(HLSessionClient*) session;

/**
 Checks to see if the given Email Address exists in the Heroic Labs platform.
 Return either 'nil', if it doesn't exist, or the current associated gamer account ID.
 @param emailAddress Email Address to check.
 @param session Session to additionally check against.
 */
+(PMKPromise*)checkEmail:(NSString*)emailAddress withSession:(HLSessionClient*) session;

/**
 Checks to see if the given Facebook Profile exists in the Heroic Labs platform.
 Return either 'nil', if it doesn't exist, or the current associated gamer account ID.
 @param facebookProfileId Facebook Profile to check.
 @param session Session to additionally check against.
 */
+(PMKPromise*)checkFacebookProfileId:(NSString*)facebookProfileId withSession:(HLSessionClient*) session;

/**
 Checks to see if the given Google Account exists in the Heroic Labs platform.
 Return either 'nil', if it doesn't exist, or the current associated gamer account ID.
 @param googleAccountId Google Account to check.
 @param session Session to additionally check against.
 */
+(PMKPromise*)checkGoogleAccountId:(NSString*)googleAccountId withSession:(HLSessionClient*) session;

/**
 Checks to see if the given Tango Account exists in the Heroic Labs platform.
 Return either 'nil', if it doesn't exist, or the current associated gamer account ID.
 @param tangoId Tango Account to check.
 @param session Session to additionally check against.
 */
+(PMKPromise*)checkTangoId:(NSString*)tangoId withSession:(HLSessionClient*) session;

/**
 Checks to see if the given GameCenter Player ID exists in the Heroic Labs platform.
 Return either 'nil', if it doesn't exist, or the current associated gamer account ID.
 @param credentials GameCenter Credentials to check.
 @param session Session to additionally check against.
 */
+(PMKPromise*)checkGameCenterId:(HLGameCenterCredentials*)credentials withSession:(HLSessionClient*) session;

@end
