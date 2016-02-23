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

#import "HLGameCenterCredentials.h"

@implementation HLGameCenterCredentials

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _playerId = [dictionary objectForKey:@"player_id"];
        _bundleId = [dictionary objectForKey:@"bundle_id"];
        _timestamp = [dictionary objectForKey:@"timestamp"];
        _salt = [dictionary objectForKey:@"salt"];
        _signature = [dictionary objectForKey:@"signature"];
        _publicKeyUrl = [dictionary objectForKey:@"public_key_url"];
    }
    return self;
}

- (NSDictionary*)toDictionary
{
    return @{
             @"player_id"       :   _playerId,
             @"bundle_id"       :   _bundleId,
             @"timestamp"       :   _timestamp,
             @"salt"            :   [_salt base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed],
             @"signature"       :   [_signature base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed],
             @"public_key_url"  :   [_publicKeyUrl absoluteString]
             };
}

@end