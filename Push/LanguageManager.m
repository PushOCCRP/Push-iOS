//
//  LanguageManager.m
//  Push
//
//  Created by Christopher Guess on 1/9/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import "LanguageManager.h"
@interface LanguageManager()

@property (nonatomic, retain) NSBundle * bundle;
@end

@implementation LanguageManager

static NSString * languageKey = @"push_language_key";

+ (LanguageManager *)sharedManager {
    static LanguageManager *_sharedManager = nil;
    
    //We only want to create one singleton object, so do that with GCD
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //Set up the singleton class
        _sharedManager = [[LanguageManager alloc] init];
    });
    
    return _sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if(self){
        [self setLanguage:self.language];
    }
    
    return self;
    
}

- (void)setLanguage:(NSString *)language
{
    [[NSUserDefaults standardUserDefaults] setObject:language forKey:languageKey];

    NSSet * keys = [[self languageDictionary] keysOfEntriesPassingTest:^BOOL(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if(obj == language){
            return YES;
        }
        return NO;
    }];
    
    if(keys.count < 1){
        keys = [NSSet setWithObjects:self.availableLanguages.firstObject, nil];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:keys.allObjects
                                              forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *languageShortCode;
    if(keys.count < 1){
        languageShortCode = @"en";
    } else {
        languageShortCode = keys.allObjects[0];
    }
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:languageShortCode ofType:@"lproj"];
    if (!path)
    {
        _bundle = [NSBundle mainBundle];
        NSLog(@"Warning: No lproj for %@, system default set instead !", languageShortCode);
        return;
    }
    
    _bundle = [NSBundle bundleWithPath:path];


}

// Adopted from https://stackoverflow.com/questions/1669645/how-to-force-nslocalizedstring-to-use-a-specific-language
// Also from: http://nswinery.io/blog/2015/4/7/set-your-app-localization-language-over-ios-settings

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value
{
    // bundle was initialized with [NSBundle mainBundle] as default and modified in setLanguage method
    return [self.bundle localizedStringForKey:key value:value table:nil];
}

- (NSString*)language
{
    NSString * language = [[NSUserDefaults standardUserDefaults] objectForKey:languageKey];
    if(!language || language.length < 1){
        language = self.availableLanguages.firstObject;
    }
    return language;
}

- (NSString*)languageShortCode{
    
    NSSet * keys = [[self languageDictionary] keysOfEntriesPassingTest:^BOOL(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if([self.language isEqualToString:obj]){
            return YES;
        }
        return NO;
    }];

    return keys.allObjects.firstObject;
}


- (NSArray*)availableLanguages
{
    NSArray * localizations = [[NSBundle mainBundle] localizations];
    
    //There doesn't seem to be any native way to do this, so here we go.
    NSDictionary * languageFullNames = [self languageDictionary];
    
    NSMutableArray * localizationsFullName = [NSMutableArray array];
    for(NSString * localization in localizations) {
        if([localization isEqualToString:@"Base"]){
            continue;
        }
        [localizationsFullName addObject:languageFullNames[localization]];
    }
    
    return [NSArray arrayWithArray:localizationsFullName];
}

- (NSDictionary*)languageDictionary
{
    NSDictionary * languageFullNames = @{ @"en": @"English",
                                          @"az": @"Azerbaijani",
                                          @"ru": @"Russian" };

    return languageFullNames;
}


@end

