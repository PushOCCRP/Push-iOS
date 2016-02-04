//
//  Article.m
//  Push
//
//  Created by Christopher Guess on 10/29/15.
//  Copyright © 2015 OCCRP. All rights reserved.
//

#import "Article.h"
#import "LanguageManager.h"
#import <DateTools/DateTools.h>

@interface Article ()

@end

@implementation Article

+ (instancetype)articleFromDictionary:(NSDictionary *)jsonDictionary {
    Article * article = [[Article alloc] initWithDictionary:jsonDictionary];
    
    return article;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init]) // this needs to be [super initWithCoder:aDecoder] if the superclass implements NSCoding
    {
        NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
        formatter.dateFormat = @"%Y%m%d";

        self.headline           = [aDecoder decodeObjectForKey:@"headline"];
        self.descriptionText    = [aDecoder decodeObjectForKey:@"description"];
        self.body               = [aDecoder decodeObjectForKey:@"body"];
        self.images             = [aDecoder decodeObjectForKey:@"images"];
        self.videos             = [aDecoder decodeObjectForKey:@"videos"];
        self.author             = [aDecoder decodeObjectForKey:@"author"];
        self.publishDate        = [formatter
                                   dateFromString:[aDecoder decodeObjectForKey:@"publish_date"]];
        self.linkURL            = [aDecoder decodeObjectForKey:@"linkURL"];
        
        NSString * language = [aDecoder decodeObjectForKey:@"language"];
        if([language isEqualToString:@"en-Gb"]) {
            self.language = ENGLISH;
        } else if([language isEqualToString:@"ru"]){
            self.language = RUSSIAN;
        } else if([language isEqualToString:@"az"]){
            self.language = AZERBAIJANI;
        }

    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)jsonDictionary{
    self = [super init];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    formatter.dateFormat = @"yyyyMMdd";

    self.headline           = jsonDictionary[@"headline"];
    self.descriptionText    = jsonDictionary[@"description"];
    self.body               = jsonDictionary[@"body"];
    self.images             = jsonDictionary[@"images"];
    self.videos             = jsonDictionary[@"videos"];
    self.author             = jsonDictionary[@"author"];
    self.publishDate        = [formatter dateFromString:jsonDictionary[@"publish_date"]];
    NSURL * url = [NSURL URLWithString:jsonDictionary[@"url"]];
    self.linkURL            = url;
    
    NSString * language = jsonDictionary[@"language"];
    if([[language substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"en"]) {
        self.language = ENGLISH;
    } else if([[language substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"ru"]){
        self.language = RUSSIAN;
    } else if([[language substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"az"]){
        self.language = AZERBAIJANI;
    }
    
    return self;
}

- (NSString*)dateByline
{
    NSDateFormatter * formatter = [self formatterForDate:NSDateFormatterLongStyle];
    NSString * dateString = [formatter stringFromDate:self.publishDate];
    return [self dateBylineForDateString:dateString];
}

- (NSString*)shortDateByline
{
    NSString * dateString;
    if(self.publishDate.daysAgo > 1){
        NSDateFormatter * formatter = [self formatterForDate:NSDateFormatterShortStyle];
        dateString = [formatter stringFromDate:self.publishDate];
    } else {
        dateString = [[LanguageManager sharedManager] localizedRelativeDate:self.publishDate.timeAgoSinceNow];
    }
    
    return [self dateBylineForDateString:dateString];
}

- (NSString*)dateBylineForDateString:(NSString*)dateString
{
    NSString * dateBylineText;
    if(self.author && self.author.length > 0){
        NSString * format = [[LanguageManager sharedManager] bylineFormatForLanguageShortCode:[LanguageManager sharedManager].languageShortCode];
        dateBylineText = [NSString stringWithFormat:format, dateString, self.author];
    } else {
        dateBylineText = dateString;
    }
    
    return dateBylineText;
}

- (NSDateFormatter*)formatterForDate:(NSDateFormatterStyle)formatterStyle
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.timeStyle = NSDateFormatterNoStyle;
    formatter.dateStyle = formatterStyle;
    
    formatter.locale = [NSLocale localeWithLocaleIdentifier:[LanguageManager sharedManager].languageShortCode];
    
    return formatter;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    formatter.dateFormat = @"%Y%m%d";
    
    [encoder encodeObject:self.headline forKey:@"headline"];
    [encoder encodeObject:self.descriptionText forKey:@"description"];
    [encoder encodeObject:self.body forKey:@"body"];
    [encoder encodeObject:self.images forKey:@"images"];
    [encoder encodeObject:self.videos forKey:@"videos"];
    [encoder encodeObject:self.author forKey:@"author"];
    [encoder encodeObject:[formatter stringFromDate:self.publishDate] forKey:@"publish_date"];
    [encoder encodeObject:self.linkURL forKey:@"linkURL"];
    
    NSString * languageKey = @"language";
    switch (self.language) {
        case ENGLISH:
            [encoder encodeObject:@"en-GB" forKey:languageKey];
            break;
        case RUSSIAN:
            [encoder encodeObject:@"ru" forKey:languageKey];
        case AZERBAIJANI:
            [encoder encodeObject:@"az" forKey:languageKey];
        default:
            break;
    }
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ - %@", self.headline, self.linkURL.absoluteString];
}

/**
 *  Used for tracking article in Crashalytics
 *
 *  @return a dictionary of properties representing this article for Crashalytics tracking
 */
- (NSDictionary*)trackingProperties
{
    return @{@"Article Headline":self.headline,
             @"Article Url":self.linkURL.absoluteString,
             @"Article Description":self.description};
}

@end
