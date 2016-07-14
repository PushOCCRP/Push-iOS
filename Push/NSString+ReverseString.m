//
//  NSString+ReverseString.m
//  Push
//
//  Created by Christopher Guess on 7/6/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import "NSString+ReverseString.h"

@implementation NSString (ReverseString)

- (instancetype)reverse
{
    NSMutableString * reversedString = [NSMutableString string];
    
    // Probably shoudl be done with scanner, but I don't know the API off the top of my head
    // This is probably fast enough...
    
    NSUInteger index = self.length - 1;
    
    while(index != 0){
        char character = [self characterAtIndex:index];
    
        [reversedString appendFormat:@"%c", character];
    }
    
    return [NSString stringWithString:reversedString];
    
    /*NSScanner * scanner = [NSScanner scannerWithString:self];
    NSCharacterSet * characterSet = [NSCharacterSet characterSetWithCharactersInString:self];
    
    while (!scanner.isAtEnd) {
         NSString * _Nullable character = @"";
        [scanner scanUpToCharactersFromSet:characterSet intoString:character];
        
        
    }*/
}

@end
