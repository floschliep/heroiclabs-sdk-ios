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
#import "HLMatch.h"
#import "HLMatchTurn.h"

/**
 Represents changes in a match
 */
@interface HLMatchChange : NSObject <HLJSONSerialisableProtocol>
/** Updated Match */
@property(readonly) HLMatch* match;

/** Array of turn data since the requested timestamp. */
@property(readonly) NSArray<HLMatchTurn*>* changedTurns;
@end