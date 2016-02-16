//
//  LanguageManager.m
//  Push
//
//  Created by Christopher Guess on 1/9/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import "LanguageManager.h"
#import <DateTools/DateTools.h>


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
        if([(NSString*)obj isEqualToString:language]){
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
    
    
    _bundle = [self bundleForLanguageShortCode:languageShortCode];
}

- (NSBundle*)bundleForLanguageShortCode:(NSString*)languageShortCode
{
    NSBundle * bundle;
    NSString *path = [[NSBundle mainBundle] pathForResource:languageShortCode ofType:@"lproj"];
    if (!path)
    {
        bundle = [NSBundle mainBundle];
        NSLog(@"Warning: No lproj for %@, system default set instead !", languageShortCode);
    } else {
        bundle = [NSBundle bundleWithPath:path];
    }
    
    [bundle load];
    return bundle;
}

// Adopted from https://stackoverflow.com/questions/1669645/how-to-force-nslocalizedstring-to-use-a-specific-language
// Also from: http://nswinery.io/blog/2015/4/7/set-your-app-localization-language-over-ios-settings

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value
{
    // bundle was initialized with [NSBundle mainBundle] as default and modified in setLanguage method
    return [self localizedStringForKey:key value:value withBundle:self.bundle];
}

- (NSString*)localizedStringForKey:(NSString *)key value:(NSString *)comment forLanguageShortCode:(NSString*)languageShortCode
{
    NSBundle * languageBundle = [self bundleForLanguageShortCode:languageShortCode];
    return [self localizedStringForKey:key value:comment withBundle:languageBundle];
}

- (NSString*)localizedStringForKey:(NSString *)key value:(NSString *)value withBundle:(NSBundle*)bundle
{
    return [bundle localizedStringForKey:key value:value table:nil];
}

- (NSString*)bylineFormatForLanguage:(NSString*)language
{
    return [self bylineFormatForLanguageShortCode:[self languageDictionary][language]];
}

- (NSString*)bylineFormatForLanguageShortCode:(NSString*)languageShortCode
{
    NSDictionary * bylineFormatByLanguage = @{ @"en": @"%%@ %@ %%@",
                                               @"az": @"%%@%@ %%@",
                                               @"ru": @"%%@%@ %%@" };
    NSString * localizedString = MYLocalizedString(@"by", @"between the author and date");
    NSString * format = [NSString stringWithFormat:bylineFormatByLanguage[languageShortCode], localizedString];
    return format;
}

//This is not a great hack, but since the server doesn't return time yet it'll do
- (NSString*)localizedRelativeDate:(NSString*)relativeDate
{
    //NSString * localizedRelativeDate = MYLocalizedString(relativeDate, @"yesterday, tomorrow etc.");
    //return localizedRelativeDate;
    return relativeDate;
}

- (NSString*)language
{
    NSString * language = [[NSUserDefaults standardUserDefaults] objectForKey:languageKey];
    if(!language || language.length < 1){
        //Check for the current language
        NSString * preferredLanguage = [[NSLocale preferredLanguages][0] substringToIndex:2];
        if([[[self languageDictionary] allKeys] containsObject:preferredLanguage]){
            language = [self languageDictionary][preferredLanguage];
        } else {
            language = self.availableLanguages.firstObject;
        }
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

- (NSArray*)nativeAvailableLanguages
{
    NSDictionary * languages = [self languageDictionary];
    NSMutableArray * mutableLangugages = [NSMutableArray array];
    
    for(NSString * key in languages.allKeys){
        [mutableLangugages addObject:[self localizedStringForKey:@"LanguageName" value:@"nil" forLanguageShortCode:key]];
    }
    
    return [NSArray arrayWithArray:mutableLangugages];
}

- (NSDictionary*)languageDictionary
{
    NSDictionary * languageFullNames = @{ @"en": @"English",
                                          @"az": @"Azerbaijani",
                                          @"ru": @"Russian" };

    return languageFullNames;
}

- (NSDictionary*)nativeLanguageDictionary
{
    NSDictionary * languages = [self languageDictionary];
    NSMutableDictionary * mutableLangugages = [NSMutableDictionary dictionaryWithDictionary:languages];
    
    for(NSString * key in mutableLangugages.allKeys){
        mutableLangugages[key] = [self localizedStringForKey:@"LanguageName" value:@"nil" forLanguageShortCode:key];
    }
    
    return [NSDictionary dictionaryWithDictionary:mutableLangugages];
}

@end

