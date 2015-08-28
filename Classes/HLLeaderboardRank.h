/*
 * Copyright 2014-2015 Heroic Labs
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>
#import "HLJSONSerialisableProtocol.h"

/**
 * Represents a gamer's detailed standing on a leaderboard.
 */
@interface HLLeaderboardRank : NSObject <HLJSONSerialisableProtocol>

/** Nickname, suitable for public display. */
@property(readonly) NSString* name;

/** Score tags. */
@property(readwrite) NSDictionary* scoreTags;

/** Most up to date rank. */
@property(readonly) NSNumber* rank;

/** When the latest rank was calculated. */
@property(readonly) NSNumber* rankAt;

/** The best score the gamer has entered on this leaderboard. */
@property(readonly) NSNumber* score;

/** When the best score was recorded. */
@property(readonly) NSNumber* scoreAt;

/**
 * If this data is in response to a leaderboard submission, and the score
 * submitted replaces the previous one, this field will contain that
 * previous value.
 */
@property(readonly) NSNumber* lastScore;

/** When the previous score was submitted. */
@property(readonly) NSNumber* lastScoreAt;

/** What the rank on this leaderboard was when it was previously checked. */
@property(readonly) NSNumber* lastRank;

/** When the previous rank was calculated. */
@property(readonly) NSNumber* lastRankAt;

/** The highest rank this gamer has ever had on this leaderboard. */
@property(readonly) NSNumber* bestRank;

/** When the highest rank was recorded. */
@property(readonly) NSNumber* bestRankAt;

/**
 * @return true if this is the first time the current gamer appears on this
 *         leaderboard, false otherwise.
 */
-(BOOL)isNew;

/**
 * @return true if the response indicates the gamer has a new best score on
 *         this leaderboard, false otherwise.
 */
-(BOOL)isNewScore;

/**
 * @return true if the rank has changed since it was last checked,
 *         regardless if it's now higher or lower, false otherwise.
 */
-(BOOL)isNewRank;


/**
 * @return true if this response contains a new all-time best rank on this
 *         leaderboard, false otherwise.
 */
-(BOOL)isNewBestRank;

@end
