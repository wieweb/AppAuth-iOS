/*! @file OIDURLSessionProvider.m
 @brief AppAuth iOS SDK
 @copyright
 Copyright 2015 Google Inc. All Rights Reserved.
 @copydetails
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

#import "OIDURLSessionProvider.h"

NS_ASSUME_NONNULL_BEGIN

static NSURLSession *__nullable gURLSession;
static NSString *__nullable OIDURLSessionProviderTrustedHost = nil;

@implementation OIDURLSessionProvider

+ (id)sharedProvider {
    static OIDURLSessionProvider *sharedOIDURLSessionProvider = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedOIDURLSessionProvider = [[self alloc] init];
    });
    return sharedOIDURLSessionProvider;
}

- (id)init {
  if (self = [super init]) {
  }
  return self;
}

+ (nullable NSString *)trustedHost {
  return OIDURLSessionProviderTrustedHost;
}

+ (void)setTrustedHost:(nullable NSString *)newTrustedHost {
  if(OIDURLSessionProviderTrustedHost != newTrustedHost) {
    OIDURLSessionProviderTrustedHost = newTrustedHost;
  }
}

- (NSURLSession *)session {
    if (!gURLSession) {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        gURLSession = [NSURLSession sessionWithConfiguration: sessionConfiguration delegate: self delegateQueue: Nil];
    }
    return gURLSession;
}

- (void)setSession:(NSURLSession *)session {
    NSAssert(session, @"Parameter: |session| must be non-nil.");
    gURLSession = session;
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
  
  if(![OIDURLSessionProvider trustedHost]) {
    return;
  }
  
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if([challenge.protectionSpace.host containsString:[OIDURLSessionProvider trustedHost]]) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
        }
    }
}

@end
NS_ASSUME_NONNULL_END
