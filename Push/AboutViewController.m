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
    [self.aboutTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)loadAboutText
{
    NSData * htmlAbout = [self dataFromHtmlFile];
    
    NSMutableAttributedString * text = [[NSMutableAttributedString alloc] initWithData:htmlAbout
                                                                options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                          NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                                     documentAttributes:nil error:nil];

    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 7.0f;
    [text setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle}  range:NSMakeRange(0, text.length)];

    self.aboutTextView.attributedText = text;
    self.aboutTextView.font = [UIFont fontWithName:@"Palatino-Roman" size:17.0f];
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

@end
