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
#include "Reachability.h"

typedef enum : NSUInteger {
    PushSyncLogin,
    PushSyncArticles,
    PushSyncArticle,
    PushSyncSearch,
} PushSyncRequestType;

NSString *const PushSyncLoginErrorDomain = @"LoginError";
NSString *const PushSyncConnectionErrorDomain = @"ConnectionError";

@interface TempRequest : NSObject

@property (nonatomic, assign) PushSyncRequestType type;
@property (nonatomic, copy) CompletionBlock completionHandler;
@property (nonatomic, copy) FailureBlock failureBlock;
@property (nonatomic, readwrite) NSDictionary * requestParameters;

@end

@implementation TempRequest
@end

struct Request {
};


@interface PushSyncManager() {
    BOOL _unreachable;
}

@property (nonatomic, retain) id articles;
@property (nonatomic, retain) NSOperationQueue * priorityQueue;

@property (nonatomic, retain) NSURLSession * session;

@property (nonatomic, retain) NSMutableArray * torRequests;

@property (atomic, assign) BOOL unreachable;
@property (atomic, assign) BOOL startingUp;



// Checks if the service is reachable
- (BOOL)checkInternetReachability;

@end

@implementation PushSyncManager

@synthesize isLoggedIn = _isLoggedIn;

static const NSString * versionNumber = @"1.1";

dispatch_semaphore_t _sem;

+ (PushSyncManager *)sharedManager {
    static PushSyncManager *_sharedManager = nil;
    
    //We only want to create one singleton object, so do that with GCD
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //Set up the singleton class
        _sharedManager = [[PushSyncManager alloc] init];
        // Testing for tor
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [_sharedManager checkInternetReachability];
        });
    });
    
    return _sharedManager;
}

- (instancetype)init
{
    self = [super initWithBaseURL:self.baseURL];
    if(self) {
        self.torRequests = [NSMutableArray array];
        self.unreachable = true;
        self.startingUp = true;
    }
    
    return self;
}

- (BOOL)isLoggedIn {
    if([SettingsManager sharedManager].loginRequired){
        return _isLoggedIn;
    }
    return false;
}

// When using this the CompletionBlock will always return nil if sucessfully logged in. It will return error for everything else
- (void)loginWithCompletionHandler:(CompletionBlock)completionHandler failure:(FailureBlock)failure {
    __weak typeof(self) weakSelf = self;

    [self waitForStartupWithCompletionHandler:^{
        [weakSelf handleLoginResponse:@{} completionHandler:completionHandler];
    }];
    

/*
    if(self.unreachable == true){
        dispatch_async(self.completionQueue, ^{
            //[weakSelf waitForStartup];
            [weakSelf informCallerThatProxyIsSpinningUpWithType:PushSyncLogin Completion:completionHandler failure:failure requestParameters:nil];
        });
        
    } else {
        dispatch_async(self.completionQueue, ^{
            //[weakSelf waitForStartup];
            [weakSelf POST:@"login.json" parameters:@{@"installation_uuid": [AnalyticsManager installationUUID], @"language":[LanguageManager sharedManager].languageShortCode,
                                                        @"v":versionNumber} progress: nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                                            if([[responseObject allKeys] containsObject:@"error"]){
                                                                NSError * localizedError = [[NSError alloc]
                                                                                            initWithDomain:MYLocalizedString(PushSyncLoginErrorDomain, nil)
                                                                                            code:2001
                                                                                            userInfo:@{
                                                                                                       NSLocalizedDescriptionKey: MYLocalizedString(@"WrongUserNameOrPassword", @"Wrong User Name or Password")
                                                                                                       }
                                                                                            ];
                                                                
                                                                [weakSelf handleError:localizedError failure:failure];
                                                                return;
                                                            }
                                                            
                                                            [weakSelf handleResponse:responseObject completionHandler:completionHandler];
                                                        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                            NSError * localizedError = [[NSError alloc]
                                                                                        initWithDomain:MYLocalizedString(PushSyncLoginErrorDomain, nil)
                                                                                        code:2000
                                                                                        userInfo:@{
                                                                                                   NSLocalizedDescriptionKey: MYLocalizedString(@"ConnectionError", @"Connection Error")
                                                                                                   }
                                                                                        ];

                                                            [weakSelf handleError:localizedError failure:failure];
                                                        }];
        });
    }
 */
}

- (void)logout {
    // We'll clear out everything stored while logged in, for now just set the variable.
    _isLoggedIn = false;
}


// Returns the current cached array, and then does another call.
// The caller should show the current array and then handle the call back with new articles
// If the return is nil there is nothing stored and the call will still be made.
- (NSArray*)articlesWithCompletionHandler:(CompletionBlock)completionHandler failure:(FailureBlock)failure;
{
    __weak typeof(self) weakSelf = self;

    [self waitForStartupWithCompletionHandler:^{
        if(self.unreachable == true){
            dispatch_async(self.completionQueue, ^{
                //[weakSelf waitForStartup];
                [weakSelf informCallerThatProxyIsSpinningUpWithType:PushSyncArticles Completion:completionHandler failure:failure requestParameters:nil];
            });
            
        } else {
            dispatch_async(self.completionQueue, ^{
                //[weakSelf waitForStartup];
                [weakSelf GET:@"articles.json" parameters:@{@"installation_uuid": [AnalyticsManager installationUUID], @"language":[LanguageManager sharedManager].languageShortCode,
                                                            @"v":versionNumber, @"categories":@"true"} progress: nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                                                
                                                                [weakSelf handleResponse:responseObject completionHandler:completionHandler];
                                                            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                                [weakSelf handleError:error failure:failure];
                                                            }];
            });
        }
        
    }];
    
    if(!self.articles || ([self.articles respondsToSelector:@selector(count)] && [self.articles count] == 0) ||
       ([self.articles respondsToSelector:@selector(allKeys)] && [[self.articles allKeys] count] == 0)){
        self.articles = [self getCachedArticles];
    }
    
    if(self.articles == nil){
        NSLog(@"Articles are not cached");
    }
    
    return self.articles;
}

- (void)articleWithId:(NSString*)articleId withCompletionHandler:(CompletionBlock)completionHandler failure:(FailureBlock)failure;
{
    [self waitForStartupWithCompletionHandler:^{
        NSString * languageShortCode = [LanguageManager sharedManager].languageShortCode;
        
        //iOS uses 'sr' for Serbian, the rest of the world uses 'rs', so switch it here
        if([languageShortCode isEqualToString:@"sr"]){
            languageShortCode = @"rs";
        }
        
        if(self.unreachable == true){
            [self informCallerThatProxyIsSpinningUpWithType:PushSyncArticle Completion:completionHandler failure:failure requestParameters:@{@"article_id": articleId}];
        } else {
            
            [self GET:@"article.json" parameters:@{@"installation_uuid": [AnalyticsManager installationUUID], @"id":articleId, @"language":[LanguageManager sharedManager].languageShortCode,
                                                   @"v":versionNumber} progress: nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                                       
                                                       [self handleResponse:responseObject completionHandler:completionHandler];
                                                       
                                                   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                       [self handleError:error failure:failure];
                                                   }];
        }

    }];
}

- (void)searchForTerm:(NSString*)searchTerms withCompletionHandler:(CompletionBlock)completionHandler failure:(FailureBlock)failure;
{
    [self waitForStartupWithCompletionHandler:^{
        NSString * languageShortCode = [LanguageManager sharedManager].languageShortCode;
        
        //iOS uses 'sr' for Serbian, the rest of the world uses 'rs', so switch it here
        if([languageShortCode isEqualToString:@"sr"]){
            languageShortCode = @"rs";
        }
        
        if(self.unreachable == true){
            [self informCallerThatProxyIsSpinningUpWithType:PushSyncSearch Completion:completionHandler failure:failure requestParameters:@{@"search_terms": searchTerms}];
        } else {
            [self GET:@"search.json" parameters:@{@"installation_uuid": [AnalyticsManager installationUUID], @"q":searchTerms, @"language":[LanguageManager sharedManager].languageShortCode,
                                                  @"v":versionNumber} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                                      
                                                      [self handleResponse:responseObject completionHandler:completionHandler];
                                                      
                                                  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                      [self handleError:error failure:failure];
                                                  }];
        }
    }];
}

- (void)handleLoginResponse:(NSDictionary*)responseObject completionHandler:(void(^)(NSObject * articles))completionHandler
{
    _isLoggedIn = YES;
    completionHandler(nil);
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
        [self cacheArticles:articles];
        
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
        
        [self cacheArticles:categories];
        
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

// This function uses the "failure" block to let the caller know that a proxy (tor)
// is spinning up in the backend. The completion and failure handlers are held so
// they can be called again. Which ever class is responding to this should use the
// UI to let people know what's going on.
- (void)informCallerThatProxyIsSpinningUpWithType:(PushSyncRequestType)type Completion:(CompletionBlock)completionHandler
                                          failure:(FailureBlock)failureHandler requestParameters:(NSDictionary*)requestParameters
{
    TempRequest * request = [[TempRequest alloc] init];
    request.type = type;
    request.completionHandler = completionHandler;
    request.failureBlock = failureHandler;
    request.requestParameters = requestParameters;
    
    [self.torRequests addObject:request];

    NSError * error = [NSError errorWithDomain:NSNetServicesErrorDomain code:1200 userInfo:nil];
    request.failureBlock(error);
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
    //NSParameterAssert([articles class] == NSClassFromString(@"NSArray") || [articles class] == NSClassFromString(@"NSDictionary"));
    NSParameterAssert([articles isKindOfClass:[NSArray class]] || [articles isKindOfClass:[NSDictionary class]]);
    
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

#pragma mark - Private Funcation
#pragma TODO should add compiler checks if tor is illegal or not

- (NSOperationQueue*)operationQueue
{
    if(!_priorityQueue){
        _priorityQueue = [[NSOperationQueue alloc] init];
        _priorityQueue.qualityOfService = NSOperationQualityOfServiceBackground;
    }
    
    return _priorityQueue;
}

- (BOOL)checkInternetReachability
{
    // Check this first
    //+ (instancetype)reachabilityForInternetConnection;
    self.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);

    Reachability *hostReachability = [Reachability reachabilityWithHostName:self.baseHost];
    if(hostReachability.currentReachabilityStatus != NotReachable){
        [self checkIfHostIsBlocked:self.baseHost];
    } else {
        self.unreachable = false;
        self.startingUp = false;
    }
    
    return true;
}

// Calls base url /heartbeat.json, if it can't reach it, we'll try it on TOR instead
- (void)checkIfHostIsBlocked:(NSString*)host
{
    // We only care if this fails.
    // TODO: Change this to a heartbeat
    self.requestSerializer.timeoutInterval = 10.0f;
    
    [self GET:@"heartbeat.json" parameters:nil
      progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          NSLog(@"Host is reachable, not using TOR.");
          self.unreachable = false;
          self.startingUp = false;
      }
      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          NSLog(@"Host is not reachable so we're going to start a TOR session.");
          self.startingUp = false;
          [[TorManager sharedManager] startTorSessionWithSession:self];
          NSLog(@"%lu", (unsigned long)[TorManager sharedManager].status);
          
    }];
    self.requestSerializer.timeoutInterval = 60.0f;
}

#pragma mark - TorSessionDelegate
- (void)didCreateTorSession:(NSURLSession*)session
{
    self.session = session;
    self.unreachable = false;
    self.startingUp = false;

    for(TempRequest * request in self.torRequests){
        switch (request.type) {
            case PushSyncArticles:
                [self articlesWithCompletionHandler:request.completionHandler failure:request.failureBlock];
                break;
            case PushSyncArticle:
                [self articleWithId:request.requestParameters[@"article_id"] withCompletionHandler:request.completionHandler failure:request.failureBlock];
            case PushSyncSearch:
                [self searchForTerm:request.requestParameters[@"search_terms"] withCompletionHandler:request.completionHandler failure:request.failureBlock];
            default:
                break;
        }
    }
    
    [self.torRequests removeAllObjects];
}

- (void)errorCreatingTorSession:(NSError*)error
{
    //Handle TOR creation error here
    self.unreachable = false;
    if(self.torRequests.count > 0){
        TempRequest *request = self.torRequests.firstObject;
        request.failureBlock([NSError errorWithDomain:NSNetServicesErrorDomain code:500 userInfo:@{NSLocalizedDescriptionKey: @"Error proxying your connection. It seems as if our service is blocked."}]);
    }
}

- (NSURL*)baseURL
{
    return [NSURL URLWithString:self.baseHost];
}

- (NSString*)baseHost
{
    return [SettingsManager sharedManager].pushUrl;
}

- (void)waitForStartupWithCompletionHandler:(void(^)())completionHandler
{
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        int count = 0;
        
        while(self.startingUp == true){
            NSLog(@"Sleeping %i", count++);
            sleep(1);
        }
        
        dispatch_async(dispatch_get_main_queue(), completionHandler);
    });
}

@end
