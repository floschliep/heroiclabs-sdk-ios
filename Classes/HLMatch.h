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
 Represents a response containing Heroic Labs Multiplayer Match with its metadata.
 */
@interface HLMatch : NSObject <HLJSONSerialisableProtocol>

/**
 Nickname set for the current gamer in this given match
 If the current gamer's nickname is changed after the match is setup,
 the old nickname is still used hence the use of this 'whoami' field.
 */
@property(readonly) NSString* whoami;

/** Match ID */
@property(readonly) NSString* matchId;

/** Match Filters */
@property(readonly) NSArray<NSString*>* filters;

/** Current turn number */
@property(readonly) NSNumber* turnCount;

/** Name of gamer for the given turn */
@property(readonly) NSString* turn DEPRECATED_ATTRIBUTE DEPRECATED_MSG_ATTRIBUTE("use turnGamerId");

/** Gamer ID for the given turn */
@property(readonly) NSString* turnGamerId;

/** Nickname of all the gamers in the current match */
@property(readonly) NSArray<NSString*>* gamers DEPRECATED_ATTRIBUTE DEPRECATED_MSG_ATTRIBUTE("use activeGamers");

/** Map of Gamer Nickname to Gamer IDs */
@property(readonly) NSDictionary* activeGamers;

/** When the match was created */
@property(readonly) NSNumber* createdAt;

/** When the match was last updatedAt */
@property(readonly) NSNumber* updatedAt;

/** Checks to see if the match is still ongoing or has ended. */
@property(readonly) BOOL active;

@end