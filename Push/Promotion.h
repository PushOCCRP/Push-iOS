//
//  Promotion.h
//  Push
//
//  Created by Christopher Guess on 6/15/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Promotion : NSObject

@property (nonatomic, retain, readonly) NSDictionary * urls;
@property (nonatomic, retain, readonly) NSDictionary * titles;
@property (nonatomic, retain, readonly) NSDictionary * texts;
@property (nonatomic, retain, readonly) NSDate * startDate;
@property (nonatomic, retain, readonly) NSDate * endDate;

- (instancetype)initWithURLs:(NSDictionary*)urls titles:(NSDictionary*)titles texts:(NSDictionary*)texts startDate:(NSDate*)startDate endDate:(NSDate*)endDate;
- (instancetype)initWihDictionary:(NSDictionary*)dictionary;

@end
