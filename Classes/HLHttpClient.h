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
#import <PromiseKit/Promise.h>
#import "HLRequestRetryHandlerProtocol.h"

static NSString * const HLHttpErrorDomain = @"com.heroiclabs.errors.http";
static NSString * const HLHttpErrorResponseKey = @"com.heroiclabs.errors.http.response";
static NSString * const HLHttpErrorResponseDataKey = @"com.heroiclabs.errors.http.response.data";

static NSString * const HEROICLABS_ACCOUNTS_URL = @"https://accounts.heroiclabs.com";
static NSString * const HEROICLABS_API_URL = @"https://api.heroiclabs.com";

typedef NS_ENUM(NSInteger, HLRequestMethod)
{
    HEAD,
    GET,
    PUT,
    POST,
    PATCH,
    DELETE
};

@interface HLHttpClient : NSObject

+ (void)setAccountsUrl:(NSString*)url;
+ (void)setApiUrl:(NSString*)url;

+ (PMKPromise*)sendAccountsRequestTo:(NSString*)endpoint
                          withMethod:(enum HLRequestMethod)method
                              apiKey:(NSString*)apikeyToUse
                               token:(NSString*)token
                              entity:(id)entity
                        retryHandler:(id<HLRequestRetryHandlerProtocol>)handler
                        successBlock:(void(^)(NSNumber* statusCode, id data, PMKResolver resolver))successCallback;

+ (PMKPromise*)sendApiRequestTo:(NSString*)endpoint
                     withMethod:(enum HLRequestMethod)method
                         apiKey:(NSString*)apiKey
                          token:(NSString*)token
                         entity:(id)entity
                   retryHandler:(id<HLRequestRetryHandlerProtocol>)handler;

+ (PMKPromise*)sendApiRequestTo:(NSString*)endpoint
                     withMethod:(enum HLRequestMethod)method
                         apiKey:(NSString*)apikeyToUse
                          token:(NSString*)token
                         entity:(id)entity
                   retryHandler:(id<HLRequestRetryHandlerProtocol>)handler
                   successBlock:(void(^)(NSNumber* statusCode, id data, PMKResolver resolver))successCallback;


@end