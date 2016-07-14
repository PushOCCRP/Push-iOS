//
//  ClickIndicator.m
//  Push
//
//  Created by Christopher Guess on 6/16/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import "ClickIndicator.h"

@interface ClickIndicatorDrawing : NSObject

// Drawing Methods
+ (void)drawCanvas1WithColor:(UIColor*)color;

@end

@implementation ClickIndicatorDrawing

#pragma mark Initialization

+ (void)initialize
{
}

#pragma mark Drawing Methods

+ (void)drawCanvas1WithColor:(UIColor*)color
{    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(1.5, 1.5)];
    [bezierPath addLineToPoint: CGPointMake(17.5, 16.5)];
    [color setStroke];
    bezierPath.lineWidth = 2;
    [bezierPath stroke];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(1, 31)];
    [bezier2Path addLineToPoint: CGPointMake(17, 16)];
    [color setStroke];
    bezier2Path.lineWidth = 2;
    [bezier2Path stroke];
}

@end

@interface ClickIndicator()

@property (nonatomic, retain) UIColor * color;

@end

@implementation ClickIndicator

- (instancetype)initWithColor:(UIColor*)color
{
    self = [super initWithFrame:CGRectMake(0, 0, 16.0f, 29.0f)];
    if(self){
        self.backgroundColor = [UIColor clearColor];
        self.color = color;
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [ClickIndicatorDrawing drawCanvas1WithColor:self.color];
}


@end
