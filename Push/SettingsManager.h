//
//  SettingsManager.h
//  Push
//
//  Created by Christopher Guess on 1/20/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsManager : NSObject
+ (SettingsManager *)sharedManager;

@property (nonatomic, readonly) NSString * pushUrl;
@property (nonatomic, readonly) NSString * hockeyAppId;
@property (nonatomic, readonly) NSURL * cmsBaseUrl;

@end
