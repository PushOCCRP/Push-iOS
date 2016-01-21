//
//  ArticlePageViewController.m
//  Push
//
//  Created by Christopher Guess on 10/29/15.
//  Copyright © 2015 OCCRP. All rights reserved.
//

#import "ArticlePageViewController.h"
#import "ArticleViewController.h"
#import "LanguageManager.h"

@interface ArticlePageViewController ()

@end

@implementation ArticlePageViewController

- (instancetype)initWithArticles:(NSArray *)articles
{
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.articles = articles;
    self.view.userInteractionEnabled = YES;
    self.dataSource = self;
    self.delegate = self;
    self.view.backgroundColor = [UIColor whiteColor];

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem * shareBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:MYLocalizedString(@"Share", @"Share") style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonTapped)];
    self.navigationItem.rightBarButtonItem = shareBarButtonItem;
    

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)shareButtonTapped {
    [(ArticleViewController*)self.viewControllers.firstObject shareButtonTapped];
}


#pragma mark - UIPageViewDelegate

#pragma mark - UIPageViewDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger currentIndex = [self.articles indexOfObject:[(ArticleViewController*)viewController article]];
    if(currentIndex == 0){
        return nil;
    }
    
    return [[ArticleViewController alloc] initWithArticle:self.articles[currentIndex - 1]];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger currentIndex = [self.articles indexOfObject:[(ArticleViewController*)viewController article]];
    if(currentIndex == self.articles.count - 1){
        return nil;
    }
    
    return [[ArticleViewController alloc] initWithArticle:self.articles[currentIndex + 1]];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return self.articles.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.articles indexOfObject:[(ArticleViewController*)pageViewController.viewControllers.firstObject article]];
}
@end
