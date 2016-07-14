//
//  PushUITests.m
//  PushUITests
//
//  Created by Christopher Guess on 10/29/15.
//  Copyright © 2015 OCCRP. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PushUITests-Swift.h"

@interface PushUITests : XCTestCase

@end

@implementation PushUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.

    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [Snapshot setupSnapshot:app];
    [app launch];
    
    //Now, we start at the top, this "reset" the language settings
    //[self switchApp:app toLanguage:@"Azerbaijani"];
    //sleep(10);
    
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    [self takeDisplayPhotosInApp:app forLanguage:@"English"];
    /*
    sleep(5);
    NSString * language = [NSLocale preferredLanguages][0];
    
    //if([[language substringToIndex:2] isEqualToString:@"en"]){
        [self switchApp:app toLanguage:@"Russian"];
        sleep(3);
        [self switchApp:app toLanguage:@"English"];
        sleep(10);
        [self takeDisplayPhotosInApp:app forLanguage:@"English"];
    //}else if([[language substringToIndex:2] isEqualToString:@"ru"]){
        [self switchApp:app toLanguage:@"English"];
        sleep(3);
        [self switchApp:app toLanguage:@"Russian"];
        sleep(10);
        [self takeDisplayPhotosInApp:app forLanguage:@"Russian"];
    //}
    */
    
}

- (void)switchApp:(XCUIApplication *)app toLanguage:(NSString*)language
{
    NSString * nativeName = nil;
    if([language isEqualToString:@"Russian"]){
        nativeName = @"русский";
    }else if([language isEqualToString:@"Azerbaijani"]){
        nativeName = @"Azərbaycanlı";
    }else if([language isEqualToString:@"English"]){
        nativeName = @"English";
    }
    
    if([app.navigationBars[@"MainView"].buttons[@"AД"] exists]){
        [app.navigationBars[@"MainView"].buttons[@"AД"] tap];
        [app.pickerWheels.element adjustToPickerWheelValue:nativeName];
        if([app.buttons[@"Выберите язык"] exists]){
            [app.buttons[@"Выберите язык"] tap];
        }else if([app.buttons[@"Dil Seçin"] exists]){
            [app.buttons[@"Dil Seçin"] tap];
        } else if([app.buttons[@"Choose Language"] exists]){
            [app.buttons[@"Choose Language"] tap];
        }
    }
}

- (void)takeDisplayPhotosInApp:(XCUIApplication*)app forLanguage:(NSString*)language
{
    [Snapshot snapshot:[NSString stringWithFormat:@"%@-01ArticleList", language] waitForLoadingIndicator:YES];
    [[app.tables.element.cells elementBoundByIndex:1] tap];
    [Snapshot snapshot:[NSString stringWithFormat:@"%@-02ArticleView", language] waitForLoadingIndicator:YES];
    
    NSString * backButtonText = nil;
    if([app.buttons[@"Back"] exists]){
        backButtonText = @"Back";
    }else if([app.buttons[@"Назад"] exists]){
        backButtonText = @"Назад";
    }else if([app.buttons[@"Geri"] exists]){
        backButtonText = @"Geri";
    }else if([app.buttons[@"Înapoi"] exists]){
        backButtonText = @"Înapoi";
    }
    [[[[app.navigationBars[@"ArticlePageView"] childrenMatchingType:XCUIElementTypeButton] matchingIdentifier:backButtonText] elementBoundByIndex:0] tap];

}

@end
