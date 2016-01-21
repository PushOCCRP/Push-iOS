//
//  PlayerNavigationBarView.m
//  Push
//
//  Created by Christopher Guess on 1/21/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import "PlayerNavigationBarView.h"
@interface PlayerNavigationBarView()

@property (nonatomic, retain) IBOutlet UIButton * backButton;

@end

@implementation PlayerNavigationBarView

- (instancetype)init
{
    self = [[NSBundle mainBundle] loadNibNamed:@"PlayerNavigationBarView" owner:self options:nil].firstObject;
    
    return self;
}

- (IBAction)backButtonTapped:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(backButtonTapped)]){
        [self.delegate backButtonTapped];
    }
}

@end
