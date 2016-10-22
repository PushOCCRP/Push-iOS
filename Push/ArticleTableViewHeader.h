//
//  ArticleTableViewHeader.h
//  Push
//
//  Created by Christopher Guess on 10/19/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleTableViewHeader : UIView

@property (nonatomic, retain) NSString * categoryName;

- (instancetype)initWithTop:(BOOL)top;

@end
