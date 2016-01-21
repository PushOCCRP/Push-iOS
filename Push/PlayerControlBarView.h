//
//  PlayerControlBarView.h
//  Push
//
//  Created by Christopher Guess on 1/20/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    pushPlaying,
    pushPaused,
    pushStopped,
} PushPlayerState;

@protocol PlayerControlBarViewDelegate <NSObject>

- (void)playButtonTapped;
- (void)didScrubToValue:(float)value;

@end

@interface PlayerControlBarView : UIView

@property (nonatomic, assign) id<PlayerControlBarViewDelegate> delegate;

@property (nonatomic, assign) IBOutlet UIButton * playButton;

@property (nonatomic, assign) PushPlayerState playState;

@property (nonatomic, assign) float playerLocation;

@end
