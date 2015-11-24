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
 The reset information for a daily, weekly, or monthly leaderboard.
 */
@interface HLLeaderboardReset : NSObject <HLJSONSerialisableProtocol>

typedef NS_ENUM(NSInteger, HLResetType)
{
    DAILY,
    WEEKLY,
    MONTHLY
};

/** Leaderboard Reset Type - daily, weekly or monthly. */
@property(readonly) HLResetType type;

/** Leaderboard Reset UTC Hour */
@property(readonly) NSNumber* utcHour;

/** Leaderboard Reset Day in a week; will be 0 if unset. */
@property(readonly) NSNumber* dayOfWeek;

/** Leaderboard Reset Day in a month; will be 0 if unset. */
@property(readonly) NSNumber* dayOfMonth;

@end

/**
 Represents a Leadeboard gamer data
 */
@interface HLLeaderboardEntry : NSObject <HLJSONSerialisableProtocol>

/** Nickname, suitable for public display. */
@property(readonly) NSString* name;

/** Score. */
@property(readonly) NSNumber* score;

/** When the score was submitted to this leaderboard. */
@property(readonly) NSNumber* scoreAt;

@end

/**
 Represents a Leaderboards' metadata with leaderboard enteries.
 */
@interface HLLeaderboard : NSObject <HLJSONSerialisableProtocol>

typedef NS_ENUM(NSInteger, HLLeaderboardSort)
{
    ASCENDING,
    DESCENDING
};

typedef NS_ENUM(NSInteger, HLLeaderboardType)
{
    RANKING
};

/** Leaderboard public identifier. */
@property(readwrite) NSString* leaderboardId;

/** Leaderboard display name. */
@property(readwrite) NSString* name;

/** Leaderboard score tags. */
@property(readwrite) NSDictionary* scoreTags;

/** Leaderboard public identifier. */
@property(readwrite) NSString* publicId;

/** Sort order indicator. */
@property(readwrite) HLLeaderboardSort sort;

/** Type indicator. */
@property(readwrite) HLLeaderboardType type;

/** Leaderboard display hint. */
@property(readwrite) NSString* displayHint;

/** Leaderboard tags */
@property(readwrite) NSArray<NSString*>* tags;

/** Leaderboard score limit */
@property(readwrite) NSNumber* scoreLimit;

/** The limit on entries in the leaderboard. */
@property(readwrite) NSNumber* limit;

/** The current offset of the leaderboard entries. */
@property(readwrite) NSNumber* offset;

/** Leaderboard Reset configuration. */
@property(readwrite) HLLeaderboardReset* reset;

/**
 * The top ranked gamers on this board, up to 50. Already sorted according
 * to the leaderboard sort settings.
 */
@property(readwrite) NSArray<HLLeaderboardEntry*>* entries;

@end
