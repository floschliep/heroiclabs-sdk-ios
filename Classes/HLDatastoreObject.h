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
#import "HLJSONSerialisableProtocol.h"

/**
 Datastore Permissions
 */
typedef NS_ENUM(NSInteger, HLDatastorePermission)
{
    NONE = 1,
    READ_ONLY = 2,
    WRITE_ONLY = 3,
    READ_WRITE = 4,
    PUBLIC_READ = 5,
    PUBLIC_READ_OWNER_WRITE = 6,
    INHERIT = 0
};

/**
 Represents Datastore Object
 */
@interface HLDatastoreMetadata : NSObject <HLJSONSerialisableProtocol>

/** Key name. */
@property(readonly) NSString* key;

/** Owner of the data. This can be null. */
@property(readonly) NSString* owner;

/** Schema Version of this data. */
@property(readonly) NSNumber* schemaVersion;

/** When this data was last updated. */
@property(readonly) NSNumber* updatedAt;

/** When this data was first stored. */
@property(readonly) NSNumber* createdAt;

/** Permissions on this key. */
@property(readonly) HLDatastorePermission permission;

@end

/**
 Represents Datastore Object
 */
@interface HLDatastoreObject : NSObject <HLJSONSerialisableProtocol>

/** Metadata stored for this object. */
@property(readonly) HLDatastoreMetadata* metadata;

/**  Data stored in this object. */
@property(readonly) NSDictionary* data;

@end

/**
 Represents Datastore storage results
 */
@interface HLDatastoreSearchResult : NSObject <HLJSONSerialisableProtocol>

/** The number of Datastore objects returned as part of this response. */
@property(readonly) NSNumber* count;

/** The total number of Datastore objects available on the server. */
@property(readonly) NSNumber* totalCount;

/** Retrieved search results of type HLDatastoreObject */
@property(readonly) NSArray<HLDatastoreObject*>* results;

@end