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
@interface HLPurchaseVerification : NSObject <HLJSONSerialisableProtocol>

/** Whether or not the purchase was successfully verified. */
@property(readonly) BOOL success;

/** Whether or not there was an existing record of this transaction. */
@property(readonly) BOOL seenBefore;

/** Whether or not there was an existing record of this transaction. */
@property(readonly) BOOL purchaseProviderReachable;

/** A message indicating why the transaction verification was unsuccessful or rejected, if applicable. */
@property(readonly) NSString* message;

/** The raw Key/Value set returned from Google when the purchase verification was performed. */
@property(readonly) NSDictionary* data;

@end
