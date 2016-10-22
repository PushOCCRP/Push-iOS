//
//  NSURL+URLWithNonLatinString.h
//  Push
//
//  Created by Christopher Guess on 8/5/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (URLWithNonLatinString)

+ (instancetype)URLWithNonLatinString:(NSString*)urlString;

@end
