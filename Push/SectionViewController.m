//
//  SectionViewController.m
//  Push
//
//  Created by Christopher Guess on 10/20/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import "SectionViewController.h"
#import "ArticlePageViewController.h"
#import "ArticleViewController.h"
#import "ArticleTableViewCell.h"
#import "FeaturedArticleTableViewCell.h"

#import "AnalyticsManager.h"
#import <Masonry/Masonry.h>
#import "Article.h"

// These are also set in the respective nibs, so if you change it make sure you change it there too
static NSString * featuredCellIdentifier = @"FEATURED_ARTICLE_STORY_CELL";
static NSString * standardCellIdentifier = @"ARTICLE_STORY_CELL";
static int contentWidth = 700;

@interface SectionViewController ()

@end

@implementation SectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype)initWithSectionTitle:(NSString*)sectionTitle andArticles:(NSArray*)articles
{
    self = [super init];
    if(self){
        _articles = articles;
        _sectionTitle = sectionTitle;
        self.title = self.sectionTitle;
        
        [self setupViews];
    }

    return self;
}

- (void)setupViews
{
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    UITableView * tableView = [[UITableView alloc] init];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [tableView registerNib:[UINib nibWithNibName:@"ArticleTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:standardCellIdentifier];
    [tableView registerNib:[UINib nibWithNibName:@"FeaturedArticleTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:featuredCellIdentifier];
    
    [self.view addSubview:tableView];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 100.0f;
    
    if(indexPath.row == 0){
        height = 434.0f;
    }
    
    return height;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    
    NSArray * articles;
    
    articles = self.articles;
    
    ArticlePageViewController * articlePageViewController = [[ArticlePageViewController alloc] initWithArticles:articles];
    
    Article * article = self.articles[indexPath.row];
    
    ArticleViewController * articleViewController = [[ArticleViewController alloc] initWithArticle:article];
    [articlePageViewController setViewControllers:@[articleViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [[AnalyticsManager sharedManager] logContentViewWithName:@"Article List Item Tapped" contentType:@"Navigation"
                                   contentId:article.description customAttributes:article.trackingProperties];
    
    
    [self.navigationController pushViewController:articlePageViewController animated:YES];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ArticleTableViewCell * cell;
    
    NSArray * articles = self.articles;
    
    if(indexPath.row == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:featuredCellIdentifier];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:standardCellIdentifier];
    }
    
    cell.article = articles[indexPath.row];
    
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

    [cell setNeedsDisplay];
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Random number for testing
    return [self.articles count];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
