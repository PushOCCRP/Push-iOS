//
//  ArticleTableViewCell.h
//  Push
//
//  Created by Christopher Guess on 10/29/15.
//  Copyright © 2015 OCCRP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"

@interface ArticleTableViewCell : UITableViewCell

@property (nonatomic, weak, nullable) Article * article;
@property IBOutlet UILabel * headlineLabel;
@property IBOutlet UIImageView * articleImageView;
@property IBOutlet UILabel * dateBylinesLabel;

@end
