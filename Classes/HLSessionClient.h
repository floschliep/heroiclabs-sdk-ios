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
#import "HLRequestRetryHandlerProtocol.h"
#import "HLPing.h"
#import "HLServer.h"
#import "HLGame.h"
#import "HLGamer.h"
#import "HLAchievement.h"
#import "HLLeaderboard.h"
#import "HLLeaderboardRank.h"
#import "HLMatch.h"
#import "HLMatchChange.h"
#import "HLMatchTurn.h"
#import "HLPurchaseVerification.h"
#import "HLMessage.h"
#import "HLSharedStorageSearchResults.h"
#import "HLDatastoreObject.h"

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
-(PMKPromise*)getStoredDataWithKey:(NSString*)storageKey DEPRECATED_ATTRIBUTE DEPRECATED_MSG_ATTRIBUTE("use Datastore instead");

/**
 Perform a key-value storage write operation, storing data as JSON. Data
 is private per-user and per-game.
 
 NOTE: This is not designed to store confidential data, such as payment
 information etc.
 
 @param value The object to serialise and store.
 @param storageKey The key to store the given data under.
 */
-(PMKPromise*)storeData:(NSDictionary*)value withKey:(NSString*)storageKey DEPRECATED_ATTRIBUTE DEPRECATED_MSG_ATTRIBUTE("use Datastore instead");

/**
 Perform a key-value storage delete operation.
 @param key The key to delete data from.
 */
-(PMKPromise*)deleteStoredDataWithKey:(NSString*)storageKey DEPRECATED_ATTRIBUTE DEPRECATED_MSG_ATTRIBUTE("use Datastore instead");

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
 Get the metadata including leaderboard enteries for given leaderboard.
 This also retrieves the current gamer's leaderboard standing
 
 @param leaderboardId The Leadeboard ID to use.
 @param limit Number of entries to return. Integer between 10 and 50 inclusive.
 @param offset Starting point to return ranking. Must be positive, if negative it is treated as an "auto offset".
 @param withScoretags Whether to retrieve scoretags or not.
 */
-(PMKPromise*)getLeaderboardAndRankWithId:(NSString*)leaderboardId limit:(NSNumber*)limit offset:(NSNumber*)offset includingScoretags:(BOOL)withScoretags;

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
 Retrieve a list of matches and turn data since the given timestamp.
 @param timestamp Unix timestamp. This should be the latest 'updatedAt' timestamp in all your matches.
 */
-(PMKPromise*)getChangedMatchesSince:(NSNumber*)timestamp;

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
-(PMKPromise*)submitTurn:(NSNumber*)turn withData:(NSString*)data toNextGamer:(NSString*)nextGamerNickname forMatchWithId:(NSString*)matchId DEPRECATED_ATTRIBUTE DEPRECATED_MSG_ATTRIBUTE("use submit turn with gamer id");

/**
 Submit turn data to the specified match.
 
 @param matchId The match identifier
 @param data Turn data to submit
 @param turn Last seen turn number - this is used as a basic consistency check
 @param nextGamerId Which gamer the next turn belongs to
 */
-(PMKPromise*)submitTurn:(NSNumber*)turn withData:(NSString*)data toNextGamerId:(NSString*)nextGamerId forMatchWithId:(NSString*)matchId;

/**
 Request a new match with the given players. The current gamer is part of the match and will be set as the first turn taker.
 @param gamers Gamer IDs of other players.
 */
-(PMKPromise*)createMatchWithGamers:(NSArray<NSString*>*)gamers;

/**
 Request a new match with the given players. The current gamer is part of the match and will be set as the first turn taker.
 @param gamers Gamer IDs of other players.
 @param matchFilters String array to filter on matches to create or join. Exact strings matching only. Up to 8 filters.
 */
-(PMKPromise*)createMatchWithGamers:(NSArray<NSString*>*)gamers filters:(NSArray*)matchFilters;

/**
 Request a new match. If there are not enough waiting gamers, the current gamer will be added to the queue instead.
 @param requiredGamers The minimal required number of gamers needed to create a new match
 */
-(PMKPromise*)createMatchFor:(NSNumber*)requiredGamers;

/**
 Request a new match with players of the same match type. 
 If there are not enough waiting gamers, the current gamer will be added to the queue instead.
 
 @param requiredGamers The minimal required number of gamers needed to create a new match
 @param matchFilters String array to filter on matches to create or join. Exact strings matching only. Up to 8 filters. Recommended to use values such as "[team,rank=7]" for team-based matches with players with ranks equal to 7.
 */
-(PMKPromise*)createMatchFor:(NSNumber*)requiredGamers withFilters:(NSArray*)matchFilters;

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

/**
 Checks and retrieves all messages from the server.
 
 @param body Whether to retrieve message body as well. Recommended NO.
 */
- (PMKPromise*)getMessagesWithBody:(BOOL)body;

/**
 Checks and retrieves all messages from the server since a given UTC timestamp in millisecond.
 
 @param body Whether to retrieve message body as well. Recommended NO. 
 @param utcMilliTimestamp Get messages that are newer than this timestamp.
 */
- (PMKPromise*)getMessagesWithBody:(BOOL)body newerSince:(NSNumber*)utcMilliTimestamp;

/**
 Retrieves a message from the mailbox. This sets the message as READ.
 
 @param messageId ID of the message to be retrieved from the player's mailbox. 
 @param body Whether to retrieve message body as well.
 */
- (PMKPromise*)getMessageWithId:(NSString*)messageId withBody:(BOOL)body;

/**
 Deletes a message from the mailbox.
 
 @param messageId ID of the message to be deleted from the player's mailbox.
 */
- (PMKPromise*)deleteMessageWithId:(NSString*)messageId;

/**
 Get data in Shared Storage matching the query.
 
 @param luceneQuery Lucene-like query used to match.
 */
- (PMKPromise*)searchSharedStorageWithQuery:(NSString*)luceneQuery DEPRECATED_ATTRIBUTE DEPRECATED_MSG_ATTRIBUTE("use Datastore instead");

/**
 Get data in Shared Storage matching the query.
 
 @param luceneQuery Lucene-like query used to match.
 @param key Key name to restrict searches to. Only results among those keys will be returned. Can be null.
 */
- (PMKPromise*)searchSharedStorageWithQuery:(NSString*)luceneQuery andFilter:(NSString*)key DEPRECATED_ATTRIBUTE DEPRECATED_MSG_ATTRIBUTE("use Datastore instead");

/**
 Get data in Shared Storage matching the query.
 
 @param luceneQuery Lucene-like query used to match.
 @param key Key name to restrict searches to. Only results among those keys will be returned. Can be null.
 @param sortKey Lucene-like sort clauses used to order search results. Can be null.
 */
- (PMKPromise*)searchSharedStorageWithQuery:(NSString*)luceneQuery andFilter:(NSString*)key sort:(NSString*)sortKey DEPRECATED_ATTRIBUTE DEPRECATED_MSG_ATTRIBUTE("use Datastore instead");

/**
 Get data in Shared Storage matching the query.
 
 @param luceneQuery Lucene-like query used to match.
 @param key Key name to restrict searches to. Only results among those keys will be returned. Can be null.
 @param sortKey Lucene-like sort clauses used to order search results. Can be null.
 @param limit Maximum number of results to return.
 */
- (PMKPromise*)searchSharedStorageWithQuery:(NSString*)luceneQuery andFilter:(NSString*)key sort:(NSString*)sortKey limit:(NSNumber*)limit DEPRECATED_ATTRIBUTE DEPRECATED_MSG_ATTRIBUTE("use Datastore instead");

/**
 Get data in Shared Storage matching the query. Use this to paginate the results.
 
 @param luceneQuery Lucene-like query used to match.
 @param key Key name to restrict searches to. Only results among those keys will be returned. Can be null.
 @param sortKey Lucene-like sort clauses used to order search results. Can be null.
 @param limit Maximum number of results to return.
 @param offset Starting position of the result.
 */
- (PMKPromise*)searchSharedStorageWithQuery:(NSString*)luceneQuery andFilter:(NSString*)key sort:(NSString*)sortKey limit:(NSNumber*)limit offset:(NSNumber*)offset DEPRECATED_ATTRIBUTE DEPRECATED_MSG_ATTRIBUTE("use Datastore instead");

/**
 Get data in SharedStorage matching the given key.
 
 @param key Data in shared storage in the given key. Alphanumeric characters only.
 */
- (PMKPromise*)getSharedDataWithKey:(NSString*)key DEPRECATED_ATTRIBUTE DEPRECATED_MSG_ATTRIBUTE("use Datastore instead");

/**
 Get data in SharedStorage matching the given key.
 
 @param data dictionary key-value pairs.
 @param key Data in shared storage in the given key. Alphanumeric characters only.
 */
- (PMKPromise*)storeSharedData:(NSDictionary*)data withKey:(NSString*)key DEPRECATED_ATTRIBUTE DEPRECATED_MSG_ATTRIBUTE("use Datastore instead");

/**
 Partially update data in SharedStorage for the given key.
 - If data doesn't exist, it will be added
 - If data exists, then the matching portion will be overwritten
 - If data exists, but new data is 'null' then the matching portion will be erased.
 
 @param key Data in shared storage in the given key. Alphanumeric characters only.
 */
- (PMKPromise*)partialUpdateSharedData:(NSDictionary*)data withKey:(NSString*)key DEPRECATED_ATTRIBUTE DEPRECATED_MSG_ATTRIBUTE("use Datastore instead");

/**
 Delete data in the Public region of SharedStorage matching the given key.
 
 @param key Data in shared storage in the given key. Alphanumeric characters only.
 */
- (PMKPromise*)deleteSharedDataWithKey:(NSString*)key DEPRECATED_ATTRIBUTE DEPRECATED_MSG_ATTRIBUTE("use Datastore instead");

/**
 Get data in Datastore matching the query.
 
 @param luceneQuery Lucene-like query used to match.
 @param table Table name to search.
 */
- (PMKPromise*)datastoreSearchWithQuery:(NSString*)luceneQuery inTable:(NSString*)table;

/**
 Get data in Datastore matching the query.
 
 @param luceneQuery Lucene-like query used to match.
 @param sortKey Lucene-like sort clauses used to order search results. Can be null.
 @param table Table name to search.
 */
- (PMKPromise*)datastoreSearchWithQuery:(NSString*)luceneQuery sort:(NSString*)sortKey inTable:(NSString*)table;

/**
 Get data in Datastore matching the query.
 
 @param luceneQuery Lucene-like query used to match.
 @param sortKey Lucene-like sort clauses used to order search results. Can be null.
 @param limit Maximum number of results to return.
 @param table Table name to search.
 */
- (PMKPromise*)datastoreSearchWithQuery:(NSString*)luceneQuery sort:(NSString*)sortKey limit:(NSNumber*)limit inTable:(NSString*)table;

/**
 Get data in Datastore matching the query. Use this to paginate the results.
 
 @param luceneQuery Lucene-like query used to match.
 @param sortKey Lucene-like sort clauses used to order search results. Can be null.
 @param limit Maximum number of results to return.
 @param offset Starting position of the result.
 @param table Table name to search.
 */
- (PMKPromise*)datastoreSearchWithQuery:(NSString*)luceneQuery sort:(NSString*)sortKey limit:(NSNumber*)limit offset:(NSNumber*)offset inTable:(NSString*)table;

/**
 Retrieve a specific key from the given Datastore table, where the key has no owner set.
 
 @param key Data in Datastore in the given key. Alphanumeric characters only.
 @param table Table name to retrieve data from.
 */
- (PMKPromise*)datastoreGetKey:(NSString*)key inTable:(NSString*)table;

/**
 Get data in a table matching the given key.
 
 @param key Data in Datastore in the given key. Alphanumeric characters only.
 @param owner The owner to retrieve the key for. Must be a Gamer ID, or the value “me” representing the current user.
 @param table Table name to retrieve data from.
 */
- (PMKPromise*)datastoreGetKey:(NSString*)key fromOwner:(NSString*)owner inTable:(NSString*)table;

/**
 Get data in Datastore matching the given key.
 
 @param data dictionary key-value pairs.
 @param key Data in Datastore in the given key. Alphanumeric characters only.
 @param table Table name to insert data into.
 */
- (PMKPromise*)datastorePutData:(NSDictionary*)data withKey:(NSString*)key inTable:(NSString*)table;

/**
 Get data in Datastore matching the given key.
 
 @param data dictionary key-value pairs.
 @param key Data in Datastore in the given key. Alphanumeric characters only.
 @param permission Set permissions for this key.
 @param table Table name to insert data into.
 */
- (PMKPromise*)datastorePutData:(NSDictionary*)data withKey:(NSString*)key withPermission:(enum HLDatastorePermission)permission inTable:(NSString*)table;

/**
 Partially update data in Datastore for the given key.
 - If data doesn't exist, it will be added
 - If data exists, then the matching portion will be overwritten
 - If data exists, but new data is 'null' then the matching portion will be erased.
 
 @param key Data in Datastore in the given key. Alphanumeric characters only.
 @param table Table name to insert data into.
 */
- (PMKPromise*)datastoreUpdateData:(NSDictionary*)data withKey:(NSString*)key inTable:(NSString*)table;

/**
 Partially update data in Datastore for the given key.
 - If data doesn't exist, it will be added
 - If data exists, then the matching portion will be overwritten
 - If data exists, but new data is 'null' then the matching portion will be erased.
 
 @param key Data in Datastore in the given key. Alphanumeric characters only.
 @param permission Set permissions for this key.
 @param table Table name to insert data into.
 */
- (PMKPromise*)datastoreUpdateData:(NSDictionary*)data withKey:(NSString*)key withPermission:(enum HLDatastorePermission)permission inTable:(NSString*)table;

/**
 Delete data in the Public region of Datastore matching the given key.
 
 @param key Data in Datastore in the given key. Alphanumeric characters only.
 @param table Table name to delete data from.
 */
- (PMKPromise*)datastoreDeleteKey:(NSString*)key inTable:(NSString*)table;

@end