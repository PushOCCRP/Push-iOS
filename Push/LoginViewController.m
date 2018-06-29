//
//  LoginViewController.m
//  Push
//
//  Created by Christopher Guess on 1/16/18.
//  Copyright © 2018 OCCRP. All rights reserved.
//

#import "LoginViewController.h"
#import <Masonry/Masonry.h>
#import "AnalyticsManager.h"
#import "LanguageManager.h"
#import "SettingsManager.h"
#import "PushSyncManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <OnePasswordExtension/OnePasswordExtension.h>

#pragma mark - InsetTextField
@interface InsetTextField : UITextField

@property (nonatomic, assign) UIEdgeInsets insets;

@end

@implementation InsetTextField : UITextField

- (CGRect)textRectForBounds:(CGRect)bounds {
    CGRect paddedRect = UIEdgeInsetsInsetRect(bounds, self.insets);
    
    if (self.rightViewMode == UITextFieldViewModeAlways || self.rightViewMode == UITextFieldViewModeUnlessEditing) {
        return [self adjustRectWithWidthRightView:paddedRect];
    }
    return paddedRect;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    CGRect paddedRect = UIEdgeInsetsInsetRect(bounds, self.insets);
    
    if (self.rightViewMode == UITextFieldViewModeAlways || self.rightViewMode == UITextFieldViewModeUnlessEditing) {
        return [self adjustRectWithWidthRightView:paddedRect];
    }
    return paddedRect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect paddedRect = UIEdgeInsetsInsetRect(bounds, self.insets);
    
    if (self.rightViewMode == UITextFieldViewModeAlways || self.rightViewMode == UITextFieldViewModeWhileEditing) {
        return [self adjustRectWithWidthRightView:paddedRect];
    }
    return paddedRect;
}

- (CGRect)adjustRectWithWidthRightView:(CGRect)bounds {
    CGRect paddedRect = bounds;
    paddedRect.size.width -= CGRectGetWidth(self.rightView.frame);
    
    return paddedRect;
}

@end

# pragma mark - LoginViewController
typedef enum : NSUInteger {
    TextFieldLogin,
    TextFieldPassword,
} TextFieldType;

@interface LoginViewController ()

@property (nonatomic, retain) UIScrollView * scrollView;

@property (nonatomic, retain) UIImageView * logoImageView;

@property (nonatomic, retain) UILabel * loginLabel;
@property (nonatomic, retain) UILabel * passwordLabel;

@property (nonatomic, retain) InsetTextField * loginTextField;
@property (nonatomic, retain) InsetTextField * passwordTextField;

@property (nonatomic, retain) UIButton * loginButton;
@property (nonatomic, retain) UIButton * passwordManagerButton;

@property (nonatomic, retain) NSMutableArray * listeners;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupViews];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = [SettingsManager sharedManager].name;
    [self.passwordManagerButton setHidden:![[OnePasswordExtension sharedExtension] isAppExtensionAvailable]];
    self.listeners = [NSMutableArray arrayWithCapacity:2];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[AnalyticsManager sharedManager] logContentViewWithName:@"Login Page Appeared" contentType:@"Navigation"
                                   contentId:nil customAttributes:nil];
    [[AnalyticsManager sharedManager] startTimerForContentViewWithObject:self name:@"Login Page Viewed Time" contentType:@"Login Page View Time" contentId:nil customAttributes:nil];
    
    [self registerForKeyboardChanges];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self deregisterForKeyboardChanges];
    [[AnalyticsManager sharedManager] endTimerForContentViewWithObject:self andName:@"Login Page Viewed Time"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)registerForKeyboardChanges {
    [self.listeners addObject:[NSNotificationCenter.defaultCenter addObserverForName:UIKeyboardDidShowNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary* info = [note userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
        [self.scrollView scrollRectToVisible:self.loginButton.frame animated:YES];
        self.scrollView.scrollEnabled = YES;
    }]];
    
    [self.listeners addObject:[NSNotificationCenter.defaultCenter addObserverForName:UIKeyboardDidHideNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
        [self.scrollView scrollRectToVisible:CGRectZero animated:YES];
        self.scrollView.scrollEnabled = NO;
    }]];
}

- (void)deregisterForKeyboardChanges {
    [self.listeners enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [NSNotificationCenter.defaultCenter removeObserver:obj];
    }];
}

- (void)setupViews
{
    self.view.backgroundColor = [SettingsManager sharedManager].navigationBarColor;
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.scrollEnabled = NO;
    [self.view addSubview:self.scrollView];
    UIView * contentView = [[UIView alloc] init];
    [self.scrollView addSubview:contentView];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
        make.height.equalTo(self.view);
        make.width.equalTo(self.view);
    }];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.height.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    
    self.logoImageView = [[UIImageView alloc] init];
    
    UILabel * explainerLabel = [[UILabel alloc] init];
    
    self.loginLabel = [[UILabel alloc] init];
    self.passwordLabel = [[UILabel alloc] init];
    
    self.loginTextField = [[InsetTextField alloc] init];
    self.passwordTextField = [[InsetTextField alloc] init];
    
    self.loginButton = [[UIButton alloc] init];
    self.passwordManagerButton = [[UIButton alloc] init];
    
    self.loginTextField.delegate = self;
    self.loginTextField.tag = TextFieldLogin;
    self.passwordTextField.delegate = self;
    self.passwordTextField.tag = TextFieldPassword;
    
    [self.loginButton addTarget:self action:@selector(loginButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.passwordManagerButton addTarget:self action:@selector(findLoginFromGenericPassword:) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addSubview:self.logoImageView];
    [contentView addSubview:explainerLabel];
    [contentView addSubview:self.loginLabel];
    [contentView addSubview:self.loginTextField];
    [contentView addSubview:self.passwordLabel];
    [contentView addSubview:self.passwordTextField];
    [contentView addSubview:self.loginButton];
    [contentView addSubview:self.passwordManagerButton];
    
    self.logoImageView.image = [UIImage imageNamed:@"icon-appstore"];
    
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(contentView.self.mas_safeAreaLayoutGuideTop).offset(20);
        } else {
            make.top.equalTo(contentView.self.mas_top).offset(20);
        }
        make.centerX.equalTo(self.view);
        make.width.equalTo(@100);
        make.height.equalTo(@100);
    }];
    
    explainerLabel.text = MYLocalizedString(@"Please Login Explainer", @"Please login with your subscriber's account to access the content.");
    explainerLabel.textColor = [UIColor whiteColor];
    explainerLabel.textAlignment = NSTextAlignmentCenter;
    explainerLabel.numberOfLines = 0;
    explainerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [explainerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logoImageView.mas_bottom).offset(20);
        make.left.equalTo(contentView.mas_left).offset(20);
        make.right.equalTo(contentView.mas_right).offset(-20);
    }];
    
    self.loginLabel.text = MYLocalizedString(@"Login", @"Login") ;
    self.loginLabel.textColor = [SettingsManager sharedManager].navigationTextColor;
    [self.loginLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(explainerLabel.self.mas_bottom).offset(20);
        make.left.equalTo(contentView.mas_left).offset(20);
        make.right.equalTo(contentView.mas_right).offset(-20);
        make.height.equalTo(@20);
    }];
    
    self.loginTextField.backgroundColor = [SettingsManager sharedManager].navigationTextColor;
    self.loginTextField.layer.cornerRadius = 5.0;
    self.loginTextField.insets = UIEdgeInsetsMake(0, 10, 0, 10);
    self.loginTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.loginTextField.placeholder = MYLocalizedString(@"Email Address", @"Email Address");
    if (@available(iOS 11, *)) {
        self.loginTextField.textContentType = UITextContentTypeEmailAddress;
    }
    [self.loginTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loginLabel.mas_bottom).offset(10);
        make.left.equalTo(self.loginLabel.mas_left);
        make.right.equalTo(self.loginLabel.mas_right);
        make.height.equalTo(@40);
    }];
    
    self.passwordLabel.text = MYLocalizedString(@"Password", @"Password");
    self.passwordLabel.textColor = [SettingsManager sharedManager].navigationTextColor;
    [self.passwordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loginTextField.mas_bottom).offset(10);
        make.left.equalTo(contentView.mas_left).offset(20);
        make.right.equalTo(contentView.mas_right).offset(-20);
        make.height.equalTo(@20);
    }];

    self.passwordTextField.backgroundColor = [SettingsManager sharedManager].navigationTextColor;
    self.passwordTextField.placeholder = MYLocalizedString(@"Password", @"Password");
    if (@available(iOS 11, *)) {
        self.passwordTextField.textContentType = UITextContentTypePassword;
    }
    self.passwordTextField.layer.cornerRadius = 5.0;
    self.passwordTextField.insets = UIEdgeInsetsMake(0, 10, 0, 10);
    [self.passwordTextField setSecureTextEntry:YES];
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordLabel.mas_bottom).offset(10);
        make.left.equalTo(self.passwordLabel);
        make.right.equalTo(self.passwordLabel);
        make.height.equalTo(@40);
    }];
    
    [self.loginButton setTitle:MYLocalizedString(@"Login", @"Login") forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[SettingsManager sharedManager].navigationTextColor forState:UIControlStateNormal];
    self.loginButton.layer.cornerRadius = 5.0;
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordTextField.mas_bottom).offset(20);
        make.height.equalTo(@50);
        make.centerX.equalTo(contentView);
    }];
    
    [self.passwordManagerButton setImage:[UIImage imageNamed:@"onepassword-extension-light"] forState:UIControlStateNormal];
    
    NSBundle * onePasswordBundle = [NSBundle bundleForClass:[OnePasswordExtension class]];
    NSString * newPath = [NSString stringWithFormat:@"%@/OnePasswordExtensionResources.bundle", [onePasswordBundle bundlePath]];
    onePasswordBundle = [NSBundle bundleWithPath:newPath];
    UIImage * passwordImage = [UIImage imageNamed:@"onepassword-button-light" inBundle:onePasswordBundle compatibleWithTraitCollection:nil];
    [self.passwordManagerButton setImage:passwordImage forState:UIControlStateNormal];
    [self.passwordManagerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loginButton.mas_top);
        make.bottom.equalTo(self.loginButton.mas_bottom);
        make.left.equalTo(self.loginButton.mas_right).offset(40);
        make.width.equalTo(@40);
    }];
    
    UIView * spacerView = [[UIView alloc] init];
    [contentView addSubview:spacerView];
    [spacerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loginButton.mas_bottom);
        make.bottom.equalTo(contentView);
    }];
}

- (IBAction)loginButtonTapped:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [PushSyncManager.sharedManager loginWithUsername:self.loginTextField.text password:self.passwordTextField.text completionHandler:^(id articles) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:error.localizedDescription
                                         message:error.localizedFailureReason
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction * okButton = [UIAlertAction actionWithTitle:MYLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    }];
}

- (IBAction)findLoginFromGenericPassword:(id)sender {
    __weak typeof (self) miniMe = self;
    [[OnePasswordExtension sharedExtension] findLoginForURLString:[SettingsManager sharedManager].cmsBaseUrl.absoluteString forViewController:self sender:sender completion:^(NSDictionary *loginDict, NSError *error) {
        if (!loginDict) {
            if (error.code != AppExtensionErrorCodeCancelledByUser) {
                NSLog(@"Error invoking GenericPassword App Extension for find login: %@", error);
            }
            return;
        }
        
        __strong typeof(self) strongMe = miniMe;
        strongMe.loginTextField.text = loginDict[AppExtensionUsernameKey];
        strongMe.passwordTextField.text = loginDict[AppExtensionPasswordKey];
    }];
}


#pragma mark - UITableViewDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    switch (textField.tag) {
        case TextFieldLogin:
            [self.passwordTextField becomeFirstResponder];
            break;
        case TextFieldPassword:
            [self loginButtonTapped:self.loginButton];
            [self.passwordTextField resignFirstResponder];
            break;
        default:
            break;
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.scrollView scrollRectToVisible:textField.frame animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason {
    [self.scrollView scrollRectToVisible:textField.frame animated:YES];
}


- (id)findFirstResponder
{
    if (self.isFirstResponder) {
        return self;
    }
    for (UIView *subView in self.view.subviews) {
        if ([subView isFirstResponder]) {
            return subView;
        }
    }
    return nil;
}


@end


