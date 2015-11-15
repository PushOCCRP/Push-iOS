//
//  ArticleViewController.h
//  Push
//
//  Created by Christopher Guess on 11/11/15.
//  Copyright © 2015 OCCRP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"

@interface ArticleViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, retain) Article * article;
- (instancetype)initWithArticle:(Article*)article;

@end
