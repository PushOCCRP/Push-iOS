//
//  ArticleTableViewCell.m
//  Push
//
//  Created by Christopher Guess on 10/29/15.
//  Copyright © 2015 OCCRP. All rights reserved.
//

#import "ArticleTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "NSURL+URLWithNonLatinString.h"
#import <Masonry/Masonry.h>

@interface ArticleTableViewCell ()
 
@end

@implementation ArticleTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setArticle:(Article *)article
{
    //[self drawViews: YES];
    self.headlineLabel.text = @"";
    self.articleImageView.image = nil;
    
    _article = article;
    if(article.headline){
        self.headlineLabel.text = article.headline;
    }
    self.dateBylinesLabel.text = article.shortDateByline;
    
    __weak typeof(self) weakSelf = self;
    
    NSString * headerImageURL;
    if(article.headerImage){
        headerImageURL = article.headerImage[@"url"];
    } else {
        headerImageURL = article.images.firstObject[@"url"];
    }
    
    if(headerImageURL){
        NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithNonLatinString:headerImageURL]];
        [self.imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
            weakSelf.articleImageView.image = image;
            [weakSelf drawViews:YES];
        } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
            NSLog(@"Error loading image: %@", error.localizedDescription);
            [weakSelf drawViews: NO];
        }];
    } else {
        [self drawViews: NO];
    }
    //Set the rest of the article as it's correctly implemented
}

- (void)drawViews:(BOOL)showImage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_articleImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(10);
            make.bottom.equalTo(self).offset(-10);
            make.width.equalTo(@99);
            make.left.equalTo(self.mas_left).offset(10);
        }];
        
        if(showImage){
            _articleImageView.hidden = NO;
            [_headlineLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mas_top).with.offset(10);
                make.left.equalTo(_articleImageView.mas_right).with.offset(10);
                make.right.equalTo(self.mas_right).with.offset(-10);
                make.height.equalTo(@73);
            }];
        } else {
            [_headlineLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mas_top).with.offset(10);
                make.left.equalTo(self.mas_left).with.offset(10);
                make.right.equalTo(self.mas_right).with.offset(-10);
                make.height.equalTo(@73);
            }];
            _articleImageView.hidden = YES;
        }
        
        [_dateBylinesLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_headlineLabel.mas_bottom).with.offset(-10);
            make.right.equalTo(_headlineLabel);
            make.left.equalTo(_headlineLabel);
            make.width.equalTo(_headlineLabel.mas_width);
            make.height.equalTo(@30);
        }];
    });
}

@end
