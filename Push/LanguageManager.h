//
//  LanguageManager.h
//  Push
//
//  Created by Christopher Guess on 1/9/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#define MYLocalizedString(key, comment) [[LanguageManager sharedManager] localizedStringForKey:(key) value:(comment)]

#import <Foundation/Foundation.h>

@interface LanguageManager : NSObject

@property (nonatomic, assign) NSString * language;
@property (nonatomic, readonly) NSString * languageShortCode;

+ (LanguageManager *)sharedManager;

- (NSArray*)availableLanguages;

- (NSString*)localizedStringForKey:(NSString*)key value:(NSString*)comment;

@end
