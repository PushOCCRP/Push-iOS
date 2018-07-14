//
//  LanguagePickerView.h
//  Push
//
//  Created by Christopher Guess on 1/13/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  LanguagePickerViewDelegate <NSObject>

- (void)languagePickerDidChooseLanguage:(NSString*)language;

@end

@interface LanguagePickerView : UIView <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak, nullable) id <LanguagePickerViewDelegate> delegate;

@end
