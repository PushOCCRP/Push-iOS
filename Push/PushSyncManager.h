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

@interface PushSyncManager : AFHTTPSessionManager

+ (PushSyncManager *)sharedManager;

// completion handler will always return either an NSArray or NSDictionary
- (NSArray*)articlesWithCompletionHandler:(void(^)(id articles))completionHandler
                              failure:(void(^)(NSError *error))failure;

// The completion handler will always return an NSArray
- (void)articleWithId:(NSString*)articleId withCompletionHandler:(void(^)(id articles))completionHandler failure:(void(^)(NSError *error))failure;

// The completion handler will always return an NSArray
- (void)searchForTerm:(NSString*)searchTerms withCompletionHandler:(void(^)(id articles))completionHandler failure:(void(^)(NSError *error))failure;
- (void)reset;
@end
