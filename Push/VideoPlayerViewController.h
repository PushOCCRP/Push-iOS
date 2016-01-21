//
//  VideoPlayerViewController.h
//  Push
//
//  Created by Christopher Guess on 1/20/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerControlBarView.h"
#import "PlayerNavigationBarView.h"

@interface VideoPlayerViewController : UIViewController <PlayerControlBarViewDelegate, PlayerNavigationBarViewDelegate>

@property (nonatomic, retain) NSString * videoId;
@property (nonatomic, readonly) PlayerControlBarView * playerControlBar;
@property (nonatomic, readonly) PlayerNavigationBarView * playerNavigationBar;

- (instancetype)initWithVideoId:(NSString*)videoId;
- (void)switchInterfaceOrientation:(UIInterfaceOrientation)orientation;

// Call this after transitioning so the views layout correctly
- (void)setupPlayer;

- (void)resetHideControlTimer;

@end
