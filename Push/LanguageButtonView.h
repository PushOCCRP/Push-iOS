//
//  LanguageButtonView.h
//  Push
//
//  Created by Christopher Guess on 8/29/17.
//  Copyright © 2017 OCCRP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LanguageButtonView : UIView

- (instancetype)initWithTarget:(id)target andSelector:(SEL)selector;

@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL selector;

@end
