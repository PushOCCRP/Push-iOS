//
//  AboutBarButtonView.h
//  Push
//
//  Created by Christopher Guess on 1/26/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutBarButtonView : UIView

- (instancetype)initWithTarget:(id)target andSelector:(SEL)selector;

@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL selector;

@end
