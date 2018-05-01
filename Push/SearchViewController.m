//
//  SearchViewController.m
//  Push
//
//  Created by Christopher Guess on 11/13/15.
//  Copyright © 2015 OCCRP. All rights reserved.
//

#import "AnalyticsManager.h"
#import "SearchViewController.h"
#import <Masonry/Masonry.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "PushSyncManager.h"
#import "Article.h"
#import "ArticleTableViewCell.h"
#import "ArticleViewController.h"
#import "LanguageManager.h"

static NSString * standardCellIdentifier = @"ARTICLE_STORY_CELL";
static int contentWidth = 700;

@interface SearchViewController ()

@property (nonatomic, retain) UISearchBar * searchBar;
@property (nonatomic, retain) UITableView * tableView;

@property (nonatomic, retain) NSArray * articles;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupSearchBar];
    [self setupTableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [AnalyticsManager logContentViewWithName:@"Search Page Appeared" contentType:@"Navigation"
                                   contentId:nil customAttributes:nil];
    [AnalyticsManager startTimerForContentViewWithObject:self name:@"Search Page Viewed Time" contentType:@"Search Page View Time" contentId:nil customAttributes:nil];

    if(!self.articles || self.articles.count < 1){
        [self.searchBar becomeFirstResponder];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [AnalyticsManager endTimerForContentViewWithObject:self andName:@"Search Page Viewed Time"];
}

- (void)setupSearchBar
{
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.placeholder = MYLocalizedString(@"Search", @"Search");
    self.searchBar.delegate = self;
    
    [self.view addSubview:self.searchBar];
    
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.top.equalTo(self.view);
    }];

}

- (void)setupTableView
{
    self.tableView = [[UITableView alloc] init];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom);
        make.bottom.equalTo(self.view.mas_bottom);
        make.right.equalTo(self.view.mas_right);
        make.left.equalTo(self.view.mas_left);
    }];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ArticleTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:standardCellIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [AnalyticsManager logSearchWithQuery:searchBar.text customAttributes:nil];
    
    [searchBar resignFirstResponder];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [[PushSyncManager sharedManager] searchForTerm:searchBar.text withCompletionHandler:^(NSArray *articles) {
        self.articles = articles;
        [self.tableView reloadData];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if(self.articles.count == 0){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [hud setMode:MBProgressHUDModeText];
                [hud setLabelText:MYLocalizedString(@"NoResultsFound", @"No search results found")];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
            });
        }
    } failure:^(NSError *error) {
        if(error.code == 1200){
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"Fixing Network Issue";
            hud.detailsLabelText = @"One moment while we attempt to fix our connection...";
            return;
        }
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:MYLocalizedString(@"ConnectionError", @"Connection Error") message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:MYLocalizedString(@"OK", @"Assertive yes") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    } loggedOut:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    }];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 100;    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    Article * article = self.articles[indexPath.row];
    [AnalyticsManager logContentViewWithName:@"Search List Item Tapped" contentType:@"Navigation"
                                   contentId:article.description customAttributes:article.trackingProperties];

    ArticleViewController * articleViewController = [[ArticleViewController alloc] initWithArticle:article];
    [self.navigationController pushViewController:articleViewController animated:YES];
}


#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ArticleTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:standardCellIdentifier];
    cell.article = self.articles[indexPath.row];
    
    if(self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular){
        int margin = (tableView.frame.size.width - contentWidth) / 2;
        [cell.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cell);
            make.bottom.equalTo(cell);
            make.left.equalTo(cell).offset(margin);
            make.right.equalTo(cell).offset(-margin);
            make.width.equalTo([NSNumber numberWithInteger:contentWidth]);
        }];
    } else {
        [cell.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell);
        }];
    }

    
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.articles.count;
}


@end
