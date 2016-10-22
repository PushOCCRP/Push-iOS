//
//  LiveVideoViewController.h
//  Push
//
//  Created by Christopher Guess on 9/2/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerControlBarView.h"
#import "PlayerNavigationBarView.h"

@interface LiveVideoViewController : UIViewController <PlayerControlBarViewDelegate, PlayerNavigationBarViewDelegate>

@property (nonatomic, retain) NSString * videoId;
@property (nonatomic, readonly) PlayerControlBarView * playerControlBar;
@property (nonatomic, readonly) PlayerNavigationBarView * playerNavigationBar;

@end
