//
//  PushSyncManager.m
//  Push
//
//  Created by Christopher Guess on 11/11/15.
//  Copyright © 2015 OCCRP. All rights reserved.
//

#import "PushSyncManager.h"
#import <AFNetworking/AFHTTPRequestOperation.h>

@interface PushSyncManager()

@property (nonatomic, retain) NSArray * articles;

@end

@implementation PushSyncManager

+ (PushSyncManager *)sharedManager {
    static PushSyncManager *_sharedManager = nil;
    
    //We only want to create one singleton object, so do that with GCD
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //Set up the singleton class
        _sharedManager = [[PushSyncManager alloc] init];
    });
    
    return _sharedManager;
}

- (instancetype)init
{
    return [super initWithBaseURL:[NSURL URLWithString:@"https://push-backend.herokuapp.com"]];
}

// Returns the current cached array, and then does another call.
// The caller should show the current array and then handle the call back with new articles
// If the return is nil there is nothing stored and the call will still be made.
- (NSArray*)articlesWithCompletionHandler:(void(^)(NSArray * articles))completionHandler failure:(void(^)(NSError *error))failure
{
    [self GET:@"articles" parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        NSDictionary * response = (NSDictionary*)responseObject;
        NSArray * articlesResponse = response[@"results"];
        
        NSMutableArray * mutableResponseArray = [NSMutableArray arrayWithCapacity:articlesResponse.count];
        
        for(NSDictionary * articleResponse in articlesResponse){
            Article * article = [Article articleFromDictionary:articleResponse];
            [mutableResponseArray addObject:article];
        }
        
        NSArray * articles = [NSArray arrayWithArray:mutableResponseArray];
        [self cacheArticles:articles];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(articles);
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            failure(error);
        });
    }];
    
    if(!self.articles || self.articles.count == 0){
        self.articles = [self getCachedArticles];
    }
    
    return self.articles;
}

- (void)searchForTerm:(NSString*)searchTerms withCompletionHandler:(void(^)(NSArray * articles))completionHandler failure:(void(^)(NSError *error))failure
{
    [self GET:@"search" parameters:@{@"q":searchTerms} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        NSDictionary * response = (NSDictionary*)responseObject;
        NSArray * articlesResponse = response[@"results"];
        
        NSMutableArray * mutableResponseArray = [NSMutableArray arrayWithCapacity:articlesResponse.count];
        
        for(NSDictionary * articleResponse in articlesResponse){
            Article * article = [Article articleFromDictionary:articleResponse];
            [mutableResponseArray addObject:article];
        }
        
        NSArray * articles = [NSArray arrayWithArray:mutableResponseArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(articles);
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            failure(error);
        });
    }];
    
}

-(NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLResponse * _Nonnull, id _Nullable, NSError * _Nullable))completionHandler
{
    return [super dataTaskWithRequest:request completionHandler:completionHandler];
}

- (void)cacheArticles:(NSArray*)articles
{
    self.articles = articles;
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:articles] forKey:@"cached_articles"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


// Returns nill if the key doesn't exist.
- (NSArray*)getCachedArticles
{
    NSData * articleData = [[NSUserDefaults standardUserDefaults] objectForKey:@"cached_articles"];
    if(!articleData){
        return nil;
    }
    
    NSArray * articles = [NSKeyedUnarchiver unarchiveObjectWithData:articleData];
    return articles;
}

@end
