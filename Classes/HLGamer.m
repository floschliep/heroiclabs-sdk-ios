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

#import "HLGamer.h"

@implementation HLGamerProfile
- (id)initWithDictionary:(NSDictionary*) dictionary
{
    self = [super init];
    if (self) {
        _profileId = [dictionary objectForKey:@"id"];
        _createdAt = [dictionary objectForKey:@"created_at"];
        id type = [dictionary objectForKey:@"type"];
        _type = _UNKNOWN;
        if ([@"anonymous" isEqualToString:type]) {
            _type = ANONYMOUS;
        } else if ([@"email" isEqualToString:type]) {
            _type = EMAIL;
        } else if ([@"facebook" isEqualToString:type]) {
            _type = FACEBOOK;
        } else if ([@"google" isEqualToString:type]) {
            _type = GOOGLE;
        } else if ([@"tango" isEqualToString:type]) {
            _type = TANGO;
        }
    }
    return self;
}
@end

@implementation HLGamer
- (id)initWithDictionary:(NSDictionary*) dictionary
{
    self = [super init];
    if (self) {
        _nickname = [dictionary objectForKey:@"nickname"];
        _gamerId = [dictionary objectForKey:@"gamer_id"];
        _name = [dictionary objectForKey:@"name"];
        _timezone = [dictionary objectForKey:@"timezone"];
        _location = [dictionary objectForKey:@"location"];
        _gender = [dictionary objectForKey:@"gender"];
        _email = [dictionary objectForKey:@"email"];
        _createdAt = [dictionary objectForKey:@"created_at"];
        _updatedAt = [dictionary objectForKey:@"updated_at"];
        
        if (_timezone == nil)
            _timezone = @"";
        if (_location == nil)
            _location = @"";
        if (_name == nil)
            _name = @"";
        if (_gender == nil)
            _gender = @"";
        
        NSMutableArray* profiles = [[NSMutableArray<HLGamerProfile*> alloc] init];
        NSArray* dics = [dictionary objectForKey:@"profiles"];
        for(NSDictionary* profile in dics) {
            [profiles addObject:[[HLGamerProfile alloc] initWithDictionary:profile]];
        }
        _profiles = [[NSArray<HLGamerProfile*> alloc] initWithArray:profiles];
    }
    return self;
}
@end
