//
//  LanguagePickerView.m
//  Push
//
//  Created by Christopher Guess on 1/13/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import "LanguagePickerView.h"
#import "LanguageManager.h"
#import <Masonry/Masonry.h>

@interface LanguagePickerView()

@property (nonatomic, retain) UIPickerView * pickerView;

@end

@implementation LanguagePickerView


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setUp];
    }
    
    return self;
}

- (void)setUp
{
    self.backgroundColor = [UIColor whiteColor];
    [self addShadow];
    [self addPickerView];
    [self addSubmitButton];
    [self setPickerViewToCurrentLanguage];
}

- (void)addShadow
{
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, -5.0f);
    self.layer.shadowOpacity = 0.1f;
    self.layer.shadowRadius = 3.0f;
}

- (void)addPickerView
{
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 20.0f, self.frame.size.width, self.frame.size.height - 80.0f)];

    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    
    
    [self addSubview:self.pickerView];
}

- (void)addSubmitButton
{
    UIButton * submitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    submitButton.frame = CGRectMake(0, self.pickerView.frame.size.height, self.frame.size.width, self.frame.size.height - self.pickerView.frame.size.height);
    
    [submitButton setTitle:MYLocalizedString(@"ChooseLanguage", @"Choose Language") forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    [submitButton addTarget:self action:@selector(submitButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:submitButton];
}

- (void)setPickerViewToCurrentLanguage
{
    NSString * currentLanguage = [LanguageManager sharedManager].language;
    NSUInteger languageIndex = [[LanguageManager sharedManager].availableLanguages indexOfObject:currentLanguage];
    
    [self.pickerView selectRow:languageIndex inComponent:0 animated:NO];
}

- (void)submitButtonTapped
{
    NSUInteger currentSelectedRow = [self.pickerView selectedRowInComponent:0];
    NSString * currentSelectedLanguage = [LanguageManager sharedManager].availableLanguages[currentSelectedRow];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(languagePickerDidChooseLanguage:)]){
        [self.delegate languagePickerDidChooseLanguage:currentSelectedLanguage];
    }
}

// UIPickerViewDataSource
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [LanguageManager sharedManager].availableLanguages.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

//UIPickerViewDelegate
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [LanguageManager sharedManager].nativeAvailableLanguages[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
}


@end
