//
//  SettingsManager.h
//  Push
//
//  Created by Christopher Guess on 1/20/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SettingsManager : NSObject
+ (SettingsManager *)sharedManager;

@property (nonatomic, readonly) NSString * name;
@property (nonatomic, readonly) NSString * shortName;
@property (nonatomic, readonly) NSString * pushIdentifier;
@property (nonatomic, readonly) NSArray * languages;
@property (nonatomic, readonly) NSString * defaultLanguage;
@property (nonatomic, readonly) NSString * iconLarge;
@property (nonatomic, readonly) NSString * iconSmall;
@property (nonatomic, readonly) UIColor * iconBackgroundColor;
@property (nonatomic, readonly) UIColor * launchBackgroundColor;
@property (nonatomic, readonly) UIColor * navigationBarColor;
@property (nonatomic, readonly) UIColor * navigationTextColor;

// Default is to show author
@property (nonatomic, readonly) BOOL shouldShowAuthor;
// Default is false
@property (nonatomic, readonly) BOOL loginRequired;

@property (nonatomic, readonly) NSString * pushUrl;
@property (nonatomic, readonly) NSString * hockeyAppId;
@property (nonatomic, readonly) NSURL * cmsBaseUrl;
@property (nonatomic, readonly) NSURL * donateUrl;

@end
