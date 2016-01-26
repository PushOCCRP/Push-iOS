//
//  AboutViewController.m
//  Push
//
//  Created by Christopher Guess on 1/25/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupViews
{
    self.aboutTextView = [[UITextView alloc] init];
    [self.view addSubview:self.aboutTextView];
    [self.aboutTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)loadAboutText
{
    NSData * htmlAbout = [self dataFromHtmlFile];
    
    self.aboutTextView.attributedText = [[NSAttributedString alloc] initWithData:htmlAbout
                                                                options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                          NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                                     documentAttributes:nil error:nil];
    self.aboutTextView.font = [UIFont fontWithName:@"Palatino-Roman" size:17.0f];
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
