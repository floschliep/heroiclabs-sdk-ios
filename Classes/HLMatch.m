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

#import "HLMatch.h"

@implementation HLMatch

- (id)initWithDictionary:(NSDictionary*) dictionary
{
    self = [super init];
    if (self) {
        _matchId = [dictionary valueForKey:@"match_id"];
        _filters = [dictionary valueForKey:@"filters"];
        _createdAt = [dictionary valueForKey:@"created_at"];
        _updatedAt = [dictionary valueForKey:@"updated_at"];
        _gamers = [dictionary valueForKey:@"gamers"];
        _activeGamers = [dictionary valueForKey:@"active_gamers"];
        _active = [[dictionary valueForKey:@"active"] boolValue];
        _turn = [dictionary valueForKey:@"turn"];
        _turnGamerId = [dictionary valueForKey:@"turn_gamer_id"];
        _turnCount = [dictionary valueForKey:@"turn_count"];
        _whoami = [dictionary valueForKey:@"whoami"];
        _whoamiGamerId = [dictionary valueForKey:@"whoami_gamer_id"];
    }
    return self;
}
@end