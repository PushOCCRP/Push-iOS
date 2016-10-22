//
//  HorizontalRule.m
//  Push
//
//  Created by Christopher Guess on 10/20/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import "HorizontalRule.h"
#import <Masonry/Masonry.h>

@implementation HorizontalRule

- (instancetype)init
{
    self = [super init];
    if(self){
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1.0f, 1.0f)];
        view.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
            
        [self addSubview:view];
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
