//
//  PromotionsManager.h
//  Push
//
//  Created by Christopher Guess on 6/15/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PromotionsManager : NSObject
+ (PromotionsManager *)sharedManager;

- (NSArray*)currentlyRunningPromotions;

@end
