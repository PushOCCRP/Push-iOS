//
//  PromotionView.h
//  Push
//
//  Created by Christopher Guess on 6/15/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Promotion.h"

@protocol PromotionViewDelegate <NSObject>

- (void)didTapOnPromotion:(nonnull Promotion*)promotion;

@end

@interface PromotionView : UIView

@property (nonatomic, retain, readonly, nonnull) Promotion * promotion;
@property (nonatomic, weak, nullable) id delegate;


- (nullable instancetype)initWithPromotion:(nonnull Promotion*)promotion;

@end
