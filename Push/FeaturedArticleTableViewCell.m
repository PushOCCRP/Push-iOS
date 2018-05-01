//
//  FirstArticleTableViewCell.m
//  Push
//
//  Created by Christopher Guess on 10/29/15.
//  Copyright © 2015 OCCRP. All rights reserved.
//

#import "FeaturedArticleTableViewCell.h"
#import <Masonry/Masonry.h>

@interface FeaturedArticleTableViewCell ()

@property IBOutlet UILabel * descriptionLabel;

@end

@implementation FeaturedArticleTableViewCell

- (void)setArticle:(Article *)article {
    [super setArticle:article];
    self.descriptionLabel.text = @"";
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5.0f;
    
    //Check for nil here, or we crash hard.
    if(article.descriptionText){
        NSAttributedString * descriptionText = [[NSAttributedString alloc] initWithString:article.descriptionText attributes:@{NSParagraphStyleAttributeName: paragraphStyle}];
        self.descriptionLabel.attributedText = descriptionText;
    }
    
    self.descriptionLabel.font = [UIFont fontWithName:@"Palatino-Roman" size:16.0f];
    self.headlineLabel.font = [UIFont fontWithName:@"TrebuchetMS" size:25.0f];
}

- (void)drawViews:(BOOL)showImage
{
    dispatch_async(dispatch_get_main_queue(), ^{

        [self.headlineLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.articleImageView.mas_bottom).with.offset(10);
            make.left.equalTo(self.contentView.mas_left).with.offset(10);
            make.right.equalTo(self.contentView.mas_right).with.offset(-10);
            //make.height.equalTo(@73);
        }];
        
        [self.descriptionLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.headlineLabel.mas_bottom).offset(10);
            make.left.equalTo(self.headlineLabel);
            make.right.equalTo(self.headlineLabel);
            make.height.equalTo(@50);
        }];
        
        [self.dateBylinesLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.descriptionLabel.mas_bottom).with.offset(10);
            make.right.equalTo(self.headlineLabel);
            make.left.equalTo(self.headlineLabel);
            make.width.equalTo(self.headlineLabel.mas_width);
            make.height.equalTo(@30);
        }];
    });
}


@end
