//
//  MainViewController.m
//  Push
//
//  Created by Christopher Guess on 11/11/15.
//  Copyright © 2015 OCCRP. All rights reserved.
//

#import "MainViewController.h"
#import "FeaturedArticleTableViewCell.h"
#import "ArticlePageViewController.h"
#import "ArticleViewController.h"
#import "PushSyncManager.h"
#import <SVPullToRefresh/SVPullToRefresh.h>
#import "SearchViewController.h"
#import <Masonry/Masonry.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <AFNetworking/UIImage+AFNetworking.h>
#import "LanguageManager.h"
#import "LanguagePickerView.h"
#import "AboutViewController.h"

#import "AboutBarButtonView.h"

#import <Crashlytics/Crashlytics.h>

// These are also set in the respective nibs, so if you change it make sure you change it there too
static NSString * featuredCellIdentifier = @"FEATURED_ARTICLE_STORY_CELL";
static NSString * standardCellIdentifier = @"ARTICLE_STORY_CELL";


@interface MainViewController ()

@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, retain) LanguagePickerView * languagePickerView;

@property (nonatomic, retain) NSArray * articles;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationBar];
    [self setupTableView];
    
    __weak typeof(self) weakSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf loadArticles];
    }];
    
    [self loadInitialArticles];
    
    // TODO: Track the user action that is important for you.
    [Answers logContentViewWithName:@"Article List" contentType:nil contentId:@"article_list" customAttributes:nil];
}

- (void)setupNavigationBar
{
    // Add Logo with custom barbutton item
    // Using a custom view for sizing
    UIImage * logoImage = [UIImage imageNamed:@"logo.png"];
    
    UIImageView * logoImageView = [[UIImageView alloc] initWithImage:logoImage];
    CGRect frame = logoImageView.frame;
    frame.size.height = self.navigationController.navigationBar.frame.size.height - 15;
    //get the appropriate width here
    CGFloat sizingRatio = frame.size.height / logoImage.size.height;
    frame.size.width = logoImage.size.width * sizingRatio;
    logoImageView.frame = frame;
    
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UIBarButtonItem * occrpLogoButton = [[UIBarButtonItem alloc]
                                         initWithCustomView:logoImageView];
    
    self.navigationItem.leftBarButtonItem = occrpLogoButton;
    self.navigationController.navigationItem.leftBarButtonItem = occrpLogoButton;
    
    // Add about button
    UIBarButtonItem * aboutBarButton = [[UIBarButtonItem alloc] initWithCustomView:[[AboutBarButtonView alloc] initWithTarget:self andSelector:@selector(aboutButtonTapped)]];
    
    // Add search button
    UIBarButtonItem * searchBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonTapped)];
    
    // Add language button
    UIBarButtonItem * languageBarButton = [[UIBarButtonItem alloc] initWithTitle:@"AД" style:UIBarButtonItemStylePlain target:self action:@selector(languageButtonTapped)];
    [self.navigationItem setRightBarButtonItems:@[languageBarButton, searchBarButton, aboutBarButton]];

    // Set Back button to correct language
    [self setUpBackButton];
}

// The back button needs to be translated, which requires a new button everytime.
- (void)setUpBackButton
{
    UIBarButtonItem * backButton = [[UIBarButtonItem alloc] initWithTitle:MYLocalizedString(@"Back", @"Back") style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    self.navigationItem.backBarButtonItem = backButton;
}

// Just pop off the view controller
- (void)goBack
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupTableView
{
    [self.tableView registerNib:[UINib nibWithNibName:@"ArticleTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:standardCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"FeaturedArticleTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:featuredCellIdentifier];
}

- (void)loadInitialArticles
{
    self.articles = [[PushSyncManager sharedManager] articlesWithCompletionHandler:^(NSArray *articles) {
        NSLog(@"%@", articles);
        self.articles = articles;
        [self.tableView reloadData];
        [self.tableView.pullToRefreshView stopAnimating];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    } failure:^(NSError *error) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:MYLocalizedString(@"ConnectionError", @"Connection Error") message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:MYLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        [self.tableView.pullToRefreshView stopAnimating];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
    if(self.articles){
        [self.tableView reloadData];
    } else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }

}

- (void)loadArticles
{
    [[PushSyncManager sharedManager] articlesWithCompletionHandler:^(NSArray *articles) {
        NSLog(@"%@", articles);
        self.articles = articles;
        [self.tableView reloadData];
        [self.tableView.pullToRefreshView stopAnimating];
    } failure:^(NSError *error) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:MYLocalizedString(@"ConnectionError", @"Connection Error") message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        [self.tableView.pullToRefreshView stopAnimating];
    }];
}

#pragma mark - Menu Button Handling

- (void)aboutButtonTapped
{
    AboutViewController * aboutViewController = [[AboutViewController alloc] init];
    [self.navigationController pushViewController:aboutViewController animated:YES];
}

- (void)searchButtonTapped
{
    SearchViewController * searchViewController = [[SearchViewController alloc] init];
    [self.navigationController pushViewController:searchViewController animated:YES];
}


- (void)languageButtonTapped
{
    if(!self.languagePickerView){
        [self showLanguagePicker];
    } else {
        [self hideLanguagePicker];
    }
}

#pragma mark Language Picker

- (void)languagePickerDidChooseLanguage:(NSString *)language
{
    [[LanguageManager sharedManager] setLanguage:language];
    [self hideLanguagePicker];
    
    //Reload the view?
    [self setUpBackButton];
    [self loadArticles];
    [self.view setNeedsDisplay];
}

- (void)showLanguagePicker
{
    if(self.languagePickerView){
        return;
    }
    
    self.languagePickerView = [[LanguagePickerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 200.0f)];
    self.languagePickerView.delegate = self;
    
    [self.view addSubview:self.languagePickerView];
    [UIView animateWithDuration:0.5f animations:^{
        CGRect frame = self.languagePickerView.frame;
        frame.origin.y = self.view.frame.size.height - frame.size.height;
        self.languagePickerView.frame = frame;
    }];
}

- (void)hideLanguagePicker
{
    if(!self.languagePickerView){
        return;
    }
    
    [UIView animateWithDuration:0.5f animations:^{
        CGRect frame = self.languagePickerView.frame;
        frame.origin.y = self.view.frame.size.height;
        self.languagePickerView.frame = frame;
    } completion:^(BOOL finished) {
        [self.languagePickerView removeFromSuperview];
        self.languagePickerView = nil;
    }];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 100.0f;
    if(indexPath.row == 0){
        height = 400.0f;
    }

    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    
    ArticlePageViewController * articlePageViewController = [[ArticlePageViewController alloc] initWithArticles:self.articles];
    
    ArticleViewController * articleViewController = [[ArticleViewController alloc] initWithArticle:self.articles[indexPath.row]];
    [articlePageViewController setViewControllers:@[articleViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self.navigationController pushViewController:articlePageViewController animated:YES];
}

// UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ArticleTableViewCell * cell;
    
    if(indexPath.row == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:featuredCellIdentifier];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:standardCellIdentifier];
    }
    
    cell.article = self.articles[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Random number for testing
    return self.articles.count;
}

@end
