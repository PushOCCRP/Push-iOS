//
//  NSMutableAttributedString+HTML.h
//  Push
//
//  Created by Christopher Guess on 2/2/16.

/***********************************************
 * The MIT License (MIT)
 * Copyright (c) 2016 Christopher Guess
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ************************************************/

/**
 A category on NSMutableAttributedString to add HTML features for UIKit that normally only available in AppKit
 The OSX documentation is here: https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ApplicationKit/Classes/NSAttributedString_AppKitAdditions/
 */
#import <Foundation/Foundation.h>


/**
 *  Object representing a HTML element
 *  This shouldn't be used outside of this class.
 */

@interface HTMLTag : NSObject

/**
 *  The type of the tag, "em" in <em>
 */

@property (nonatomic, retain, readonly) NSString * _Nonnull type;

/**
 *  Range of opening tag in text
 */

@property (nonatomic, readonly) NSRange openRange;

/**
 *  Attributes of tag
 */

@property (nonatomic, retain, readonly) NSDictionary * _Nullable attributes;

/**
 *  Range of closing tag in text
 */

@property (nonatomic) NSRange closingRange;

/**
 *  Text between the opening and closing tag
 */

@property (nonatomic, retain) NSString * _Nullable internalText;

@end


@interface NSMutableAttributedString (HTML)

/**
 *  Initializes and returns a new NSMutableAttributedString object from HTML contained in the given data object.
 *
 *  @param data          The data in HTML format from which to create the attributed string.
 *  @param docAttributes An in-out dictionary containing document-level attributes described in Document Attributes. May be NULL, in which case no document attributes are returned.
 *
 *  @return Returns an initialized object, or nil if the data can’t be decoded.
 */
- (instancetype _Nullable)initWithHTML:(NSData * _Nonnull)data documentAttributes:(NSDictionary<NSString *, id> * _Nullable * _Nullable)docAttributes;

/**
 *  Initializes and returns a new NSAttributedString object from the HTML contained in the given object and base URL.
 *
 *  @param data          The data in HTML format from which to create the attributed string.
 *  @param aURL          An NSURL that represents the base URL for all links within the HTML.
 *  @param docAttributes An in-out dictionary containing document-level attributes described in Document Attributes. May be NULL, in which case no document attributes are returned.
 *
 *  @return Returns an initialized object, or nil if the data can’t be decoded.
 */
- (instancetype _Nullable)initWithHTML:(NSData * _Nonnull)data baseURL:(NSURL * _Nullable)aURL documentAttributes:(NSDictionary<NSString *, id> * _Nullable * _Nullable)docAttributes;

/**
 *  Initializes and returns a new attributed string object from HTML contained in the given data object.
 *
 *  @param data    The data in HTML format from which to create the attributed string.
 *  @param options Specifies how the document should be loaded. Contains values described in Option keys for importing documents.
 *  @param dict    An in-out dictionary containing document-level attributes described in Document Attributes. May be NULL, in which case no document attributes are returned.
 *
 *  @return Returns an initialized object, or nil if the data can’t be decoded.
 */
- (instancetype _Nullable)initWithHTML:(NSData * _Nonnull)data options:(NSDictionary * _Nullable)options documentAttributes:(NSDictionary<NSString *, id> * _Nullable * _Nullable)dict;

/**
 *  Parses html string into tag pairs, and figuring out ranges.
 *  If a tag is not properly nested or closed it just discards it,
 *  For now, assumes thats it's invalid and ignores it.
 *
 *
 *  @return an array of HTMLTag elements
 */

- (NSArray*)parseHTMLString;
- (NSAttributedString*)processHTML;

@end
