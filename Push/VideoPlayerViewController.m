//
//  VideoPlayerViewController.m
//  Push
//
//  Created by Christopher Guess on 1/20/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import <Masonry/Masonry.h>

@interface VideoPlayerViewController ()

@property (nonatomic, assign) BOOL shouldAutoRotate;
@property (nonatomic, assign) BOOL showingControls;

@property (nonatomic, retain) NSTimer * hideControlBarTimer;

@end

@implementation VideoPlayerViewController

- (instancetype)initWithVideoId:(NSString*)videoId
{
    self = [super init];
    if(self){
        self.videoId = videoId;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self switchInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
    self.showingControls = YES;
    [self startHideControlTimer];
    // Do any additional setup after loading the view.
}

- (BOOL)shouldAutorotate
{
    return _shouldAutoRotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)switchInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    self.shouldAutoRotate = YES;
    
    NSNumber *value = [NSNumber numberWithInt: orientation];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

// Ok, let's do this
/*
 If there's a touch detected show a uinavigation bar
 IT has the the play button, and a uiprogressbar with the total length divided by it's current spot
 Also a back button on the top
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touches Began");
    if([self checkForTouchesOnControlBar:touches withEvent:event]){
        [self resetHideControlTimer];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touches Moved");
    if([self checkForTouchesOnControlBar:touches withEvent:event]){
        [self resetHideControlTimer];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touches Cancelled");

    if([self checkForTouchesOnControlBar:touches withEvent:event]){
        [self resetHideControlTimer];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touches Ended");
    if(!self.showingControls){
        [self showControl];
        [self startHideControlTimer];
    } else {
        [self.hideControlBarTimer invalidate];
        if([self checkForTouchesOnControlBar:touches withEvent:event]){
            [self resetHideControlTimer];
        } else {
            [self hideControl];
        }
    }
}

- (BOOL)checkForTouchesOnControlBar:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint locationPoint = [[touches anyObject] locationInView:self.view];
    UIView* viewYouWishToObtain = [self.view hitTest:locationPoint withEvent:event];
    
    if(self.playerControlBar == viewYouWishToObtain || [self.playerControlBar.subviews containsObject:viewYouWishToObtain]){
        return YES;
    } else {
        return NO;
    }
}

- (void)resetHideControlTimer
{
    [self.hideControlBarTimer invalidate];
    [self startHideControlTimer];
}

- (void)startHideControlTimer
{
    self.hideControlBarTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(hideControl) userInfo:nil repeats:NO];
}

- (void)showControl
{
    NSLog(@"Showing Controls");
    self.showingControls = YES;
    [self.playerControlBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    [self.playerNavigationBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width);
        make.top.equalTo(self.view.mas_top);
    }];
    
    [UIView animateWithDuration:0.5f animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)hideControl
{
    NSLog(@"Hiding Controls");
    self.showingControls = NO;
    [self.playerControlBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width);
        make.bottom.equalTo(self.view.mas_bottom).offset(self.playerControlBar.frame.size.height);
    }];
    [self.playerNavigationBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width);
        make.top.equalTo(self.view.mas_top).offset(-self.playerNavigationBar.frame.size.height);
    }];

    
    [UIView animateWithDuration:0.5f animations:^{
        [self.view layoutIfNeeded];
    }];
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
