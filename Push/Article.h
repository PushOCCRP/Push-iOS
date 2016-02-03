//
//  Article.h
//  Push
//
//  Created by Christopher Guess on 10/29/15.
//  Copyright © 2015 OCCRP. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    ENGLISH,
    RUSSIAN,
    AZERBAIJANI
} ArticleLanguage;

@interface Article : NSObject <NSCoding>

@property (nonatomic, retain) NSString * headline;
@property (nonatomic, retain) NSString * descriptionText;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSArray * images;
@property (nonatomic, retain) NSArray * videos;
@property (nonatomic, retain) NSDate * publishDate;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, assign) ArticleLanguage language;
@property (nonatomic, retain) NSURL * linkURL;

@property (nonatomic, readonly) NSString * dateByline;
@property (nonatomic, readonly) NSString * shortDateByline;

+ (instancetype)articleFromDictionary:(NSDictionary *)jsonDictionary;
- (instancetype)initWithDictionary:(NSDictionary *)jsonDictionary;

@end
