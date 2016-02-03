//
//  PlayerControlBarView.m
//  Push
//
//  Created by Christopher Guess on 1/20/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import "PlayerControlBarView.h"
#import "PlayButtonView.h"
#import "PauseButtonView.h"

@interface PlayerControlBarView ()

@property (nonatomic, retain) IBOutlet UISlider * scrubber;

@property (nonatomic, retain) UIView * playButtonView;
@property (nonatomic, retain) UIView * pauseButtonView;

@end

@implementation PlayerControlBarView

- (instancetype)init
{
    self = [[NSBundle mainBundle] loadNibNamed:@"PlayerControlBarView" owner:self options:nil].firstObject;
    [self.scrubber addTarget:self action:@selector(scrubberDidChangeValue:) forControlEvents:UIControlEventValueChanged];
    
    [self createPlayButtonViews];

    return self;
}

- (void)createPlayButtonViews
{
    [self.playButton setTitle:@"" forState:UIControlStateNormal];
    CGRect frame = self.playButton.frame;
    frame.origin = CGPointMake(0, 0);
    self.playButtonView = [[PlayButtonView alloc] initWithFrame:frame Target:self andSelector:@selector(playButtonTapped:)];
    self.pauseButtonView = [[PauseButtonView alloc] initWithFrame:frame Target:self andSelector:@selector(playButtonTapped:)];
    
    [self.playButton addSubview:self.playButtonView];
}


- (IBAction)playButtonTapped:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(playButtonTapped)]){
        [self.delegate playButtonTapped];
    }
}

- (void)setPlayState:(PushPlayerState)playState
{
    _playState = playState;
    
    switch (playState) {
        case pushPlaying:
            [self.playButtonView removeFromSuperview];
            [self.playButton addSubview:self.pauseButtonView];
            //[self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
            break;
        case pushPaused:
            [self.pauseButtonView removeFromSuperview];
            [self.playButton addSubview:self.playButtonView];
            //[self.playButton setTitle:@"Play" forState:UIControlStateNormal];
            break;
        case pushStopped:
            [self.pauseButtonView removeFromSuperview];
            [self.playButton addSubview:self.playButtonView];
            //[self.playButton setTitle:@"Play" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

- (void)scrubberDidChangeValue:(UISlider*)sender
{
    NSLog(@"Scrubber changed to: %f", sender.value);
    if(self.delegate && [self.delegate respondsToSelector:@selector(didScrubToValue:)]){
        [self.delegate didScrubToValue:sender.value];
    }
}

- (float)playerLocation
{
    return self.scrubber.value;
}

- (void)setPlayerLocation:(float)playerLocation
{
    [self.scrubber setValue:playerLocation animated:YES];
}

@end
