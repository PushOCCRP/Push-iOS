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

@interface AboutViewController ()

@property (nonatomic, retain) UITextView * aboutTextView;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self loadAboutText];
}

- (void)viewDidAppear:(BOOL)animated
{
    [AnalyticsManager logContentViewWithName:@"About Page Appeared" contentType:@"Navigation"
                                   contentId:nil customAttributes:nil];
    [AnalyticsManager startTimerForContentViewWithObject:self name:@"About Page Viewed Time" contentType:@"About Page View Time" contentId:nil customAttributes:nil];
    
    if([SettingsManager sharedManager].donateUrl != nil){
        UIBarButtonItem * donateBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:MYLocalizedString(@"Donate", @"Donate") style:UIBarButtonItemStylePlain target:self action:@selector(donateButtonTapped)];
        self.navigationItem.rightBarButtonItem = donateBarButtonItem;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [AnalyticsManager endTimerForContentViewWithObject:self andName:@"About Page Viewed Time"];
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
        make.right.equalTo(self.view).offset(-10);
        make.bottom.equalTo(self.view).offset(0);
    }];
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

@end
