//
//  NotificationManager.h
//  Push
//
//  Created by Christopher Guess on 6/19/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NotificationManager : NSObject

@property (nonatomic, assign, readonly) BOOL registered;

+ (nonnull NotificationManager *)sharedManager;

- (void)registerForNotifications;

- (void)didRegisterForNotificationsWithDeviceToken:(nonnull NSData*)devToken;

- (void)didReceiveNotification:(nonnull NSDictionary *)userInfo withNavigationController:(nonnull UINavigationController*)navController forApplicationSatate:(UIApplicationState)state;

- (void)changeLanguage:(nonnull NSString*)oldShortCode to:(nonnull NSString*)newShortCode;

@end
