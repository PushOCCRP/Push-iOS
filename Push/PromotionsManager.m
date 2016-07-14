//
//  PromotionsManager.m
//  Push
//
//  Created by Christopher Guess on 6/15/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import "PromotionsManager.h"
#import <YAML-Framework/YAMLSerialization.h>
#import "Promotion.h"

@interface PromotionsManager()

@property (nonatomic, retain) NSArray * promotions;

@end

@implementation PromotionsManager

+ (PromotionsManager *)sharedManager {
    static PromotionsManager *_sharedManager = nil;
    
    //We only want to create one singleton object, so do that with GCD
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //Set up the singleton class
        _sharedManager = [[PromotionsManager alloc] init];
    });
    
    return _sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if(self){
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"promotions" ofType:@"yml"];
        NSData * ymlData = [NSData dataWithContentsOfFile:filePath];

        NSArray * parsedPromotions = [YAMLSerialization objectsWithYAMLData:ymlData options:kYAMLReadOptionStringScalars error:nil];
        
        NSMutableArray * mutablePromotions = [NSMutableArray array];
        for(NSDictionary * parsedPromotion in parsedPromotions) {
            Promotion * promotion = [[Promotion alloc] initWihDictionary:parsedPromotion];
            [mutablePromotions addObject:promotion];
        }
        
        self.promotions = mutablePromotions;
    }
    
    return self;
}

- (NSArray*)currentlyRunningPromotions
{
    NSMutableArray * validPromotions = [NSMutableArray array];
    NSDate * currentDate = [NSDate date];
    for(Promotion * promotion in self.promotions){
        if([currentDate earlierDate:promotion.startDate] == promotion.startDate && [currentDate laterDate:promotion.endDate] == promotion.endDate){
            [validPromotions addObject:promotion];
        }
    }
    
    return validPromotions;
}


@end
