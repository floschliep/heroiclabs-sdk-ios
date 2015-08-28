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

#import "HLLeaderboard.h"

@implementation HLLeaderboardReset

- (id)initWithDictionary:(NSDictionary*) dictionary
{
    self = [super init];
    if (self) {
        _utcHour = [dictionary objectForKey:@"utc_hour"];
        
        _type = DAILY;
        if ([@"monthly" isEqualToString:[dictionary valueForKey:@"type"]]) {
            _type = MONTHLY;
            _dayOfMonth = [dictionary objectForKey:@"day_of_month"];
        } else if ([@"weekly" isEqualToString:[dictionary valueForKey:@"type"]]) {
            _type = MONTHLY;
            _dayOfWeek = [dictionary objectForKey:@"day_of_week"];
        }
    }
    return self;
}

@end

@implementation HLLeaderboardEntry

- (id)initWithDictionary:(NSDictionary*) dictionary
{
    self = [super init];
    if (self) {
        _name = [dictionary objectForKey:@"name"];
        _score = [dictionary objectForKey:@"score"];
        _scoreAt = [dictionary objectForKey:@"score_at"];
    }
    return self;
}
@end

@implementation HLLeaderboard

- (id)initWithDictionary:(NSDictionary*) dictionary
{
    self = [super init];
    if (self) {
        _leaderboardId = [dictionary objectForKey:@"leaderboard_id"];
        _type = RANKING;
        _name = [dictionary objectForKey:@"name"];
        _publicId = [dictionary objectForKey:@"public_id"];
        
        _sort = ASCENDING;
        if ([@"desc" isEqualToString:[dictionary valueForKey:@"sort"]]) {
            _sort = DESCENDING;
        }
        
        //optional
        for (NSString* key in dictionary) {
            if ([dictionary objectForKey:key] == nil || [dictionary objectForKey:key] == (id)[NSNull null]) {
                continue;
            }
            
            if ([@"tags" isEqualToString:key]) {
                _tags = [dictionary objectForKey:key];
            } else if ([@"score_limit" isEqualToString:key]) {
                _scoreLimit = [dictionary objectForKey:key];
            } else if ([@"limit" isEqualToString:key]) {
                _limit = [dictionary objectForKey:key];
            } else if ([@"offset" isEqualToString:key]) {
                _offset = [dictionary objectForKey:key];
            } else if ([@"display_hint" isEqualToString:key]) {
                _displayHint = [dictionary objectForKey:key];
            } else if ([@"leaderboard_reset" isEqualToString:key]) {
                _reset = [[HLLeaderboardReset alloc] initWithDictionary:[dictionary objectForKey:key]];
            } else if ([@"scoretags" isEqualToString:key]) {
                _scoreTags = [dictionary objectForKey:key];
            } else if ([@"entries" isEqualToString:key]) {
                NSMutableArray* leaderboardEnteries = [[NSMutableArray alloc] init];
                NSArray* dics = [dictionary objectForKey:key];
                for(NSDictionary* entry in dics) {
                    [leaderboardEnteries addObject:[[HLLeaderboardEntry alloc] initWithDictionary:entry]];
                }
                _entries = [[NSArray alloc]initWithArray:leaderboardEnteries];
            }
        }
    }
    return self;
}

@end
