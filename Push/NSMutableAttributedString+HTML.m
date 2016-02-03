//
//  NSMutableAttributedString+HTML.m
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

#import "NSMutableAttributedString+HTML.h"
#import <UIKit/UIKit.h>

/**
 *  Internal object representing a HTML <a href=''></a> element
 *  This shouldn't be used outside of this class.
 */
@interface HtmlLink : NSObject

/**
 *  Range of link tag in text
 */
@property (nonatomic, assign, readonly) NSRange range;
/**
 *  NSURL the tag represents
 */
@property (nonatomic, retain, readonly) NSURL * url;
/**
 *  NSString of the display text from the tag
 */
@property (nonatomic, retain, readonly) NSString * text;
/**
 *  The full original tag (useful for reference after adding a base url)
 */
@property (nonatomic, retain, readonly) NSString * originalTag;

/**
 *  Intialize HtmlLink object
 *
 *  @param range Range of link tag in text
 *  @param url    NSURL the tag represents
 *  @param text  NSString of the display text from the tag
 *  @param originTag The full original tag (useful for reference after adding a base url)
 *
 *  @return HtmlLink object representing
 */
- (instancetype)initWithRange:(NSRange)range urlString:(NSString*)urlString text:(NSString*)text originalTag:(NSString*)originalTagString;

@end

/**
 *  Internal object representing a HTML <a href=''></a> element
 *  This shouldn't be used outside of this class.
 */
@implementation HtmlLink

/**
 *  Intialize HtmlLink object
 *
 *  @param range Range of link tag in text
 *  @param url    NSURL the tag represents
 *  @param text  NSString of the display text from the tag
 *  @param originTag The full original tag (useful for reference after adding a base url)
 *
 *  @return HtmlLink object representing
 */
- (instancetype)initWithRange:(NSRange)range urlString:(NSString*)urlString text:(NSString*)text originalTag:(NSString*)originalTagString
{
    self = [super init];
    if(self){
        _range = range;
        _url = [NSURL URLWithString:urlString];
        _text = text;
        _originalTag = originalTagString;
    }
    
    return self;
}

@end

/**
 A category on NSMutableAttributedString to add HTML features for UIKit that normally only available in AppKit
 The OSX documentation is here: https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ApplicationKit/Classes/NSAttributedString_AppKitAdditions/
 */
@implementation NSMutableAttributedString (HTML)

/**
 *  Initializes and returns a new NSMutableAttributedString object from HTML contained in the given data object.
 *
 *  @param data          The data in HTML format from which to create the attributed string.
 *  @param docAttributes An in-out dictionary containing document-level attributes described in Document Attributes. May be NULL, in which case no document attributes are returned.
 *
 *  @return Returns an initialized object, or nil if the data can’t be decoded.
 */
- (instancetype _Nullable)initWithHTML:(NSData * _Nonnull)data documentAttributes:(NSDictionary<NSString *, id> * _Nullable * _Nullable)docAttributes
{
    self = [self initWithHTML:data options:nil documentAttributes:docAttributes];
    {
        
    }
    return self;
}

/**
 *  Initializes and returns a new NSAttributedString object from the HTML contained in the given object and base URL.
 *
 *  @param data          The data in HTML format from which to create the attributed string.
 *  @param aURL          An NSURL that represents the base URL for all links within the HTML.
 *  @param docAttributes An in-out dictionary containing document-level attributes described in Document Attributes. May be NULL, in which case no document attributes are returned.
 *
 *  @return Returns an initialized object, or nil if the data can’t be decoded.
 */
- (instancetype _Nullable)initWithHTML:(NSData * _Nonnull)data baseURL:(NSURL * _Nullable)aURL documentAttributes:(NSDictionary<NSString *, id> * _Nullable * _Nullable)docAttributes
{
    NSData * modifiedData = [self addBaseURL:aURL.absoluteString ToHtmlLinksInHTMLData:data];

    self = [self initWithHTML:modifiedData options:nil documentAttributes:docAttributes];
    if(self){
        
    }
    return self;
}

/**
 *  Initializes and returns a new attributed string object from HTML contained in the given data object.
 *
 *  @param data    The data in HTML format from which to create the attributed string.
 *  @param options Specifies how the document should be loaded. Contains values described in Option keys for importing documents.
 *  @param dict    An in-out dictionary containing document-level attributes described in Document Attributes. May be NULL, in which case no document attributes are returned.
 *
 *  @return Returns an initialized object, or nil if the data can’t be decoded.
 */
- (instancetype _Nullable)initWithHTML:(NSData * _Nonnull)data options:(NSDictionary * _Nullable)options documentAttributes:(NSDictionary<NSString *, id> * _Nullable * _Nullable)dict
{
    NSMutableDictionary * mutableOptions = [NSMutableDictionary dictionaryWithDictionary:options];
    [mutableOptions addEntriesFromDictionary:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                               NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}];

    self = [super initWithData:data options:mutableOptions documentAttributes:dict error:nil];
    if(self){
        
    }
    return self;
}

/**
 *  Add a base URL string all links in a string of HTML text. If there already is a base url in the string it is unmodified
 *
 *  @param baseURL  A NSString representing a base url in the form https://www.example.com
 *  @param htmlData The data in HTML format from which to create the attributed string.
 *
 *  @return NSData object representing NSString with all links modified to have the base url if there is not a base url already.
 */
- (NSData*)addBaseURL:(NSString*)baseURL ToHtmlLinksInHTMLData:(NSData*)htmlData
{
    NSMutableString * mutableString = [[NSMutableString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    NSArray * links = [self detectHTMLLinksInString:mutableString];
    
    NSUInteger locationOffset = 0;
    for(HtmlLink * link in links){
        NSString * linkString = [NSString stringWithFormat:@"<a href=\"%@%@\">%@</a>", baseURL, link.url, link.text];
        [mutableString replaceCharactersInRange:NSMakeRange(link.range.location + locationOffset, link.range.length) withString:linkString];
        locationOffset += (linkString.length - link.originalTag.length);
    }
    
    NSData * stringData = [[NSString stringWithString:mutableString] dataUsingEncoding:NSUTF8StringEncoding];
    
    return stringData;
}

/**
 *  Detect htmls links in the form '<a href="http://www.example.com">example</a>
 *
 *  @param string NSString of html
 *
 *  @return NSArray of HTMLLink objects
 */
- (NSArray*)detectHTMLLinksInString:(NSString*)string
{
    NSError * error;
    NSArray * matches = [self linkTagsInString:string];
    NSMutableArray * mutableResults = [NSMutableArray array];
    if(!error){
        for(NSTextCheckingResult* match in matches){
            NSString * matchedString = [string substringWithRange:match.range];
            
            // If there's an http in the link already skip it
            if([self stringHasBaseURL:matchedString]){
                continue;
            }
            
            // Get the url string
            NSString * urlString = [self getURLFromLinkTag:matchedString];
            NSString * linkText = [self getTextFromLinkTag:matchedString];
            HtmlLink * htmlLink = [[HtmlLink alloc] initWithRange:match.range urlString:urlString text:linkText originalTag:matchedString];
            [mutableResults addObject:htmlLink];
        }
    }
    
    return [NSArray arrayWithArray:mutableResults];
}

/**
 *  Checks if a string url has a base url in it. This depends on if the string starts with http:// or https://
 *
 *  @param string NSString of html
 *
 *  @return Boolean whether or not the string has a base url.
 */
- (BOOL)stringHasBaseURL:(NSString*)string
{
    if([string containsString:@"http://"] || [string containsString:@"https://"]){
        return YES;
    }
    
    return NO;

}

/**
 *  Detect all link tags in a string of html
 *
 *  @param string NSString of html
 *
 *  @return An array of NSTextCheckingResult objects representing all found link tags
 */
- (NSArray*)linkTagsInString:(NSString*)string
{
    NSString * linkTagPattern = @"<a\\b[^>]*>(.*?)<\\/a>";
    NSError * error;
    NSRegularExpression * regularExpression = [[NSRegularExpression alloc] initWithPattern:linkTagPattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray * matches = [regularExpression matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    return matches;
}

/**
 *  Extract URL string from a link tag
 *
 *  @param tag NSString of an html 'a' tag
 *
 *  @return URL string from the tag, nil if there's nothing found
 */
- (NSString*)getURLFromLinkTag:(NSString*)tag
{
    NSString * hrefPropertyPattern = @"href=\"[^\\\"]*\"";

    NSError * error;
    NSRegularExpression * hrefRegularExpression = [[NSRegularExpression alloc] initWithPattern:hrefPropertyPattern options:0 error:&error];
    NSArray * hrefMatches = [hrefRegularExpression matchesInString:tag options:0 range:NSMakeRange(0, tag.length)];
    
    if(!error){
        NSString * urlString;
        //Let's assume there's only one href per tag (is it even valid to have more than one?)
        if(hrefMatches.count > 0){
            NSTextCheckingResult * hrefMatch = hrefMatches[0];
            NSString * hrefString = [tag substringWithRange:hrefMatch.range];
            //Some magic numbers to get rid of the final matched quote and the initial 'href="' portion of the link
            urlString = [hrefString substringWithRange:NSMakeRange(6, hrefString.length - 7)];
            return urlString;
        } else {
            return nil;
        }
    }
    
    return nil;

}

/**
 *  Pulls the display text of an html link tag
 *
 *  @param tag NSString of an html 'a' tag
 *
 *  @return display text from the tag, nil if there's nothing found
 */
- (NSString*)getTextFromLinkTag:(NSString*)tag
{
    NSString * linkTextPattern = @">(.*?)<";
    NSError * error;
    NSRegularExpression * linkTextRegularExpression = [[NSRegularExpression alloc] initWithPattern:linkTextPattern options:0 error:&error];
    NSArray * linkTextMatches = [linkTextRegularExpression matchesInString:tag options:0 range:NSMakeRange(0, tag.length)];
    
    if(!error){
        NSString * linkText;
        if(linkTextMatches.count > 0){
            NSTextCheckingResult * linkTextMatch = linkTextMatches[0];
            linkText = [tag substringWithRange:NSMakeRange(linkTextMatch.range.location+1, linkTextMatch.range.length-2)];
            return linkText;
        } else {
            return nil;
        }
    } else {
        return nil;
    }
    
    return nil;

}

@end
