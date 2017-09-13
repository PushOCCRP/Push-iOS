//
//  LanguageButtonView.m
//  Push
//
//  Created by Christopher Guess on 8/29/17.
//  Copyright © 2017 OCCRP. All rights reserved.
//

#import "LanguageButtonView.h"
#import "LanguageButton.h"

@interface LanguageButtonView()

@property (nonatomic, retain) UITapGestureRecognizer * tapGestureRecognizer;

@end

@implementation LanguageButtonView

- (instancetype)initWithTarget:(id)target andSelector:(SEL)selector
{
    self = [self init];
    if(self){
        _target = target;
        _selector = selector;
    }
    
    return self;
}

- (instancetype)init
{
    self = [self initWithFrame:CGRectMake(0, 0, 40.0f, 30.0f)];
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupGestureRecognizers];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    [LanguageButton drawCanvas1];
}

- (void)setupGestureRecognizers
{
    if(self.tapGestureRecognizer){
        [self removeGestureRecognizer:self.tapGestureRecognizer];
        self.tapGestureRecognizer = nil;
    }
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    [self addGestureRecognizer:self.tapGestureRecognizer];
    self.userInteractionEnabled = YES;
}

- (void)tapped
{
    if(self.target && [self.target respondsToSelector:self.selector]){
        [self.target performSelector:self.selector withObject:nil afterDelay:0.0f];
    }
}

- (void)setTarget:(id)target
{
    _target = target;
    [self setupGestureRecognizers];
}

- (void)setSelector:(SEL)selector
{
    _selector = selector;
    [self setupGestureRecognizers];
}

@end
