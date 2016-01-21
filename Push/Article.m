//
//  Article.m
//  Push
//
//  Created by Christopher Guess on 10/29/15.
//  Copyright © 2015 OCCRP. All rights reserved.
//

#import "Article.h"

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
        self.captions           = [aDecoder decodeObjectForKey:@"captions"];
        self.publishDate        = [formatter
                                   dateFromString:[aDecoder decodeObjectForKey:@"publish_date"]];
        
        NSString * language = [aDecoder decodeObjectForKey:@"language"];
        if([language isEqualToString:@"en-Gb"]) {
            self.language = ENGLISH;
        } else if([language isEqualToString:@"ru"]){
            self.language = RUSSIAN;
        }

    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)jsonDictionary{
    self = [super init];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    formatter.dateFormat = @"%Y%m%d";

    self.headline           = jsonDictionary[@"headline"];
    self.descriptionText    = jsonDictionary[@"description"];
    self.body               = jsonDictionary[@"body"];
    self.images             = jsonDictionary[@"images"];
    self.videos             = jsonDictionary[@"videos"];
    self.author             = jsonDictionary[@"author"];
    self.captions           = jsonDictionary[@"captions"];
    self.publishDate        = [formatter dateFromString:jsonDictionary[@"publish_date"]];
    
    NSString * language = jsonDictionary[@"language"];
    if([language isEqualToString:@"en-Gb"]) {
        self.language = ENGLISH;
    } else if([language isEqualToString:@"ru"]){
        self.language = RUSSIAN;
    } else if([language isEqualToString:@"az"]){
        self.language = AZERBAIJANI;
    }
    
    return self;
}

- (NSURL*)linkURL {
    NSURL * url = [NSURL URLWithString:@""];
    return url;
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
    [encoder encodeObject:self.captions forKey:@"captions"];
    [encoder encodeObject:[formatter stringFromDate:self.publishDate] forKey:@"publish_date"];

    switch (self.language) {
        case ENGLISH:
            [encoder encodeObject:@"en-GB" forKey:@"language"];
            break;
        case RUSSIAN:
            [encoder encodeObject:@"ru" forKey:@"language"];
        default:
            break;
    }
}


@end
