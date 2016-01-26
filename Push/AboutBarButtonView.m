//
//  AboutBarButtonView.m
//  Push
//
//  Created by Christopher Guess on 1/26/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import "AboutBarButtonView.h"
#import "About.h"

@interface AboutBarButtonView()

@property (nonatomic, retain) UITapGestureRecognizer * tapGestureRecognizer;

@end

@implementation AboutBarButtonView

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
    [About drawIOval1Canvas];
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
