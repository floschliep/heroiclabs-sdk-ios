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

#import "HLDatastoreObject.h"

@implementation HLDatastoreSearchResult

- (id)initWithDictionary:(NSDictionary*) dictionary
{
    self = [super init];
    if (self) {
        _count = [dictionary valueForKey:@"count"];
        _totalCount = [dictionary valueForKey:@"total_count"];
        id objects = [[NSMutableArray alloc] init];
        for(id entry in [dictionary valueForKey:@"results"]) {
            [objects addObject:[[HLDatastoreObject alloc] initWithDictionary:entry]];
        }
        _results = [NSArray arrayWithArray:objects];
    }
    return self;
}
@end

@implementation HLDatastoreMetadata

- (id)initWithDictionary:(NSDictionary*) dictionary
{
    self = [super init];
    if (self) {
        _key = [dictionary valueForKey:@"key"];
        _owner = [dictionary valueForKey:@"owner"];
        _updatedAt = [dictionary valueForKey:@"updated_at"];
        _createdAt = [dictionary valueForKey:@"created_at"];
        _schemaVersion = [[dictionary valueForKey:@"schema"] valueForKey:@"version"];
        
        NSNumber* read = [[dictionary valueForKey:@"permissions"] valueForKey:@"read"];
        NSNumber* write = [[dictionary valueForKey:@"permissions"] valueForKey:@"write"];
        
        NSNumber* zero = [NSNumber numberWithInt:0];
        NSNumber* one = [NSNumber numberWithInt:1];
        NSNumber* two = [NSNumber numberWithInt:2];
        
        if (read == one && write == zero) {
            _permission = READ_ONLY;
        } else if (read == zero && write == one) {
            _permission = WRITE_ONLY;
        } else if (read == one && write == one) {
            _permission = READ_WRITE;
        } else if (read == two && write == zero) {
            _permission = PUBLIC_READ;
        } else if (read == two && write == one) {
            _permission = PUBLIC_READ_OWNER_WRITE;
        } else {
            _permission = NONE;
        }
        
    }
    return self;
}
@end

@implementation HLDatastoreObject

- (id)initWithDictionary:(NSDictionary*) dictionary
{
    self = [super init];
    if (self) {
        _metadata = [[HLDatastoreMetadata alloc] initWithDictionary:[dictionary valueForKey:@"metadata"]];
        _data = [dictionary valueForKey:@"data"];
        
    }
    return self;
}
@end