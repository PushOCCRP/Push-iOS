//
//  Article.h
//  Push
//
//  Created by Christopher Guess on 10/29/15.
//  Copyright © 2015 OCCRP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

typedef enum : NSUInteger {
    ENGLISH,
    RUSSIAN,
    AZERBAIJANI,
    ROMANIAN,
    SERBIAN,
    GEORGIAN,
    BOSNIAN
} ArticleLanguage;

@interface PushImage : RLMObject

@property (nonatomic, assign) NSInteger length;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger start;
@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSString * byline;
@property (nonatomic, retain) NSString * url;

@end
RLM_ARRAY_TYPE(PushImage)

@interface PushVideo : RLMObject

@property (nonatomic, retain) NSString * youtubeId;

@end
RLM_ARRAY_TYPE(PushVideo)

@interface Article : RLMObject <NSCoding>

@property (nonatomic, assign) NSInteger id;
@property (nonatomic, retain) NSString * headline;
@property (nonatomic, retain) NSString * descriptionText;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * dbBodyString;
@property (nonatomic, retain) NSAttributedString * bodyHTML;
@property (nonatomic, retain) PushImage * headerImage;
@property (nonatomic, retain) RLMArray<PushImage*><PushImage> * images;
@property (nonatomic, retain) RLMArray<PushVideo*><PushVideo> * videos;
@property (nonatomic, retain) NSDate * publishDate;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, assign) ArticleLanguage language;
@property (nonatomic, assign) NSInteger languageInteger;
@property (nonatomic, retain) NSURL * linkURL;
@property (nonatomic, retain) NSString * linkURLString;

@property (nonatomic, readonly) NSString * dateByline;
@property (nonatomic, readonly) NSString * shortDateByline;
@property (nonatomic, readonly) NSDictionary * trackingProperties;

+ (instancetype)articleFromDictionary:(NSDictionary *)jsonDictionary;
+ (instancetype)articleFromDictionary:(NSDictionary *)jsonDictionary andCategory:(NSString*)category;
- (instancetype)initWithDictionary:(NSDictionary *)jsonDictionary;
- (instancetype)initWithDictionary:(NSDictionary *)jsonDictionary andCategory:(NSString*)category;

@end
RLM_ARRAY_TYPE(Article)

