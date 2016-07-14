//
//  PromotionView.m
//  Push
//
//  Created by Christopher Guess on 6/15/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import "PromotionView.h"
#import <Masonry/Masonry.h>
#import "LanguageManager.h"
#import "SettingsManager.h"

#import "ClickIndicator.h"

#import <QuartzCore/QuartzCore.h>

@implementation PromotionView

- (instancetype)initWithPromotion:(Promotion*)promotion 
{
    self = [super init];
    if(self){
        
        if(![self checkLanguage:[LanguageManager sharedManager].languageShortCode forPromotion:promotion]){
            return nil;
        }
        
        _promotion = promotion;
        [self addViews];
        [self addTapRecognizer];
        self.userInteractionEnabled = YES;
    }
    
    return self;
}

- (BOOL)checkLanguage:(NSString*)language forPromotion:(Promotion*)promotion
{
    if([promotion.titles.allKeys containsObject:language] && [promotion.texts.allKeys containsObject:language] && [promotion.urls.allKeys containsObject:language]){
        return YES;
    }
    
    return false;
}

- (void)addViews
{
    
    NSString * language = [LanguageManager sharedManager].languageShortCode;

    self.backgroundColor = [UIColor whiteColor];
    
    UILabel * titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13.0f];
    [self addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(5.0f);
        make.right.equalTo(self).offset(5.0f);
        make.left.equalTo(self).offset(5.0f);
        make.height.equalTo(@13);
    }];
    
    titleLabel.text = self.promotion.titles[language];
    
    UILabel * label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:@"Helvetica" size:14.0f];
    [self addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(2.0f);
        make.right.equalTo(self).offset(5.0f);
        make.left.equalTo(self).offset(5.0f);
        make.bottom.equalTo(self).offset(-5.0f);
    }];
    
    label.text = self.promotion.texts[language];
    
    //Spacers
    UIView * spacer1 = [[UIView alloc] init];
    UIView * spacer2 = [[UIView alloc] init];
    
    [self addSubview:spacer1];
    [self addSubview:spacer2];
    NSNumber * height = @10;
    [spacer1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@5);
        make.top.equalTo(@0);
        make.height.equalTo(height);
    }];
    
    [spacer2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@5);
        make.bottom.equalTo(@0);
        make.height.equalTo(height);
    }];
    
    ClickIndicator * arrow  = [[ClickIndicator alloc] initWithColor:[SettingsManager sharedManager].navigationTextColor];
    [self addSubview:arrow];
    
    [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-20.0f);
        make.top.equalTo(spacer1.mas_bottom);
        make.bottom.equalTo(spacer2.mas_bottom);
        make.width.equalTo(@20);
    }];

}

- (void)layoutSubviews
{
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.bounds];
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.layer.shadowOpacity = 0.2f;
    self.layer.shadowPath = shadowPath.CGPath;
}

- (void)addTapRecognizer
{
    UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
    [self addGestureRecognizer:recognizer];
}

- (void)didTap
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didTapOnPromotion:)]){
        [self.delegate didTapOnPromotion:self.promotion];
    }
}

@end
