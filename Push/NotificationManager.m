//
//  NotificationManager.m
//  Push
//
//  Created by Christopher Guess on 6/19/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import "NotificationManager.h"
#import "SettingsManager.h"
#import "LanguageManager.h"
#import "PushSyncManager.h"
#import <AFNetworking/AFHTTPSessionManager.h>

#import "ArticleViewController.h"
//#import "LiveVideoViewController.h"

#import "Article.h"

//ew
// Always set this to true before generating and pushing...
// I know, for a fact, I'm going to screw that up at some point
#ifdef DEBUG
    #define SANDBOX @"true"
#else
    #define SANDBOX @"false"
#endif

@interface NotificationManager()

@property (nonatomic, retain) NSData * devToken;

@end

@implementation NotificationManager

+ (NotificationManager *)sharedManager {
    static NotificationManager *_sharedManager = nil;
    
    //We only want to create one singleton object, so do that with GCD
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //Set up the singleton class
        _sharedManager = [[NotificationManager alloc] init];
    });
    
    return _sharedManager;
}

- (instancetype)init
{
    self = [super init];
    
    if(self){
        _registered = NO;
        [self registerForNotifications];
    }
    
    return self;
}

- (void)changeLanguage:(nonnull NSString*)oldShortCode to:(nonnull NSString*)newShortCode;
{
    [self unRegisterWithPushServerWithLanguage:oldShortCode];
    [self registerWithPushServer:self.devToken andLanguage:newShortCode];
}

- (void)registerForNotifications
{
    #if !(TARGET_IPHONE_SIMULATOR)
        UIUserNotificationType types = (UIUserNotificationType) (UIUserNotificationTypeSound | UIUserNotificationTypeAlert);
    
        UIUserNotificationSettings * mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];

        [[UIApplication sharedApplication] registerForRemoteNotifications];
    #endif
}

- (void)didRegisterForNotificationsWithDeviceToken:(NSData*)devToken
{
    _registered = YES;
    
    self.devToken = devToken;
    
    [self registerWithPushServer:devToken];
}

- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Error registering for notifications: %@", error.localizedDescription);
}

- (void)registerWithPushServer:(NSData*)devToken
{
    NSString * languageShortCode = [LanguageManager sharedManager].languageShortCode;
    [self registerWithPushServer:devToken andLanguage:languageShortCode];
}

- (void)registerWithPushServer:(NSData*)devToken andLanguage:(NSString*)languageShortCode
{
    NSString * urlString = [NSString stringWithFormat:@"%@/notifications/subscribe", [SettingsManager sharedManager].pushUrl];
    
    NSString * devTokenString = [self hexForData:devToken];
    
    NSDictionary * parameters = @{@"dev_id": [self identifierForInstall],
                                  @"dev_token": devTokenString,
                                  @"language": languageShortCode,
                                  @"platform": @"ios",
                                  @"sandbox": SANDBOX};
    
    NSMutableURLRequest * request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlString parameters:parameters error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSString * responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"%@", responseString);
        }
    }];
    [dataTask resume];
}

- (void)unRegisterWithPushServerWithLanguage:(NSString*)languageShortCode
{
    NSString * urlString = [NSString stringWithFormat:@"%@/notifications/unsubscribe", [SettingsManager sharedManager].pushUrl];

    NSString * devTokenString = [self hexForData:self.devToken];
    
    NSDictionary * parameters = @{@"dev_id": [self identifierForInstall],
                                  @"dev_token": devTokenString,
                                  @"language": languageShortCode,
                                  @"platform": @"ios",
                                  @"sandbox": SANDBOX};
    
    NSMutableURLRequest * request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlString parameters:parameters error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSString * responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"%@", responseString);
        }
    }];
    [dataTask resume];
}

- (void)didReceiveNotification:(nonnull NSDictionary *)userInfo withNavigationController:(UINavigationController*)navController forApplicationSatate:(UIApplicationState)state
{
    NSLog(@"%@", userInfo);
    if([[userInfo allKeys] containsObject:@"article_id"]){
        
        [[PushSyncManager sharedManager] articleWithId:userInfo[@"article_id"] withCompletionHandler:^(NSArray *articles) {
            if([articles count] > 0){
                Article * article = articles[0];
                if (state == UIApplicationStateActive){
                    [self showAlertForArticle:article withNavigationController:navController];
                } else {
                    [self showArticle:article withNavigationController:navController];
                }
            }

        } failure:^(NSError *error) {
            NSLog(@"Error fetching article: %@", error.localizedDescription);
        }];
    } else if([[userInfo allKeys] containsObject:@"facebook_live_id"]){
        if (state == UIApplicationStateActive){
            [self showAlertForFacebookLiveWithNavigationController:navController];
        } else {
            [self showFacebookLiveVideoViewControllerWithNavigationController:navController];
        }

    }
}

- (void)showAlertForArticle:(Article*)article withNavigationController:(UINavigationController*)navController
{
    UIAlertController * alertcontroller = [UIAlertController alertControllerWithTitle:[[LanguageManager sharedManager] localizedStringForKey:@"NewsAlert" value:@"Header of news alert dialog"] message:article.headline preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:[[LanguageManager sharedManager] localizedStringForKey:@"Cancel" value:@"Cancel button of news alert dialog"] style:UIAlertActionStyleCancel handler:nil];
    
    [alertcontroller addAction:cancelAction];
    
    UIAlertAction * readAction = [UIAlertAction actionWithTitle:[[LanguageManager sharedManager] localizedStringForKey:@"Read" value:@"Read article button of news alert dialog"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showArticle:article withNavigationController:navController];
    }];
    
    [alertcontroller addAction:readAction];
    
    [navController presentViewController:alertcontroller animated:YES completion:nil];
}

- (void)showArticle:(Article*)article withNavigationController:(UINavigationController*)navController
{
    ArticleViewController * articleViewController = [[ArticleViewController alloc] initWithArticle:article];
    dispatch_async(dispatch_get_main_queue(), ^{
        [navController pushViewController:articleViewController animated:YES];
    });
}

- (void)showAlertForFacebookLiveWithNavigationController:(UINavigationController*)navController
{
    UIAlertController * alertcontroller = [UIAlertController alertControllerWithTitle:[[LanguageManager sharedManager] localizedStringForKey:@"FacebookLiveAlert" value:@"Facebook live alert notification"] message:@"We're live on Facebook Live, click here to watch" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:[[LanguageManager sharedManager] localizedStringForKey:@"Cancel" value:@"Cancel button of news alert dialog"] style:UIAlertActionStyleCancel handler:nil];
    
    [alertcontroller addAction:cancelAction];
    
    UIAlertAction * readAction = [UIAlertAction actionWithTitle:[[LanguageManager sharedManager] localizedStringForKey:@"Watch" value:@"View Facebook Live"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showFacebookLiveVideoViewControllerWithNavigationController:navController];
    }];
    
    [alertcontroller addAction:readAction];
    
    [navController presentViewController:alertcontroller animated:YES completion:nil];
}

- (void)showFacebookLiveVideoViewControllerWithNavigationController:(UINavigationController*)navController
{
//    LiveVideoViewController * liveVideoViewController = [[LiveVideoViewController alloc] init];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [navController pushViewController:liveVideoViewController animated:YES];
//    });

}

- (NSString*)identifierForInstallWithLanguage:(NSString*)languageShortCode
{
    // This is a placeholder, fix it.
    NSString * uuid = [self identifierForInstall];
    return [NSString stringWithFormat:@"%@.%@", uuid, languageShortCode];
}
    
- (NSString*)identifierForInstall
{
    NSString * defaultKey = [NSString stringWithFormat:@"%@-ios-push", [SettingsManager sharedManager].pushIdentifier];
    NSString * uuid = [[NSUserDefaults standardUserDefaults] objectForKey:defaultKey];
    
    if(!uuid){
        uuid = [NSUUID UUID].UUIDString;
        [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:defaultKey];
    }

    return uuid;
}

- (NSString*)hexForData:(NSData*)data
{
    NSUInteger capacity = data.length * 2;
    NSMutableString *sbuf = [NSMutableString stringWithCapacity:capacity];
    const unsigned char *buf = data.bytes;
    NSInteger i;
    for (i=0; i<data.length; ++i) {
        [sbuf appendFormat:@"%02X", (NSUInteger)buf[i]];
    }

    return sbuf;
}



@end
