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
    NSAttributedString * descriptionText = [[NSAttributedString alloc] initWithString:article.descriptionText attributes:@{NSParagraphStyleAttributeName: paragraphStyle}];
    
    self.descriptionLabel.attributedText = descriptionText;
    self.descriptionLabel.font = [UIFont fontWithName:@"Palatino-Roman" size:16.0f];
    self.headlineLabel.font = [UIFont fontWithName:@"TrebuchetMS" size:25.0f];
    
    
}

@end
