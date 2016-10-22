//
//  LiveVideoViewController.m
//  Push
//
//  Created by Christopher Guess on 9/2/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import "LiveVideoViewController.h"
#import "AnalyticsManager.h"
#import <Masonry/Masonry.h>

@interface LiveVideoViewController()

@property (nonatomic, assign) BOOL shouldAutoRotate;

@end

@implementation LiveVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self switchInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
    //self.showingControls = YES;
    //[self startHideControlTimer];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [AnalyticsManager logContentViewWithName:@"Video Player Appeared" contentType:@"Navigation"
                                   contentId:nil customAttributes:nil];
    [AnalyticsManager startTimerForContentViewWithObject:self name:@"Video Viewed Time" contentType:@"Video View Time" contentId:nil customAttributes:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [AnalyticsManager endTimerForContentViewWithObject:self andName:@"Video Viewed Time"];
}

- (BOOL)shouldAutorotate
{
    return _shouldAutoRotate;
}

- (void)setupPlayer
{
    _playerControlBar = [[PlayerControlBarView alloc] init];
    _playerControlBar.delegate = self;
    [self.view addSubview:_playerControlBar];
    
    _playerNavigationBar = [[PlayerNavigationBarView alloc] init];
    _playerNavigationBar.delegate = self;
    [self.view addSubview:_playerNavigationBar];
    
    [_playerControlBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    [_playerNavigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width);
        make.top.equalTo(self.view.mas_top);
    }];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)switchInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    self.shouldAutoRotate = YES;
    
    NSNumber *value = [NSNumber numberWithInt: orientation];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

#pragma mark - PlayerControlBarViewDelegate

- (void)playButtonTapped
{
    // Stub implementation
}

- (void)didScrubToValue:(float)value
{
    // Stub implementation
}

#pragma mark - PlayerNavigationBarViewDelegate

- (void)backButtonTapped
{
    [self switchInterfaceOrientation:UIInterfaceOrientationPortrait];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
