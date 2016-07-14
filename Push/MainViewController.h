//
//  MainViewController.h
//  Push
//
//  Created by Christopher Guess on 11/11/15.
//  Copyright © 2015 OCCRP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LanguagePickerView.h"
#import "PromotionView.h"

@interface MainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, LanguagePickerViewDelegate, PromotionViewDelegate>

@end
