//
//  PlayButtonView.m
//  Push
//
//  Created by Christopher Guess on 2/3/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import "PlayButtonView.h"
#import "PlayButton.h"

@interface PlayButtonView()

@property (nonatomic, retain) UITapGestureRecognizer * tapGestureRecognizer;

@end

@implementation PlayButtonView

- (instancetype)initWithFrame:(CGRect)frame Target:(id)target andSelector:(SEL)selector
{
    self = [self initWithFrame:frame];
    if(self){
        _target = target;
        _selector = selector;
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupGestureRecognizers];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    //Flips the height and width because of a rotation used in the play button draw code.
    [PlayButton drawCanvas1WithFrame:self.frame];
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
