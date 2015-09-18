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

#import <AFNetworking/AFNetworking.h>
#import <PromiseKit/Promise.h>
#import <Base64nl/Base64.h>

#import "HLHttpClient.h"
#import "HLRequestRetryHandlerProtocol.h"
#import "HLSessionClient.h"
#import "HLPing.h"
#import "HLServer.h"
#import "HLGame.h"
#import "HLGamer.h"
#import "HLAchievement.h"
#import "HLLeaderboard.h"
#import "HLLeaderboardRank.h"
#import "HLMatch.h"
#import "HLMatchTurn.h"
#import "HLPurchaseVerification.h"

static NSString *const HEROICLABS_VERSION=@"0.1.0";
static NSString *const AFN_VERSION=@"AFN2.5.4";

static NSString *const USER_AGENT_NAME=@"heroiclabs-ios-sdk";

static NSString *USER_AGENT = nil;
static NSInteger REQUEST_TIMEOUT=30;

static NSDictionary *REQUEST_URLS = nil;
static NSDictionary *REQUEST_METHODS = nil;
static AFHTTPRequestOperationManager *NETWORK_MANAGER = nil;

@implementation HLHttpClient

+ (void)initialize
{
    REQUEST_METHODS = @{
                        @(HEAD) : @"HEAD",
                        @(GET): @"GET",
                        @(POST): @"POST",
                        @(PUT) : @"PUT",
                        @(PATCH) : @"PATCH",
                        @(DELETE) : @"DELETE"
                        };
    
    
    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString* secretAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSMutableString *USER_AGENT_MUTABLE = [[NSMutableString alloc] initWithString:USER_AGENT_NAME];
    [USER_AGENT_MUTABLE appendString:@"/"];
    [USER_AGENT_MUTABLE appendString:HEROICLABS_VERSION];
    [USER_AGENT_MUTABLE appendString:@" ("];
    [USER_AGENT_MUTABLE appendString:[[UIDevice currentDevice] systemName]];
    [USER_AGENT_MUTABLE appendString:@" "];
    [USER_AGENT_MUTABLE appendString:[[UIDevice currentDevice] systemVersion]];
    [USER_AGENT_MUTABLE appendString:@"; "];
    [USER_AGENT_MUTABLE appendString:AFN_VERSION];
    [USER_AGENT_MUTABLE appendString:@"; "];
    [USER_AGENT_MUTABLE appendString:secretAgent];
    [USER_AGENT_MUTABLE appendString:@")"];
    USER_AGENT = [[NSString alloc] initWithString:USER_AGENT_MUTABLE];
    
    NSURL *baseURL = [NSURL URLWithString:HEROICLABS_API_URL];
    NETWORK_MANAGER = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
}

+ (PMKPromise*)sendAccountsRequestTo:(NSString*)endpoint
                          withMethod:(enum HLRequestMethod)method
                          apiKey:(NSString*)apiKey
                           token:(NSString*)token
                          entity:(id)entity
                    retryHandler:(id<HLRequestRetryHandlerProtocol>)handler
                    successBlock:(void(^)(NSNumber* statusCode, id data, PMKResolver resolver))successCallback
{
    return [HLHttpClient sendRequestTo:HEROICLABS_ACCOUNTS_URL
                          withEndpoint:endpoint
                            withMethod:method
                            withApiKey:apiKey
                             withToken:token
                            withEntity:entity
                      withRetryHandler:handler
                      withSuccessBlock:successCallback];
}

+ (PMKPromise*)sendApiRequestTo:(NSString*)endpoint
                     withMethod:(enum HLRequestMethod)method
                     apiKey:(NSString*)apiKey
                      token:(NSString*)token
                     entity:(id)entity
               retryHandler:(id<HLRequestRetryHandlerProtocol>)handler
{
    return [HLHttpClient sendApiRequestTo:endpoint
                               withMethod:method
                               apiKey:apiKey
                                token:token
                               entity:entity
                         retryHandler:handler
                         successBlock:nil];
}

+ (PMKPromise*)sendApiRequestTo:(NSString*)endpoint
                     withMethod:(enum HLRequestMethod)method
                     apiKey:(NSString*)apiKey
                      token:(NSString*)token
                     entity:(id)entity
               retryHandler:(id<HLRequestRetryHandlerProtocol>)handler
               successBlock:(void(^)(NSNumber* statusCode, id data, PMKResolver resolver))successCallback
{
    return [HLHttpClient sendRequestTo:HEROICLABS_API_URL
                          withEndpoint:endpoint
                            withMethod:method
                            withApiKey:apiKey
                             withToken:token
                            withEntity:entity
                      withRetryHandler:handler
                      withSuccessBlock:successCallback];
}

+ (PMKPromise*)sendRequestTo:(NSString*)url
                withEndpoint:(NSString*)endpoint
                  withMethod:(enum HLRequestMethod)method
                  withApiKey:(NSString*)apiKey
                   withToken:(NSString*)token
                  withEntity:(id)entity
            withRetryHandler:(id<HLRequestRetryHandlerProtocol>)handler
            withSuccessBlock:(void(^)(NSNumber* statusCode, id data, PMKResolver resolver))successCallback
{
    NSMutableString *finalUrl = [[NSMutableString alloc] initWithString:url];
    [finalUrl appendString:endpoint];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:finalUrl]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:REQUEST_TIMEOUT];
    
    NSMutableString *authorization = [[NSMutableString alloc] initWithString:apiKey];
    [authorization appendString:@":"];
    [authorization appendString:token];
    
    NSMutableString *base64EncodedAuth = [[NSMutableString alloc] initWithString:@"Basic "];
    [base64EncodedAuth appendString:[authorization base64EncodedString]];
    
    [request setHTTPMethod:[REQUEST_METHODS objectForKey:@(method)]];
    [request setValue:base64EncodedAuth forHTTPHeaderField:@"Authorization"];
    [request setValue:USER_AGENT forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    if (method == PUT || method == POST || method == PATCH) {
        [request setHTTPBody:[HLHttpClient serialiseDictionaryToData:entity]];
    }
    
    return [HLHttpClient sendRequest:request
                    withRetryHandler:handler
                    withSuccessBlock:successCallback];
}

+ (PMKPromise*)sendRequest:(NSURLRequest*)request
          withRetryHandler:(id<HLRequestRetryHandlerProtocol>)retryHandler
          withSuccessBlock:(void(^)(NSNumber* statusCode, id data, PMKResolver resolver))successCallback;
{
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    return [PMKPromise promiseWithResolver:^(PMKResolver resolver) {
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
            [retryHandler requestSucceed:request];
            NSNumber* statusCode = @([[operation response] statusCode]);
            if (successCallback == nil) { //used mainly for 204s
                resolver(JSON);
            } else {
                successCallback(statusCode, JSON, resolver);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSHTTPURLResponse *response = [operation response];
            
            if ([response statusCode] >= 500) {
                [retryHandler requestFailed:request];
                if ([retryHandler shouldRetryRequest:request]) {
                    [HLHttpClient sendRequest:request
                             withRetryHandler:retryHandler
                             withSuccessBlock:successCallback];
                } else {
                    resolver(error);
                }
            } else {
                [retryHandler requestSucceed:request];
                resolver(error);
            }
        }];
        [NETWORK_MANAGER.operationQueue addOperation:op];
    }];
}

+ (NSData*)serialiseDictionaryToData:(NSDictionary*)dict
{
    NSError *error = nil;
    NSData *json = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    return json;
}
@end
