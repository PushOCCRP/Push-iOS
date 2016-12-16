//
//  PushSyncManager.m
//  Push
//
//  Created by Christopher Guess on 11/11/15.
//  Copyright © 2015 OCCRP. All rights reserved.
//

#import "PushSyncManager.h"
#import "SettingsManager.h"
#import "LanguageManager.h"
#import "AnalyticsManager.h"
#import <AFNetworking/AFNetworking.h>

@interface PushSyncManager()

@property (nonatomic, retain) id articles;

@end

@implementation PushSyncManager

static const NSString * versionNumber = @"1.1";

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
    return [super initWithBaseURL:[NSURL URLWithString:[SettingsManager sharedManager].pushUrl]];
}

// Returns the current cached array, and then does another call.
// The caller should show the current array and then handle the call back with new articles
// If the return is nil there is nothing stored and the call will still be made.
- (NSArray*)articlesWithCompletionHandler:(void(^)(id articles))completionHandler failure:(void(^)(NSError *error))failure
{

    [self GET:@"articles" parameters:@{@"language":[LanguageManager sharedManager].languageShortCode,
                                       @"v":versionNumber, @"categories":@"true"} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
                                           [self handleResponse:responseObject completionHandler:completionHandler];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleError:error failure:failure];
    }];
    
    
    if(!self.articles || ([self.articles respondsToSelector:@selector(count)] && [self.articles count] == 0) ||
       ([self.articles respondsToSelector:@selector(allKeys)] && [[self.articles allKeys] count] == 0)){
        self.articles = [self getCachedArticles];
    }
    
    return self.articles;
}

- (void)articleWithId:(NSString*)articleId withCompletionHandler:(void(^)(id articles))completionHandler failure:(void(^)(NSError *error))failure
{
    NSString * languageShortCode = [LanguageManager sharedManager].languageShortCode;
    
    //iOS uses 'sr' for Serbian, the rest of the world uses 'rs', so switch it here
    if([languageShortCode isEqualToString:@"sr"]){
        languageShortCode = @"rs";
    }
    
    [self GET:@"article" parameters:@{@"id":articleId, @"language":[LanguageManager sharedManager].languageShortCode,
                                     @"v":versionNumber} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                         
                                         [self handleResponse:responseObject completionHandler:completionHandler];
                                         
                                     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                         [self handleError:error failure:failure];
                                     }];
    
}

- (void)searchForTerm:(NSString*)searchTerms withCompletionHandler:(void(^)(id articles))completionHandler failure:(void(^)(NSError *error))failure
{
    NSString * languageShortCode = [LanguageManager sharedManager].languageShortCode;
    
    //iOS uses 'sr' for Serbian, the rest of the world uses 'rs', so switch it here
    if([languageShortCode isEqualToString:@"sr"]){
        languageShortCode = @"rs";
    }
    
    [self GET:@"search" parameters:@{@"q":searchTerms, @"language":[LanguageManager sharedManager].languageShortCode,
                                     @"v":versionNumber} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                         
                                         [self handleResponse:responseObject completionHandler:completionHandler];
                                         
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleError:error failure:failure];
    }];
}

- (void)handleResponse:(NSDictionary*)responseObject completionHandler:(void(^)(NSObject * articles))completionHandler
{
    NSDictionary * response = (NSDictionary*)responseObject;

    /* we want to handle both categories and consolidated returns */
    
    if(![response.allKeys containsObject:@"categories"]){
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
    } else {
        NSMutableDictionary * mutableCategoriesResponseDictionary = [NSMutableDictionary dictionary];
        NSArray * categoriesArray = response[@"categories"];
        for(NSString * category in categoriesArray){
            NSArray * articles = response[@"results"][category];
            
            NSMutableArray * mutableResponseArray = [NSMutableArray array];
            for(NSDictionary * articleResponse in articles){
                Article * article = [Article articleFromDictionary:articleResponse andCategory:category];
                [mutableResponseArray addObject:article];
            }
            
            mutableCategoriesResponseDictionary[category] = mutableResponseArray;
        }
        
        mutableCategoriesResponseDictionary[@"categories_order"] = categoriesArray;
        
        NSDictionary * categories = [NSDictionary dictionaryWithDictionary:mutableCategoriesResponseDictionary];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(categories);
        });
    }
    
}

- (void)handleError:(NSError*)error failure:(void(^)(NSError *error))failure
{
    [AnalyticsManager logErrorWithErrorDescription:error.localizedDescription];
    dispatch_async(dispatch_get_main_queue(), ^{
        failure(error);
    });
}

- (void)reset
{
    self.articles = nil;
    [self resetCachedArticles];
}

-(NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLResponse * _Nonnull, id _Nullable, NSError * _Nullable))completionHandler
{
    return [super dataTaskWithRequest:request completionHandler:completionHandler];
}

// Pass in either NSArray or NSDictionary
- (void)cacheArticles:(id)articles
{
    NSParameterAssert([articles class] == NSClassFromString(@"NSArray") || [articles class] == NSClassFromString(@"NSDictionary"));
    
    self.articles = articles;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:articles] forKey:@"cached_articles"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


// Returns nill if the key doesn't exist.
- (id)getCachedArticles
{
    NSData * articleData = [[NSUserDefaults standardUserDefaults] objectForKey:@"cached_articles"];
    if(!articleData){
        return nil;
    }
    
    id articles = [NSKeyedUnarchiver unarchiveObjectWithData:articleData];
    
    @try {
        NSParameterAssert([articles class] == NSClassFromString(@"NSArray") || [articles class] == NSClassFromString(@"NSDictionary"));
    } @catch (NSException *exception) {
        return nil;
    }

    return articles;
}

- (void)resetCachedArticles
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"cached_articles"];
}


@end
