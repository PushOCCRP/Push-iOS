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
- (NSArray*)articlesWithCompletionHandler:(void(^)(NSArray * articles))completionHandler
                              failure:(void(^)(NSError *error))failure;
- (void)searchForTerm:(NSString*)searchTerms withCompletionHandler:(void(^)(NSArray * articles))completionHandler failure:(void(^)(NSError *error))failure;
- (void)reset;
@end
