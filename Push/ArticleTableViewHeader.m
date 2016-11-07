//
//  ArticleTableViewHeader.m
//  Push
//
//  Created by Christopher Guess on 10/19/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import "ArticleTableViewHeader.h"
#import <Masonry/Masonry.h>
#import "HorizontalRule.h"
#import "SectionSplit.h"

@interface ArticleTableViewHeader()

@property (nonatomic, nonnull) UILabel * categoryNameLabel;

@end

@implementation ArticleTableViewHeader

- (instancetype)initWithTop:(BOOL)top
{
    self = [super init];
    if(self){
        [self addViewsWithTop:top];
    }
    
    return self;
}

- (void)addViewsWithTop:(BOOL)top
{
    self.backgroundColor = [UIColor whiteColor];
    
    self.categoryNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.categoryNameLabel.font = [UIFont fontWithName:@"AmericanTypewriter" size:16.0f];
    self.categoryNameLabel.textColor = [UIColor darkTextColor];
    
    UIView * topView = [[SectionSplit alloc] initWithTop:top];
    UIView * horizontalRuleBottom = [[HorizontalRule alloc] init];
    
    [self addSubview:topView];
    [self addSubview:self.categoryNameLabel];
    [self addSubview:horizontalRuleBottom];
    
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        if(top){
            make.height.equalTo(@1);
        } else {
            make.height.equalTo(@10);
        }
    }];
    
    [self.categoryNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topView.mas_bottom).offset(8.0f);
        make.left.equalTo(self).offset(20.0f);
        make.right.equalTo(self).offset(20.0f);
    }];
    
    [horizontalRuleBottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.categoryNameLabel.mas_bottom).offset(5.0f);
        make.left.equalTo(self).offset(15.0f);
        make.right.equalTo(self).offset(-15.0f);
        make.height.equalTo(@1);
        make.bottom.equalTo(self).offset(-10.0f);
    }];

}

- (void)setCategoryName:(NSString *)categoryName
{
    _categoryName = categoryName;
    self.categoryNameLabel.text = [categoryName capitalizedString];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
