//
//  SettingsManager.m
//  Push
//
//  Created by Christopher Guess on 1/20/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import "SettingsManager.h"

@interface SettingsManager()

@property (nonatomic, retain) NSDictionary * settingsDictionary;

@end

@implementation SettingsManager

+ (SettingsManager *)sharedManager {
    static SettingsManager *_sharedManager = nil;
    
    //We only want to create one singleton object, so do that with GCD
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //Set up the singleton class
        _sharedManager = [[SettingsManager alloc] init];
    });
    
    return _sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if(self){
        NSString *path = [[NSBundle mainBundle] pathForResource:@"SecretKeys" ofType:@"plist"];
    
        // Build the dictionary from the plist
        self.settingsDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    
    return self;
}

- (NSString*)pushUrl
{
    return self.settingsDictionary[@"push_url"];
}

- (NSString*)hockeyAppId
{
    return self.settingsDictionary[@"hockey_app_id"];
}
@end
