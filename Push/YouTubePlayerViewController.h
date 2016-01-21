//
//  YouTubePlayerViewController.h
//  Push
//
//  Created by Christopher Guess on 1/20/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoPlayerViewController.h"
#import "YTPlayerView.h"

@interface YouTubePlayerViewController : VideoPlayerViewController <YTPlayerViewDelegate, PlayerControlBarViewDelegate>

@end
