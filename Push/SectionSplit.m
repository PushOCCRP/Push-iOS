//
//  SectionSplit.m
//  Push
//
//  Created by Christopher Guess on 10/20/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import "SectionSplit.h"
#import <Masonry/Masonry.h>

@implementation SectionSplit

- (instancetype)initWithTop:(BOOL)top
{
    self = [super init];
    if(self) {
        self.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
        if(top == NO){
            [self addShadow];
        } else {
            [self addBottomLine];
        }
    }
    
    return self;
}

- (void)addBottomLine
{
    UIView * darkLineBottom = [[UIView alloc] init];
    darkLineBottom.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];

    [self addSubview:darkLineBottom];
    [darkLineBottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(@1);
    }];
}

- (void)addShadow
{
    UIView * darkLineTop = [[UIView alloc] init];
    darkLineTop.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
    

    [self addSubview:darkLineTop];
    
    [darkLineTop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(@1);
    }];
    
    [self addBottomLine];
}

@end
