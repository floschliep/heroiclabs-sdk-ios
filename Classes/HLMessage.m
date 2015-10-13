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

#import "HLMessage.h"

@implementation HLMessage

- (id)initWithDictionary:(NSDictionary*) dictionary
{
    self = [super init];
    if (self) {
        _messageId = [dictionary objectForKey:@"message_id"];
        _tags = [dictionary objectForKey:@"tags"];
        _subject = [dictionary objectForKey:@"subject"];
        _body = [dictionary objectForKey:@"body"];
        _createdAt = [dictionary objectForKey:@"created_at"];
        _expiresAt = [dictionary objectForKey:@"expires_at"];
        _readAt = [dictionary objectForKey:@"read_at"];
    }
    return self;
}
@end
