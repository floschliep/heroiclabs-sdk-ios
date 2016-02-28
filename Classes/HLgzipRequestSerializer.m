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
 
 Based on the work of AFgzipRequestSerializer.h
 */

#import "HLgzipRequestSerializer.h"

#import "NSData+GZIP.h"

@interface HLgzipRequestSerializer ()
@property (readwrite, nonatomic, strong) id <AFURLRequestSerialization> serializer;
@end

@implementation HLgzipRequestSerializer

+ (instancetype)serializerWithSerializer:(id<AFURLRequestSerialization>)serializer {
    HLgzipRequestSerializer *gzipSerializer = [self serializer];
    gzipSerializer.serializer = serializer;
    
    return gzipSerializer;
}

#pragma mark - AFURLRequestSerialization

- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request
                               withParameters:(id)parameters
                                        error:(NSError * __autoreleasing *)error
{
    NSError *serializationError = nil;
    NSMutableURLRequest *mutableRequest = [[self.serializer requestBySerializingRequest:request withParameters:parameters error:&serializationError] mutableCopy];
    
    [self.HTTPRequestHeaders enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
        if (![request valueForHTTPHeaderField:field]) {
            [mutableRequest setValue:value forHTTPHeaderField:field];
        }
    }];
    
    if (!serializationError && mutableRequest.HTTPBody) {
        NSData *compressedData = [mutableRequest.HTTPBody gzippedData];
        
        if (compressedData != nil) {
            [mutableRequest setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
            [mutableRequest setHTTPBody:compressedData];
        }
    } else {
        if (error) {
            *error = serializationError;
        }
    }
    
    return mutableRequest;
}

#pragma mark - NSCoder

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.serializer = [decoder decodeObjectForKey:NSStringFromSelector(@selector(serializer))];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeObject:self.serializer forKey:NSStringFromSelector(@selector(serializer))];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    HLgzipRequestSerializer *serializer = [[[self class] allocWithZone:zone] init];
    serializer.serializer = self.serializer;
    
    return serializer;
}

@end