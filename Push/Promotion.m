//
//  Promotion.m
//  Push
//
//  Created by Christopher Guess on 6/15/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import "Promotion.h"

@implementation Promotion

- (instancetype)initWithURLs:(NSDictionary*)urls titles:(NSDictionary*)titles texts:(NSDictionary*)texts startDate:(NSDate*)startDate endDate:(NSDate*)endDate;
{
    self = [super init];
    if(self){
        _urls = urls;
        _titles = titles;
        _texts = texts;
        _startDate = startDate;
        _endDate = endDate;
    }
    
    return self;
}

- (instancetype)initWihDictionary:(NSDictionary *)dictionary
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd-MM-yyyy";
    
    
    NSDate * startDate = [dateFormatter dateFromString:dictionary[@"start-date"]];
    NSDate * endDate = [dateFormatter dateFromString:dictionary[@"end-date"]];
    
    return [self initWithURLs:dictionary[@"urls"] titles:dictionary[@"title"] texts:dictionary[@"text"] startDate:startDate endDate:endDate];
}

@end
