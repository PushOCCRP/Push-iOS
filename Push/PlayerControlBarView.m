//
//  PlayerControlBarView.m
//  Push
//
//  Created by Christopher Guess on 1/20/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import "PlayerControlBarView.h"

@interface PlayerControlBarView ()

@property (nonatomic, retain) IBOutlet UISlider * scrubber;

@end

@implementation PlayerControlBarView

- (instancetype)init
{
    self = [[NSBundle mainBundle] loadNibNamed:@"PlayerControlBarView" owner:self options:nil].firstObject;
    [self.scrubber addTarget:self action:@selector(scrubberDidChangeValue:) forControlEvents:UIControlEventValueChanged];
    
    return self;
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
            [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
            break;
        case pushPaused:
            [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
            break;
        case pushStopped:
            [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
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
