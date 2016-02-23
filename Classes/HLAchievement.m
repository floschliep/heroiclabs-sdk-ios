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

#import "HLAchievement.h"

@implementation HLAchievement

- (id)initWithDictionary:(NSDictionary*) dictionary
{
    self = [super init];
    if (self) {
        _publicId = [dictionary valueForKey:@"public_id"];
        _name = [dictionary valueForKey:@"name"];
        _desc = [dictionary valueForKey:@"description"];
        _points = [dictionary valueForKey:@"points"];
        _requiredCount = [dictionary valueForKey:@"required_count"];
        _count = 0;
        if ([dictionary objectForKey:@"count"] != nil) {
            _count = [dictionary valueForKey:@"count"];
        }
        
        _type = NORMAL;
        if ([@"incremental" isEqualToString:[dictionary valueForKey:@"type"]]) {
            _type = INCREMENTAL;
        }
        _state = VISIBLE;
        if ([@"hidden" isEqualToString:[dictionary valueForKey:@"state"]]) {
            _state = HIDDEN;
        } else if ([@"secret" isEqualToString:[dictionary valueForKey:@"state"]]) {
            _state = SECRET;
        }
        
        if ([dictionary objectForKey:@"completed_at"] != nil) {
            _completedAt = [dictionary valueForKey:@"completed_at"];
        }
        if ([dictionary objectForKey:@"progress_at"] != nil) {
            _progressAt = [dictionary valueForKey:@"progress_at"];
        }
    }
    return self;
}

- (BOOL)isAchievementUnlocked
{
    return (_completedAt || _completedAt > 0);
}
@end
