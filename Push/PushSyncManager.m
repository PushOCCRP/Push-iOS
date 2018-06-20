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
#import <Realm/Realm.h>

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
@property (nonatomic, copy) LoggedOutBlock loggedOutBlock;
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
@property (nonatomic, readwrite) NSString * apiKey;
@property (nonatomic, readwrite) NSString * username;

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
        return [self isLoggedInSaved];
    }
    return false;
}

- (void)saveLoggedInStatus:(BOOL)loggedIn username:(NSString*)username apiKey:(NSString*)apiKey {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:loggedIn] forKey:@"is_logged_in"];
    self.apiKey = apiKey;
    self.username = username;
}

- (BOOL)isLoggedInSaved {
    NSNumber * loggedIn = [[NSUserDefaults standardUserDefaults] objectForKey:@"is_logged_in"];
    return  loggedIn.boolValue;
}

- (NSString*)apiKey {
    NSString * apiKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"apiKey"];
    return  apiKey;
}

- (void)setApiKey:(NSString *)apiKey {
    [[NSUserDefaults standardUserDefaults] setObject:apiKey forKey:@"apiKey"];
}

- (NSString*)username {
    NSString * username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    return username;
}

- (void)setUsername:(NSString *)username {
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
}


// When using this the CompletionBlock will always return nil if sucessfully logged in. It will return error for everything else
- (void)loginWithUsername:(NSString*)username password:(NSString*)password completionHandler:(CompletionBlock)completionHandler failure:(FailureBlock)failure {
    __weak typeof(self) weakSelf = self;

//    [self waitForStartupWithCompletionHandler:^{
//        [weakSelf handleLoginResponse:@{} completionHandler:completionHandler];
//    }];
//

    if(self.unreachable == true){
        dispatch_async(self.completionQueue, ^{
            //[weakSelf waitForStartup];
            [weakSelf informCallerThatProxyIsSpinningUpWithType:PushSyncLogin
                                                     completion:completionHandler
                                                        failure:failure
                                                      loggedOut:nil
                                              requestParameters:nil];
        });
        
    } else {
        dispatch_async(self.completionQueue, ^{
            //[weakSelf waitForStartup];
            NSDictionary * parameters = @{@"username": username,
                                          @"password": password,
                                          @"installation_uuid": [AnalyticsManager installationUUID],
                                          @"language":[LanguageManager sharedManager].languageShortCode,
                                          @"v":versionNumber};
            
            [weakSelf POST:@"authenticate"
                parameters:parameters
                  progress: nil
                   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                       if([[responseObject allKeys] containsObject:@"code"] && [[responseObject objectForKey:@"code"] isEqualToString:@"1"]){
                           _isLoggedIn = YES;
                           [weakSelf handleLoginResponse:responseObject completionHandler:completionHandler];
                           return;
                       }

                       NSError * localizedError = [[NSError alloc]
                                                initWithDomain:MYLocalizedString(PushSyncLoginErrorDomain, nil)
                                                code:2001
                                                userInfo:@{
                                                       NSLocalizedDescriptionKey: MYLocalizedString(@"WrongUserNameOrPassword", @"Wrong User Name or Password")
                                                       }
                                            ];
                       [weakSelf handleError:localizedError failure:failure];
                       return;
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        NSError * localizedError = [[NSError alloc]
                                            initWithDomain:MYLocalizedString(PushSyncLoginErrorDomain, nil)
                                            code:2000
                                            userInfo:@{
                                                       NSLocalizedDescriptionKey: MYLocalizedString(@"ConnectionError", @"Connection Error")
                                                       }
                                            ];

                        [weakSelf handleError:localizedError failure:failure];
                    }
             ];
        });
    }

}

- (void)logout {
    // We'll clear out everything stored while logged in, for now just set the variable.
    [self saveLoggedInStatus:NO username:nil apiKey:nil];
}


// Returns the current cached array, and then does another call.
// The caller should show the current array and then handle the call back with new articles
// If the return is nil there is nothing stored and the call will still be made.
- (RLMResults *)articlesWithCompletionHandler:(CompletionBlock)completionHandler failure:(FailureBlock)failure loggedOut:(LoggedOutBlock)loggedOut;
{
    __weak typeof(self) weakSelf = self;

    [self waitForStartupWithCompletionHandler:^{
        if(self.unreachable == true){
            dispatch_async(self.completionQueue, ^{
                //[weakSelf waitForStartup];
                NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
                if([SettingsManager sharedManager].loginRequired) {
                    parameters[@"api_key"] = [self apiKey];
                }

                [weakSelf informCallerThatProxyIsSpinningUpWithType:PushSyncArticles
                                                         completion:completionHandler
                                                            failure:failure
                                                          loggedOut:loggedOut
                                                  requestParameters:parameters];
            });
            
        } else {
            dispatch_async(self.completionQueue, ^{
                //[weakSelf waitForStartup];
                NSMutableDictionary * parameters = [NSMutableDictionary
                                                    dictionaryWithDictionary:@{@"installation_uuid": [AnalyticsManager installationUUID],
                                                    @"language":[LanguageManager sharedManager].languageShortCode,
                                                    @"v":versionNumber,
                                                    @"categories":@"true"}];
                if([SettingsManager sharedManager].loginRequired) {
                    parameters[@"api_key"] = [self apiKey];
                }

                [weakSelf GET:@"articles.json" parameters:parameters progress: nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                    [weakSelf handleResponse:responseObject completionHandler:completionHandler loggedOut:loggedOut];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [weakSelf handleError:error failure:failure];
                }];
            });
        }
        
    }];
    
//    if(!self.articles || ([self.articles respondsToSelector:@selector(count)] && [self.articles count] == 0) ||
//       ([self.articles respondsToSelector:@selector(allKeys)] && [[self.articles allKeys] count] == 0)){
//        self.articles = [self getCachedArticles];
//    }
    
    RLMResults * articles = [[Article allObjects] sortedResultsUsingKeyPath:@"publishDate" ascending:NO];
    if(articles.count == 0){
        NSLog(@"Articles are not cached");
    }
    
    return articles;
}

- (void)articleWithId:(NSString*)articleId withCompletionHandler:(CompletionBlock)completionHandler failure:(FailureBlock)failure loggedOut:(LoggedOutBlock)loggedOut;
{
    [self waitForStartupWithCompletionHandler:^{
        NSString * languageShortCode = [LanguageManager sharedManager].languageShortCode;
        
        //iOS uses 'sr' for Serbian, the rest of the world uses 'rs', so switch it here
        if([languageShortCode isEqualToString:@"sr"]){
            languageShortCode = @"rs";
        }
        
        if(self.unreachable == true){
            NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"article_id": articleId}];
            
            if([SettingsManager sharedManager].loginRequired) {
                parameters[@"api_key"] = [self apiKey];
            }

            [self informCallerThatProxyIsSpinningUpWithType:PushSyncArticle
                                                 completion:completionHandler
                                                    failure:failure
                                                  loggedOut:loggedOut
                                          requestParameters:parameters];
            
        } else {
            NSMutableDictionary * parameters = [NSMutableDictionary
                                                dictionaryWithDictionary:@{
                                                                           @"installation_uuid": [AnalyticsManager installationUUID],
                                                                           @"id":articleId,
                                                                           @"language":[LanguageManager sharedManager].languageShortCode,
                                                                           @"v":versionNumber}];
            if([SettingsManager sharedManager].loginRequired) {
                parameters[@"api_key"] = [self apiKey];
            }
            
            [self GET:@"article.json" parameters:parameters progress: nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                [self handleResponse:responseObject completionHandler:completionHandler loggedOut:loggedOut];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handleError:error failure:failure];
            }];
        }

    }];
}

- (void)searchForTerm:(NSString*)searchTerms withCompletionHandler:(CompletionBlock)completionHandler failure:(FailureBlock)failure loggedOut:(LoggedOutBlock)loggedOut;
{
    [self waitForStartupWithCompletionHandler:^{
        NSString * languageShortCode = [LanguageManager sharedManager].languageShortCode;
        
        //iOS uses 'sr' for Serbian, the rest of the world uses 'rs', so switch it here
        if([languageShortCode isEqualToString:@"sr"]){
            languageShortCode = @"rs";
        }
        
        if(self.unreachable == true){
            NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"search_terms": searchTerms}];
            
            if([SettingsManager sharedManager].loginRequired) {
                parameters[@"api_key"] = [self apiKey];
            }

            [self informCallerThatProxyIsSpinningUpWithType:PushSyncSearch
                                                 completion:completionHandler
                                                    failure:failure
                                                  loggedOut:loggedOut
                                          requestParameters:parameters];
        } else {
            NSMutableDictionary * parameters = [NSMutableDictionary
                                                dictionaryWithDictionary:@{
                                                                           @"installation_uuid": [AnalyticsManager installationUUID],
                                                                           @"q":searchTerms,
                                                                           @"language":[LanguageManager sharedManager].languageShortCode,
                                                                           @"v":versionNumber}];
            if([SettingsManager sharedManager].loginRequired) {
                parameters[@"api_key"] = [self apiKey];
            }
                                                
            [self GET:@"search.json" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                [self handleSearchResponse:responseObject completionHandler:completionHandler loggedOut:loggedOut];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handleError:error failure:failure];
            }];
        }
    }];
}

- (void)handleLoginResponse:(NSDictionary*)responseObject completionHandler:(void(^)(NSObject * articles))completionHandler
{
    [self saveLoggedInStatus:YES username:responseObject[@"username"] apiKey:responseObject[@"api_key"]];
    completionHandler(nil);
}

- (void)handleSearchResponse:(NSDictionary*)responseObject completionHandler:(void(^)(NSObject * articles))completionHandler loggedOut:(LoggedOutBlock)loggedOutHandler
{
    [self verifyLoginStatusForResponse:responseObject loggedOut:loggedOutHandler];
    dispatch_async(dispatch_get_main_queue(), ^{
        completionHandler([self articlesForResponse:responseObject[@"results"]]);
    });
}

- (void)handleResponse:(NSDictionary*)responseObject completionHandler:(void(^)(NSObject * articles))completionHandler loggedOut:(LoggedOutBlock)loggedOutHandler
{
    NSDictionary * response = (NSDictionary*)responseObject;
    [self verifyLoginStatusForResponse:responseObject loggedOut:loggedOutHandler];
    
    /* we want to handle both categories and consolidated returns */
    if(![response.allKeys containsObject:@"categories"]){
        NSArray * articles = [self articlesForResponse:response[@"results"]];
        RLMRealm *realm = [RLMRealm defaultRealm];
        NSError * error;
        [realm transactionWithBlock:^{
            for(Article * article in articles){
                [realm addOrUpdateObject:article];
            }
        } error:&error ];
        
        [realm refresh];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler([[Article allObjects] sortedResultsUsingKeyPath:@"publishDate" ascending:NO]);
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
   
        // transfer results to realm database
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        NSError * error;
        [realm transactionWithBlock:^{
            for(NSString * category in categoriesArray){
                NSArray * articles = [self articlesForResponse:[response[@"results"] valueForKey:category]];
                //NSArray * articles = [response[@"results"] valueForKey:category];//[category];
                for(Article * article in articles){
                    NSLog(@"test");
                   
                    [realm addOrUpdateObject:article];
              }
            }
        } error:&error ];
        
        [realm refresh];
        
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
- (void)informCallerThatProxyIsSpinningUpWithType:(PushSyncRequestType)type
                                       completion:(CompletionBlock)completionHandler
                                          failure:(FailureBlock)failureHandler
                                        loggedOut:(LoggedOutBlock)loggedOutHandler
                                requestParameters:(NSDictionary*)requestParameters
{
    TempRequest * request = [[TempRequest alloc] init];
    request.type = type;
    request.completionHandler = completionHandler;
    request.failureBlock = failureHandler;
    request.loggedOutBlock = loggedOutHandler;
    request.requestParameters = requestParameters;
    
    [self.torRequests addObject:request];

    NSError * error = [NSError errorWithDomain:NSNetServicesErrorDomain code:1200 userInfo:nil];
    request.failureBlock(error);
}

- (void)verifyLoginStatusForResponse:(NSDictionary*)response loggedOut:(LoggedOutBlock)loggedOutHandler {
    // Check if authentication was wrong. This could mean there was a hard reset on the server.
    // In which case we just delete everything and reset the app.
    if([SettingsManager sharedManager].loginRequired) {
        if([response.allKeys containsObject:@"code"] && [response[@"code"] isEqual:@0]){
            [self logout];
            loggedOutHandler();
        }
    }
}

- (NSArray*)articlesForResponse:(NSArray*)response {
    NSMutableArray * mutableResponseArray = [NSMutableArray arrayWithCapacity:response.count];
    
    for(NSDictionary * articleResponse in response){
        Article * article = [Article articleFromDictionary:articleResponse];
        [mutableResponseArray addObject:article];
    }
    
    NSArray * articles = [NSArray arrayWithArray:mutableResponseArray];
    return articles;
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
                [self articlesWithCompletionHandler:request.completionHandler failure:request.failureBlock loggedOut:request.loggedOutBlock];
                break;
            case PushSyncArticle:
                [self articleWithId:request.requestParameters[@"article_id"] withCompletionHandler:request.completionHandler failure:request.failureBlock loggedOut:request.loggedOutBlock];
            case PushSyncSearch:
                [self searchForTerm:request.requestParameters[@"search_terms"] withCompletionHandler:request.completionHandler failure:request.failureBlock loggedOut:request.loggedOutBlock];
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
