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

static NSString *const HEROICLABS_VERSION=@"0.5.2";
static NSString *const AFN_VERSION=@"AFN3.0.0-beta.2";

static NSString *const USER_AGENT_NAME=@"heroiclabs-ios-sdk";
static NSString *USER_AGENT = nil;

@implementation HLHttpClient

static NSURL *baseURL;

+ (void)initialize
{
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
    
    baseURL = [NSURL URLWithString:HEROICLABS_API_URL];
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
            withRetryHandler:(id<HLRequestRetryHandlerProtocol>)retryHandler
            withSuccessBlock:(void(^)(NSNumber* statusCode, id data, PMKResolver resolver))successCallback
{
    NSMutableString *fullUrl = [[NSMutableString alloc] initWithString:url];
    [fullUrl appendString:endpoint];
    NSString* finalUrl = [fullUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableString *authorization = [[NSMutableString alloc] initWithString:apiKey];
    [authorization appendString:@":"];
    [authorization appendString:token];
    
    NSMutableString *base64EncodedAuth = [[NSMutableString alloc] initWithString:@"Basic "];
    [base64EncodedAuth appendString:[[authorization dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]];
    
    AFJSONRequestSerializer* requestSerializer = [[AFJSONRequestSerializer alloc] init];
    [requestSerializer setValue:base64EncodedAuth forHTTPHeaderField:@"Authorization"];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestSerializer setValue:USER_AGENT forHTTPHeaderField:@"User-Agent"];

    AFHTTPSessionManager *networkManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    networkManager.requestSerializer = requestSerializer;
    
    return [PMKPromise promiseWithResolver:^(PMKResolver resolver) {
        [HLHttpClient sendRequestTo:finalUrl withEndpoint:endpoint withMethod:method withEntity:entity withNetworkManager:networkManager withRetryHandler:retryHandler withSuccessBlock:successCallback withResolver:resolver];
    }];
}

+ (void) sendRequestTo:(NSString*)finalUrl
          withEndpoint:(NSString*)endpoint
            withMethod:(enum HLRequestMethod)method
            withEntity:(id)entity
    withNetworkManager:(AFHTTPSessionManager*)networkManager
      withRetryHandler:(id<HLRequestRetryHandlerProtocol>)retryHandler
      withSuccessBlock:(void(^)(NSNumber* statusCode, id data, PMKResolver resolver))successCallback
          withResolver:(PMKResolver)resolver
{

    
    void (^httpSuccess)(NSURLSessionDataTask *task, id responseObject) = ^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull JSON) {
        [retryHandler requestSucceed:[task originalRequest]];
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSNumber* statusCode = @([response statusCode]);
        if (successCallback == nil) { //used mainly for 204s
            resolver(JSON);
        } else {
            successCallback(statusCode, JSON, resolver);
        }
    };
    void (^httpHeadSuccess)(NSURLSessionDataTask *task) = ^(NSURLSessionDataTask * _Nonnull task) {
        httpSuccess(task, nil);
    };
    void (^httpFailure)(NSURLSessionDataTask *task, NSError *error) = ^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
//        NSURLRequest *request = [task originalRequest];
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        
//        if ([response statusCode] == 500) {
//            [retryHandler requestFailed:request];
//            if ([retryHandler shouldRetryRequest:request]) {
//                [HLHttpClient sendRequestTo:finalUrl withEndpoint:endpoint withMethod:method withEntity:entity withNetworkManager:networkManager withRetryHandler:retryHandler withSuccessBlock:successCallback withResolver:resolver];
//            } else {
//                resolver([HLHttpClient createNewHttpError:error andStatusCode:[response statusCode]]);
//            }
//        } else {
//            [retryHandler requestSucceed:request];
            resolver([HLHttpClient createNewHttpError:error andStatusCode:[response statusCode]]);
//        }
    };
    
    switch (method) {
        case HEAD:
            [networkManager HEAD:finalUrl parameters:entity success:httpHeadSuccess failure:httpFailure];
            break;
        case GET:
            [networkManager GET:finalUrl parameters:entity success:httpSuccess failure:httpFailure];
            break;
        case DELETE:
            [networkManager DELETE:finalUrl parameters:entity success:httpSuccess failure:httpFailure];
            break;
        case PUT:
            [networkManager PUT:finalUrl parameters:entity success:httpSuccess failure:httpFailure];
            break;
        case POST:
            [networkManager POST:finalUrl parameters:entity success:httpSuccess failure:httpFailure];
            break;
        case PATCH:
            [networkManager PATCH:finalUrl parameters:entity success:httpSuccess failure:httpFailure];
            break;
    }
}

+ (NSError*)createNewHttpError:(NSError*)error andStatusCode:(NSInteger) statusCode
{
    NSDictionary *userInfo = [error userInfo];
    if ([[error domain] isEqualToString:AFURLResponseSerializationErrorDomain]) {
        NSDictionary* jsonError = [NSJSONSerialization JSONObjectWithData:[[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey]
                                                                  options:kNilOptions
                                                                    error:nil];
        userInfo = @{
                     NSLocalizedDescriptionKey:[[error userInfo] objectForKey:NSLocalizedDescriptionKey],
                     NSURLErrorFailingURLStringErrorKey:[[error userInfo] objectForKey:@"NSErrorFailingURLKey"],
                     HLHttpErrorResponseKey: [[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey],
                     HLHttpErrorResponseDataKey:jsonError,
                     };
    } else {
        statusCode = 500;
    }
    return [NSError errorWithDomain:HLHttpErrorDomain code:statusCode userInfo:userInfo];
}
@end
