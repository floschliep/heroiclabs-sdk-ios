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

#import "HLGame.h"

@implementation HLGame

- (id)initWithDictionary:(NSDictionary*) dictionary
{
    self = [super init];
    if (self) {
        _name = [dictionary objectForKey:@"name"];
        _desc = [dictionary objectForKey:@"description"];
        _createdAt = [dictionary objectForKey:@"created_at"];
        _updatedAt = [dictionary objectForKey:@"updated_at"];
    }
    return self;
}
@end
