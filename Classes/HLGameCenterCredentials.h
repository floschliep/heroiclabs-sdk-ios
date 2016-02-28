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
 Represents interface for integrating GameCenter credentials with the Heroic Labs service.
 
 Because the SDK doesn't have a dependency on GameKit, you'll need to pass the correct information to this class to allow remote authentication of the player on the Heroic Labs server. 
 
 You'll need to use `GKLocalPlayer.generateIdentityVerificationSignatureWithCompletionHandler` to capture most of the information required in this class.
 */
@interface HLGameCenterCredentials : NSObject <HLJSONSerialisableProtocol>

/** GameCenter Player ID. */
@property (readwrite) NSString* playerId;

/** Application Bundle ID. */
@property (readwrite) NSString* bundleId;

/** GKPlayer Authentication Timestamp. */
@property (readwrite) NSNumber* timestamp;

/** GKPlayer Authentication Salt. */
@property (readwrite) NSData* salt;

/** GKPlayer Authentication Signature. */
@property (readwrite) NSData* signature;

/** GKPlayer Authentication publicKeyUrl. */
@property (readwrite) NSURL* publicKeyUrl;

@end