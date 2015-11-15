//
//  AppDelegate.m
//  Push
//
//  Created by Christopher Guess on 10/29/15.
//  Copyright © 2015 OCCRP. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:screenBounds];

    MainViewController * mainController = [[MainViewController alloc] init];
    
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:mainController];
    
    [self formatNavigationBar:navigationController.navigationBar];
    
    [window setRootViewController:navigationController];
    [window makeKeyAndVisible];
    
    [self setWindow:window];


    return YES;
}

- (void)formatNavigationBar:(UINavigationBar*)bar
{
    bar.barTintColor= [UIColor colorWithRed:156.0f/255.0f green:26.0f/255.0f blue:30.0f/255.0f alpha:1.0f];
    bar.tintColor = [UIColor whiteColor];
    bar.translucent = NO;
    
    bar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    bar.barStyle = UIBarStyleBlack;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
