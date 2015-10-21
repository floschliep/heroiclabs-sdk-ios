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

#import "HLSharedStorageSearchResults.h"

@implementation HLSharedStorageSearchResults

- (id)initWithDictionary:(NSDictionary*) dictionary
{
    self = [super init];
    if (self) {
        _count = [dictionary valueForKey:@"count"];
        _totalCount = [dictionary valueForKey:@"total_count"];
        id objects = [[NSMutableArray alloc] init];
        for(id entry in [dictionary valueForKey:@"results"]) {
            [objects addObject:[[HLSharedStorageObject alloc] initWithDictionary:entry]];
        }
        _results = [NSArray arrayWithArray:objects];
    }
    return self;
}
@end

@implementation HLSharedStorageObject

- (id)initWithDictionary:(NSDictionary*) dictionary
{
    self = [super init];
    if (self) {
        _publicData = [dictionary valueForKey:@"public"];
        _protectedData = [dictionary valueForKey:@"protected"];
        
    }
    return self;
}
@end