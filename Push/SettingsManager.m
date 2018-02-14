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
@property (nonatomic, retain) NSDictionary * secretsDictionary;

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
        self.secretsDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
        
        path = [[NSBundle mainBundle] pathForResource:@"CustomizedSettings" ofType:@"plist"];
        
        self.settingsDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    
    return self;
}

- (NSString*)name
{
    return self.settingsDictionary[@"name"];
}

- (NSString*)shortName
{
    return self.settingsDictionary[@"short-name"];
}

- (NSString*)pushIdentifier
{
    return self.settingsDictionary[@"uniqush"];
}

- (NSArray*)languages;
{
    NSString * languagesString = self.settingsDictionary[@"languages"];
    languagesString = [languagesString stringByReplacingOccurrencesOfString:@"[" withString:@""];
    languagesString = [languagesString stringByReplacingOccurrencesOfString:@"]" withString:@""];
    languagesString = [languagesString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSArray * languages = [languagesString componentsSeparatedByString:@", "];
    return languages;
}

- (NSString*)defaultLanguage;
{
    return self.settingsDictionary[@"default-language"];
}

- (NSString*)iconLarge;
{
    return self.settingsDictionary[@"icon-large"];
}

- (NSString*)iconSmall;
{
    return self.settingsDictionary[@"icon-small"];
}

- (UIColor *)iconBackgroundColor;
{
    return [self colorFromHexString:self.settingsDictionary[@"icon-background-color"]];
}

- (UIColor *)launchBackgroundColor;
{
    return [self colorFromHexString:self.settingsDictionary[@"launch-background-color"]];
}

- (UIColor *)navigationBarColor;
{
    return [self colorFromHexString:self.settingsDictionary[@"navigation-bar-color"]];
}

- (UIColor *)navigationTextColor;
{
    return [self colorFromHexString:self.settingsDictionary[@"navigation-text-color"]];
}

// Default is to show author
- (BOOL)shouldShowAuthor;
{
    NSString * shouldShowAuthor;
    
    if([self.settingsDictionary.allKeys containsObject:@"show-author"]) {
        shouldShowAuthor = [self.settingsDictionary[@"show-author"] lowercaseString];
        
        if([shouldShowAuthor isEqualToString:@"false"]) {
            return NO;
        }
    }
    
    return YES;
}


- (NSString*)pushUrl
{
    return self.secretsDictionary[@"push_url"];
}

- (NSString*)hockeyAppId
{
    return self.secretsDictionary[@"hockey_app_id"];
}

- (NSURL*)cmsBaseUrl
{
    return [NSURL URLWithString:self.secretsDictionary[@"cms_base_url"]];
}

- (NSURL*)donateUrl
{
    NSString * donateUrlString = self.secretsDictionary[@"donation_url"];
    if(donateUrlString != nil && donateUrlString.length > 0 ) {
        return [NSURL URLWithString:donateUrlString];
    } else {
        return nil;
    }
}

- (BOOL)loginRequired
{
    
    NSString * loginRequired;
    
    if([self.settingsDictionary.allKeys containsObject:@"login-required"]) {
        loginRequired = [self.settingsDictionary[@"login-required"] lowercaseString];
        
        if([loginRequired isEqualToString:@"true"]) {
            return YES;
        }
    }
    
    return NO;
}

// Borrowed from http://stackoverflow.com/a/12397366
// Assumes input like "#00FF00" (#RRGGBB).
- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}
@end
