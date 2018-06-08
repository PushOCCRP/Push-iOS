//
//  ArticlePageViewController.h
//  Push
//
//  Created by Christopher Guess on 10/29/15.
//  Copyright © 2015 OCCRP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Realm/Realm.h>

@interface ArticlePageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, retain) RLMArray * articles;

- (instancetype)initWithArticles:(RLMArray *)articles;

@end
