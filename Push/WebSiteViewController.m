//
//  WebSiteViewController.m
//  Push
//
//  Created by Christopher Guess on 6/15/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import "WebSiteViewController.h"
#import <WebKit/WebKit.h>
#import <Masonry/Masonry.h>

@interface WebSiteViewController ()

@property (nonatomic, retain, readonly) WKWebView * browser;
@property (nonatomic, retain, readonly) NSURL * url;

@end

@implementation WebSiteViewController

- (instancetype)initWithURL:(NSURL*)url {
    self = [super init];
    if(self){
        _url = url;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc] init];
    _browser = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
    
    [self.view addSubview:self.browser];
    
    UIToolbar * toolbar = [[UIToolbar alloc] init];
    UIBarButtonItem * backButton = [[UIBarButtonItem alloc] initWithTitle:@"< Back" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped)];
    [toolbar setItems:@[backButton]];
    
    [self.view addSubview:toolbar];
    
    [toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
        make.right.equalTo(self.view);
        make.left.equalTo(self.view);
        make.height.equalTo(@50);
    }];
    
    [_browser mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.right.equalTo(self.view);
        make.left.equalTo(self.view);
        make.bottom.equalTo(toolbar.mas_top);
    }];
    
    [self loadURL:self.url];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadURL:(NSURL*)url
{
    NSURLRequest * request = [NSURLRequest requestWithURL:self.url];
    [self.browser loadRequest:request];
}

- (void)backButtonTapped
{
    if([self.browser canGoBack]){
        [self.browser goBack];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
