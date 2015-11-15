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
    
    self.descriptionLabel.text = article.descriptionText;
    self.descriptionLabel.font = [UIFont fontWithName:@"Palatino-Roman" size:16.0f];
    self.headlineLabel.font = [UIFont fontWithName:@"TrebuchetMS" size:25.0f];
}

@end
