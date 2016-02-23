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
 Represents a game on the Heroic Labs service.
 */
@interface HLGame : NSObject <HLJSONSerialisableProtocol>

/** Game's registered display name. */
@property(readonly) NSString* name;

/** Game description text. */
@property(readonly) NSString* desc;

/** Timestamp when the game was created. */
@property(readonly) NSNumber* createdAt;

/** Timestamp when game details were last changed or updated. */
@property(readonly) NSNumber* updatedAt;

@end
