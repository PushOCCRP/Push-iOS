//
//  ArticlePageViewController.m
//  Push
//
//  Created by Christopher Guess on 10/29/15.
//  Copyright © 2015 OCCRP. All rights reserved.
//

#import "ArticlePageViewController.h"
#import "ArticleViewController.h"
#import <ShareKit/ShareKit.h>

@interface ArticlePageViewController ()

@end

@implementation ArticlePageViewController

- (instancetype)initWithArticles:(NSArray *)articles
{
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.articles = articles;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem * shareBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonTapped)];
    self.navigationItem.rightBarButtonItem = shareBarButtonItem;
    

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)shareButtonTapped {
    //Build url from currently showing article
    NSURL * url = [NSURL URLWithString:@""];
    SHKItem * item = [SHKItem URL:url title:@"" contentType:SHKURLContentTypeWebpage];
    
    // ShareKit detects top view controller (the one intended to present ShareKit UI) automatically,
    // but sometimes it may not find one. To be safe, set it explicitly
    [SHK setRootViewController:self];
    
    SHKAlertController * alertController = [SHKAlertController actionSheetForItem:item];
    [alertController setModalPresentationStyle:UIModalPresentationPopover];
    UIPopoverPresentationController * popPresenter = [alertController popoverPresentationController];
    popPresenter.barButtonItem = self.toolbarItems[1];
    [self presentViewController:alertController animated:YES completion:nil];
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
