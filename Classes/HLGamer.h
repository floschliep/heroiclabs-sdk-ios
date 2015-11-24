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
 Represents a gamer profile in the Heroic Labs service.
 */
@interface HLGamerProfile : NSObject <HLJSONSerialisableProtocol>

typedef NS_ENUM(NSInteger, HLGamerProfileType)
{
    _UNKNOWN,
    ANONYMOUS,
    EMAIL,
    FACEBOOK,
    GOOGLE,
    TANGO
};

/** Unique GamerProfile ID. */
@property(readonly) NSString* profileId;

/** Type of gamer profile. */
@property(readonly) HLGamerProfileType type;

/** When the gamer profile was created. */
@property(readonly) NSNumber* createdAt;

@end

/**
 Represents a gamer in the Heroic Labs service.
 */
@interface HLGamer : NSObject <HLJSONSerialisableProtocol>

/** Unique Gamer ID. */
@property(readonly) NSString* gamerId;

/** Nickname, intended for easy public display. */
@property(readonly) NSString* nickname;

/** Linked profiles of this gamer. */
@property(readonly) NSArray<HLGamerProfile*>* profiles;

/** Gamer Name. */
@property(readonly) NSString* name;

/** Gamer Email Address. */
@property(readonly) NSString* email;

/** Time zone of the gamer. */
@property(readonly) NSString* timezone;

/** Location of the gamer. */
@property(readonly) NSString* location;

/** Gender of the gamer. */
@property(readonly) NSString* gender;

/** When the gamer first registered with Heroic Labs. */
@property(readonly) NSNumber* createdAt;

/** When the gamer's profile was last updated. */
@property(readonly) NSNumber* updatedAt;

@end