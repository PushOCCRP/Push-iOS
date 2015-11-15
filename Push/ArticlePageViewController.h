//
//  ArticlePageViewController.h
//  Push
//
//  Created by Christopher Guess on 10/29/15.
//  Copyright © 2015 OCCRP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticlePageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, retain) NSArray * articles;

- (instancetype)initWithArticles:(NSArray *)articles;

@end
