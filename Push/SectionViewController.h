//
//  SectionViewController.h
//  Push
//
//  Created by Christopher Guess on 10/20/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SectionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (instancetype)initWithSectionTitle:(NSString*)title andArticles:(NSArray*)articles;

@property (nonatomic, readonly) NSString * sectionTitle;
@property (nonatomic, readonly) NSArray * articles;

@end
