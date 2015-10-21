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

#import <Foundation/Foundation.h>
#import "HLJSONSerialisableProtocol.h"

/**
 Represents shared storage data
 */
@interface HLSharedStorageSearchResults : NSObject <HLJSONSerialisableProtocol>

/** The number of shared storage data returned as part of this response. */
@property(readonly) NSNumber* count;

/** The total number of shared storage data available on the server. */
@property(readonly) NSNumber* totalCount;

/** Retrieved search results of type HLSharedStorageObject */
@property(readonly) NSArray* results;

@end

@interface HLSharedStorageObject : NSObject <HLJSONSerialisableProtocol>

/** Public portion of search result. */
@property(readonly) NSDictionary* publicData;

/** Protected portion of search result. */
@property(readonly) NSDictionary* protectedData;

@end