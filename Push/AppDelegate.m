//
//  AppDelegate.m
//  Push
//
//  Created by Christopher Guess on 10/29/15.
//  Copyright © 2015 OCCRP. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "SettingsManager.h"
#import "AnalyticsManager.h"
#import "LanguageManager.h"
#import "NotificationManager.h"
#import "PushSyncManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //Initialize Analytics manager
    //[AnalyticsManager sharedManager];
    // Start analytics tracking
    [[AnalyticsManager sharedManager] setupForAnaylytics:CWGAnalyticsCrashlytics];
   
    //[[BITHockeyManager sharedHockeyManager] configureWithIdentifier:[SettingsManager sharedManager].hockeyAppId];
    // Do some additional configuration if needed here
    //[[BITHockeyManager sharedHockeyManager] startManager];
    //[[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];

    // Intialize the language manager so everything's set correctly from launch
    [LanguageManager sharedManager];
    
    // Set up the notifications
    //[NotificationManager sharedManager];
    
    [PushSyncManager sharedManager];
    
    // Override point for customization after application launch.
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:screenBounds];

    MainViewController * mainController = [[MainViewController alloc] init];
    
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:mainController];
    
    [self formatNavigationBar:navigationController.navigationBar];
    [self formatPageIndicatorView];
    
    [window setRootViewController:navigationController];
    [window makeKeyAndVisible];
    
    [self setWindow:window];

    
    /*NSMutableAttributedString *attrStringFromHtml = [[NSMutableAttributedString alloc]
                                                     initWithData: [@"<span>html enabled</span>" dataUsingEncoding:NSUnicodeStringEncoding
                                                                                              allowLossyConversion:NO]
                                                     options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType}
                                                     documentAttributes:nil error:nil];
    NSLog(@"%@",[attrStringFromHtml string]);
      */

    return YES;
}

- (void)formatNavigationBar:(UINavigationBar*)bar
{
    bar.barTintColor = [SettingsManager sharedManager].navigationBarColor;
    UIColor * darkColor = [SettingsManager sharedManager].navigationTextColor;
    //bar.barTintColor= [UIColor colorWithRed:39.0f/255.0f green:39.0f/255.0f blue:39.0f/255.0f alpha:1.0f];
    //UIColor * darkColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    bar.tintColor = darkColor;
    bar.translucent = NO;
    
    bar.titleTextAttributes = @{NSForegroundColorAttributeName: darkColor};
    bar.barStyle = UIBarStyleBlack;
}

- (void)formatPageIndicatorView {
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[NSUserDefaults standardUserDefaults] setValue:@"exited" forKey:@"crashed"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSString * crashedString = [[NSUserDefaults standardUserDefaults] valueForKey:@"crashed"];
    if(!crashedString || [crashedString isEqualToString:@"crashed"] ){
        [[PushSyncManager sharedManager] reset];
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:@"crashed" forKey:@"crashed"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] setValue:@"exited" forKey:@"crashed"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[NotificationManager sharedManager] didRegisterForNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error
{
    NSLog(@"Failed to register for notifications");
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo
{
    [[NotificationManager sharedManager] didReceiveNotification:userInfo withNavigationController:(UINavigationController*)self.window.rootViewController forApplicationSatate:application.applicationState];
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler
{
    [[NotificationManager sharedManager] didReceiveNotification:userInfo withNavigationController:(UINavigationController*)self.window.rootViewController forApplicationSatate:application.applicationState];
    completionHandler(UIBackgroundFetchResultNewData);
}

@end
