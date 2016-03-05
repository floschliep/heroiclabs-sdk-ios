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

#import <AFNetworking/AFURLRequestSerialization.h>

/**
 `HLgzipRequestSerializer` applies gzip compression to requests generated by a specified serializer, setting the appropriate `Content-Encoding` header.
 */
@interface HLgzipRequestSerializer : AFHTTPRequestSerializer

/**
 The serializer used to generate requests to be compressed.
 */
@property (readonly, nonatomic, strong) id <AFURLRequestSerialization> serializer;

/**
 Creates and returns an instance of `AFgzipRequestSerializer`, using the specified serializer to generate requests to be compressed.
 */
+ (instancetype)serializerWithSerializer:(id <AFURLRequestSerialization>)serializer;

@end