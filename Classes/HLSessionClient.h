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
#import "HLRequestRetryHandlerProtocol.h"

/**
 Represents interface for interacting with the Heroic Labs service with a gamer token
 */
@interface HLSessionClient : NSObject

/**
 Initialise a Heroic Labs Session with an API Key, Gamer Token, and a custom retry handler.
 */
-(id)initWithApiKey:(id)apikeyToUse
           andToken:(id)tokenToUse
   withRetryHandler:(id<HLRequestRetryHandlerProtocol>)handler;


/**
 Returns the cached Gamer Token. Save this Gamer Token in the local device storage for later restore.
 */
-(id)getGamerToken;

/**
 Ping the Heroic Labs service with the given API Key and Token to check it is reachable and ready to handle
 requests.
 */
-(PMKPromise*)ping;

/**
 Get information about the gamer who owns this session.
 */
-(PMKPromise*)getGamerProfile;

/**
 Updates information about the gamer who owns this session.
 */
-(PMKPromise*)updateGamerProfile:(NSString*)nickname;

/**
 Perform a key-value storage read operation.
 
 @param storageKey The key to attempt to read data from.
 */
-(PMKPromise*)getStoredDataWithKey:(NSString*)storageKey;

/**
 Perform a key-value storage write operation, storing data as JSON. Data
 is private per-user and per-game.
 
 NOTE: This is not designed to store confidential data, such as payment
 information etc.
 
 @param value The object to serialise and store.
 @param storageKey The key to store the given data under.
 */
-(PMKPromise*)storeData:(NSDictionary*)value withKey:(NSString*)storageKey;

/**
 Perform a key-value storage delete operation.
 @param key The key to delete data from.
 */
-(PMKPromise*)deleteStoredDataWithKey:(NSString*)storageKey;

/**
 Get a list of achievements available for the game, including any gamer
 data such as progress or completed timestamps.
 */
-(PMKPromise*)getAchievements;

/**
 Unlocks the given achievement.
 
 @param achievementId An achievement ID to be unlocked.
 */
-(PMKPromise*)unlockAchievementWithId:(NSString*)achievementId;

/**
 Report progress towards a given achievement.
 
 @param achievementId An achievement update to be sent to the Heroic Labs server.
 @param count Count of the achievement to be updated.
 */
-(PMKPromise*)updateAchievementWithId:(NSString*)achievementId withCount:(NSNumber*)count;

/**
 Get the metadata including leaderboard enteries for given leaderboard.
 This also retrieves the current gamer's leaderboard standing
 
 @param leaderboardId The Leadeboard ID to use.
 */
-(PMKPromise*)getLeaderboardAndRankWithId:(id)leaderboardId;

/**
 Update the gamer's stand in the leaderboard with a new score leaving scoretags untouched.
 
 @param leaderboardId Leaderboard ID to be updated.
 @param score New score for this leaderboard.
 */
-(PMKPromise*)updateRankWithId:(NSString*)leaderboardId withScore:(NSNumber*) score;


/**
 Update the gamer's stand in the leaderboard with a new score with new scoretags data.
 
 @param leaderboardId Leaderboard ID to be updated.
 @param score New score for this leaderboard.
 @param scoretags New scoretags for this leaderboard.
 */
-(PMKPromise*)updateRankWithId:(NSString*)leaderboardId withScore:(NSNumber*)score andScoretags:(NSDictionary*)scoretags;

/**
 Retrieve a list of matches the gamer is part of, along with the metadata for each match.
 */
-(PMKPromise*)getMatches;

/**
 Retrieve a particular match's status and metadata.
 @param matchId The match identifier
 */
-(PMKPromise*)getMatchWithId:(NSString*) matchId;

/**
 Get turn data for a particular match, only returning turns newer than the identified one.
 @param matchId The match identifier
 @param The turn number to start from, not inclusive. Use '0' to get all the turns in the match
 */
-(PMKPromise*)getDataForTurn:(NSNumber*) turnNumber withMatchId:(NSString*) matchId;

/**
 Submit turn data to the specified match.
 
 @param matchId The match identifier
 @param data Turn data to submit
 @param turn Last seen turn number - this is used as a basic consistency check
 @param nextGamerNickname Which gamer the next turn belongs to
 */
-(PMKPromise*)submitTurn:(NSNumber*)turn withData:(NSString*)data toNextGamer:(NSString*)nextGamerNickname forMatchWithId:(NSString*)matchId;

/**
 Request a new match. If there are not enough waiting gamers, the current gamer will be added to the queue instead.
 @param requiredGamers The minimal required number of gamers needed to create a new match
 */
-(PMKPromise*)createMatchFor:(NSNumber*)requiredGamers;

/**
 End match. This will only work if it's the current gamer's turn.
 @param matchId The match identifier
 */
-(PMKPromise*)endMatchWithId:(NSString*)matchId;


/**
 Leave match. This will only work if it's NOT the current gamer's turn.
 @param matchId The match identifier
 */
-(PMKPromise*)leaveMatchWithId:(NSString*)matchId;

/**
 Subscribe this device for Push notification with Heroic Labs Push and Apple Push Notifications.
 
 @param inDeviceToken raw Device Token recieved from APN
 @param segments Segment names to subscribe to. To subscribe to all segments, pass an empty array.
 */
- (PMKPromise*)subscribePushWithDeviceToken:(NSData*)inDeviceToken toSegments:(NSArray*)segments;

/**
 Verify purchase of a given product using receipt IDs from the App Store
 
 @param receipt Purchase receipt from App Store
 @param productId In-App Purchase Product Id in the form of "some.purchased.product.id"
 */
- (PMKPromise*)verifyPurchase:(NSData*)receipt ofProduct:(NSString*)productId;

/**
 Executes a script on the server, with the current player authenticated.
 
 @param scriptId The Script ID to use.
 @param json The Payload to send to the server. Can be nil or NSDictionary or NSString.
 */
- (PMKPromise*)executeScript:(NSString*)scriptId withPayload:(id)json;

@end