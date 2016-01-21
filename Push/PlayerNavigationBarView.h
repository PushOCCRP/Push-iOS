//
//  PlayerNavigationBarView.h
//  Push
//
//  Created by Christopher Guess on 1/21/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlayerNavigationBarViewDelegate <NSObject>

- (void)backButtonTapped;

@end

@interface PlayerNavigationBarView : UIView

@property (nonatomic, assign) id<PlayerNavigationBarViewDelegate> delegate;

@end
