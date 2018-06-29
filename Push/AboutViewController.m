//
//  AboutViewController.m
//  Push
//
//  Created by Christopher Guess on 1/25/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import "AnalyticsManager.h"
#import "AboutViewController.h"
#import <Masonry/Masonry.h>
#import "LanguageManager.h"
#import "SettingsManager.h"
#import "PushSyncManager.h"

@interface AboutViewController ()

@property (nonatomic, retain) UITextView * aboutTextView;

@end

@implementation AboutViewController

static int contentWidth = 700;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self loadAboutText];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSMutableArray * rightBarButtonItems = [NSMutableArray array];
    if([SettingsManager sharedManager].donateUrl != nil){
        UIBarButtonItem * donateBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:MYLocalizedString(@"Donate", @"Donate") style:UIBarButtonItemStylePlain target:self action:@selector(donateButtonTapped)];
        [rightBarButtonItems addObject:donateBarButtonItem];
    }
    
    if([SettingsManager sharedManager].loginRequired != NO){
        UIBarButtonItem * loginBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:MYLocalizedString(@"Logout", @"Logout") style:UIBarButtonItemStylePlain target:self action:@selector(logoutButtonTapped)];
        [rightBarButtonItems addObject:loginBarButtonItem];
    }
    
    self.navigationItem.rightBarButtonItems = rightBarButtonItems;
    self.navigationItem.title = @"About";
}

- (void)viewDidAppear:(BOOL)animated
{
    [[AnalyticsManager sharedManager] logContentViewWithName:@"About Page Appeared" contentType:@"Navigation"
                                   contentId:nil customAttributes:nil];
    [[AnalyticsManager sharedManager] startTimerForContentViewWithObject:self name:@"About Page Viewed Time" contentType:@"About Page View Time" contentId:nil customAttributes:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[AnalyticsManager sharedManager] endTimerForContentViewWithObject:self andName:@"About Page Viewed Time"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupViews
{
    self.aboutTextView = [[UITextView alloc] init];
    self.aboutTextView.editable = NO;
    
    [self.view addSubview:self.aboutTextView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.aboutTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).offset(10);

        if(self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular){
            make.width.equalTo([NSNumber numberWithInteger:contentWidth]);
        } else {
            make.right.equalTo(self.view).offset(-10);
        }
        make.bottom.equalTo(self.view).offset(0);
    }];
}

- (void)viewDidLayoutSubviews {
    if(self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular){
        int margin = (self.aboutTextView.frame.size.width - contentWidth) / 2;
        UIEdgeInsets scrollViewInsets = self.aboutTextView.contentInset;
        scrollViewInsets.left = margin;
        scrollViewInsets.right = margin;
        
        [self.aboutTextView setContentInset:scrollViewInsets];
    }
}

- (void)loadAboutText
{
    NSData * htmlAbout = [self dataFromHtmlFile];
    
    NSString * html = [[NSString alloc] initWithData:htmlAbout encoding:NSUTF8StringEncoding];
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 7.0f;
    
    html = [html stringByAppendingString:[NSString stringWithFormat:@"<style>body{line-height: '%@'; font-family: '%@'; font-size:%fpx;}</style>", @"20px", @"Palatino-Roman", 20.0f]];
    
    
    NSMutableAttributedString * text = [[NSMutableAttributedString alloc] initWithData:[html dataUsingEncoding:NSUTF8StringEncoding]
                                                                options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                          NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                                     documentAttributes:nil error:nil];
    [self.aboutTextView setAttributedText:text];

    self.aboutTextView.dataDetectorTypes = UIDataDetectorTypeAll;
}

- (NSData*)dataFromHtmlFile
{
    NSString * languageShortCode = [[LanguageManager sharedManager] languageShortCode];
    NSString * aboutTextFileName = [NSString stringWithFormat:@"about_text-%@", languageShortCode];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:aboutTextFileName ofType:@"html"];
    NSData * htmlData = [NSData dataWithContentsOfFile:filePath];
    return  htmlData;
}

- (void)donateButtonTapped
{
    [[UIApplication sharedApplication] openURL:[SettingsManager sharedManager].donateUrl options:@{} completionHandler:nil];
}

- (void)logoutButtonTapped
{
    [[PushSyncManager sharedManager] logout];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
