//
//  PlayButtonView.h
//  Push
//
//  Created by Christopher Guess on 2/3/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayButtonView : UIView

- (instancetype)initWithFrame:(CGRect)frame Target:(id)target andSelector:(SEL)selector;

@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL selector;

@end
