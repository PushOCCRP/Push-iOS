//
//  PushSyncManager.h
//  Push
//
//  Created by Christopher Guess on 11/11/15.
//  Copyright © 2015 OCCRP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPSessionManager.h>
#import "Article.h"
#import "TorManager.h"

extern NSString *const PushSyncLoginErrorDomain;
extern NSString *const PushSyncConnectionErrorDomain;

@interface PushSyncManager : AFHTTPSessionManager <TorManagerDelegate>
//@interface PushSyncManager : AFHTTPSessionManager

typedef void(^CompletionBlock)(id articles);
typedef void(^FailureBlock)(NSError *error);

@property (nonatomic, readonly) BOOL isLoggedIn;

+ (PushSyncManager *)sharedManager;

// Completion handler will return nil if login is sucessful. Failure will return in all other cases
- (void)loginWithUsername:(NSString*)username password:(NSString*)password completionHandler:(CompletionBlock)completionHandler failure:(FailureBlock)failure;

// completion handler will always return either an NSArray or NSDictionary
- (NSArray*)articlesWithCompletionHandler:(CompletionBlock)completionHandler failure:(FailureBlock)failure;

// The completion handler will always return an NSArray
- (void)articleWithId:(NSString*)articleId withCompletionHandler:(CompletionBlock)completionHandler failure:(FailureBlock)failure;

// The completion handler will always return an NSArray
- (void)searchForTerm:(NSString*)searchTerms withCompletionHandler:(CompletionBlock)completionHandler failure:(FailureBlock)failure;
- (void)reset;
@end
