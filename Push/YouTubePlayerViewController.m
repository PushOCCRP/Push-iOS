//
//  YouTubePlayerViewController.m
//  Push
//
//  Created by Christopher Guess on 1/20/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import "YouTubePlayerViewController.h"

@interface YouTubePlayerViewController ()

@property (nonatomic, retain) YTPlayerView * player;

@end

@implementation YouTubePlayerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setupPlayer {
    [self setUpPlayerView];
    [super setupPlayer];
}

- (void)setUpPlayerView
{
    self.player = [[YTPlayerView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.player];
    self.player.delegate = self;
    NSDictionary *playerVars = @{
                                 @"playsinline" : @1,
                                 @"autoplay": @1,
                                 @"fs": @0,
                                 @"controls": @0,
                                 @"rel": @0,
                                 @"showinfo": @0,
                                 @"modestbranding": @0,
                                 };
    [self.player loadWithVideoId:self.videoId playerVars:playerVars];
    self.player.userInteractionEnabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PlayerControlBarViewDelegate

- (void)playButtonTapped
{
    switch (self.player.playerState) {
        case kYTPlayerStatePlaying:
            [self.player pauseVideo];
            break;
        case kYTPlayerStatePaused:
            [self.player playVideo];
        default:
            break;
    }
}

- (void)didScrubToValue:(float)value
{
    [self resetHideControlTimer];
    float seconds = self.player.duration * value;
    [self.player seekToSeconds:seconds allowSeekAhead:YES];
}

#pragma mark - YTPlayerViewDelegate

- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView
{
    [self.player playVideo];
}

- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state
{
    switch (state) {
        case kYTPlayerStatePlaying:
        case kYTPlayerStateBuffering:
            self.playerControlBar.playState = pushPlaying;
            break;
        case kYTPlayerStatePaused:
            self.playerControlBar.playState = pushPaused;
            break;
        case kYTPlayerStateEnded:
            [self backButtonTapped];
            break;
        default:
            self.playerControlBar.playState = pushStopped;
            break;
    }
}

- (void)playerView:(YTPlayerView *)playerView didChangeToQuality:(YTPlaybackQuality)quality
{
    
}

- (void)playerView:(YTPlayerView *)playerView receivedError:(YTPlayerError)error
{
    NSLog(@"Error: %ld", (long)error);
}

- (void)playerView:(YTPlayerView *)playerView didPlayTime:(float)playTime
{
    self.playerControlBar.playerLocation = playTime / self.player.duration;
}

- (UIColor *)playerViewPreferredWebViewBackgroundColor:(YTPlayerView *)playerView
{
    return [UIColor greenColor];
}



@end
