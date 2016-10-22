//
//  NSURL+URLWithNonLatinString.m
//  Push
//
//  Created by Christopher Guess on 8/5/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import "NSURL+URLWithNonLatinString.h"

@implementation NSURL (URLWithNonLatinString)

+ (instancetype)URLWithNonLatinString:(NSString*)urlString
{
    NSString * escapedUrlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSURL * url = [NSURL URLWithString:escapedUrlString];
    
    return url;
}

@end
