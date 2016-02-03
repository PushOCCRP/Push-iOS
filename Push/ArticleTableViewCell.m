//
//  ArticleTableViewCell.m
//  Push
//
//  Created by Christopher Guess on 10/29/15.
//  Copyright © 2015 OCCRP. All rights reserved.
//

#import "ArticleTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface ArticleTableViewCell ()
 
@end

@implementation ArticleTableViewCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setArticle:(Article *)article
{
    self.headlineLabel.text = @"";
    self.imageView.image = nil;
    
    _article = article;
    self.headlineLabel.text = article.headline;
    self.dateBylinesLabel.text = article.shortDateByline;
    
    __weak typeof(self) weakSelf = self;
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:article.images.firstObject[@"url"]]];
    [self.imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        weakSelf.articleImageView.image = image;
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        NSLog(@"Error loading image: %@", error.localizedDescription);
    }];
    //Set the rest of the article as it's correctly implemented
}

@end
