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


@implementation HTMLTag

/**
 *  Intialize HTMLTag object
 *
 *  @param type The type of the tag, "em" in <em>
 *  @param openingRange    Range of opening tag in text
 *  @param closingRange    Range of closing tag in text
 *  @param attributes      Attributes of tag
 *  @param internalText    Text between the opening and closing tag
 *
 *  @return HTMLTag object representing
 */

- (instancetype)initWithType:(NSString*)type openingRange:(NSRange)openingRange
                closingRange:(NSRange)closingRange
                  attributes:(NSDictionary*)attributes
                internalText:(NSString*)internalText
{
    self = [super init];
    if(self){
        _type = type;
        _openRange = openingRange;
        _closingRange = closingRange;
        _attributes = attributes;
        _internalText = internalText;
    }
    
    return self;
}

- (NSString *)description {
    NSString *descriptionString = [NSString stringWithFormat:@"Type: %@ \n Opening Range: %lu \n Closing Range: %lu", self.type, self.openRange.location, self.closingRange.location];
    return descriptionString;
    
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

- (NSAttributedString*)processHTML
{
    NSArray * tags = [self parseHTMLString];
    NSArray * attributes = [self attributesForHTMLTags:tags];
    
    
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:self.string];

    for(NSDictionary * attribute in attributes) {
        NSDictionary * unwrappedAttribute = (NSDictionary*)attribute[@"attribute"];
        
        NSString * key = unwrappedAttribute.allKeys.firstObject;
        NSString * value = unwrappedAttribute[key];
        
        NSRange range = [attribute[@"range"] rangeValue];
        
        [string addAttribute:key value:value range:range];
    }
    
    return string;
}

// NOTE: THIS IS NOT FINISHED, PROBABLY NOT USED
/**
 *  Takes and arry of HTMLTag elements and applies formatting to the string
 *  All tags are removed along in the process
 *
 *  @param tags NSArray of HTMLTags
 *
 *  @return NSArray of attributes for a NSAttributeString
 */

- (NSArray*)attributesForHTMLTags:(NSArray *)tags
{
    // OK, so this is a bit tough to do
    // the main reason is that the range for an attribute
    // has to be for just the text itself, it can include any nested
    // tags. For instance <strong> haha <em>yep</em> lslsl</strong>
    // the attribute range has to take into consideration that the <em> tags
    // will no longer be there when the attribute is applied
    //
    // To do this, we'll be making a stack, comparing the next tag
    // to the first's end index. If it's before, we add it to the stack.
    // Once this is built, we keep a counter of offset, and start removing tags
    // in teh process building up the attributes, offsetting
    // the ranges appropriately. Then for the next tag we can just
    // start with the offset we already have.
    
    NSUInteger globalOffset = 0;
    NSUInteger internalOffset = 0;
    
    NSMutableArray * mutableTags = [NSMutableArray arrayWithArray:tags];
    
    NSMutableArray * tagWorkingStack = [NSMutableArray array];
    
    NSMutableArray * finalAttributes = [NSMutableArray array];
    
    HTMLTag * compareTag;
    
    for(HTMLTag * tag in tags) {
        
        [tagWorkingStack addObject:tag];

        // If there's no compare tag, make this one it.
        if(!compareTag){
            compareTag = tag;
        }
        
        // If we got to a tag outside of the stack, we run through the current working stack and apply it all
        if(tag.openRange.location > compareTag.closingRange.location + compareTag.closingRange.length || tag == tags.lastObject){
            NSMutableArray * attributes = [NSMutableArray arrayWithArray:[self traveseTagStack:tagWorkingStack withOffset:globalOffset]];
            globalOffset += compareTag.closingRange.location + compareTag.closingRange.length;
            
            NSUInteger index = 0;
            NSUInteger offset = 0;
            for(HTMLTag * tagToClean in tagWorkingStack){
                NSString * cleanedString = self.string;
                
                NSUInteger closingLocation = tagToClean.closingRange.location - offset;
                NSUInteger openingLocation = tagToClean.openRange.location;
                
                NSRange closingRange = NSMakeRange(closingLocation, tagToClean.closingRange.length);
                NSRange openingRange = NSMakeRange(openingLocation, tagToClean.openRange.length);
                
                cleanedString = [cleanedString stringByReplacingCharactersInRange:closingRange withString:@""];
                cleanedString = [cleanedString stringByReplacingCharactersInRange:openingRange withString:@""];
                [self setAttributedString:[[NSAttributedString alloc] initWithString:cleanedString]];
                
                NSMutableDictionary * attribute = [NSMutableDictionary dictionaryWithDictionary:attributes[index]];
                NSValue * rangeValue = attribute[@"range"];
                NSRange range = [rangeValue rangeValue];
                
                range.location = tagToClean.openRange.location - offset;
                range.length = tagToClean.closingRange.location - (tagToClean.openRange.location + tagToClean.openRange.length);
                
                rangeValue = [NSValue valueWithRange:range];
                attribute[@"range"] = rangeValue;
                
                [attributes replaceObjectAtIndex:index withObject:attribute];
                
                offset += tagToClean.openRange.length + tagToClean.closingRange.length;
                
                index++;
            }
            
            [finalAttributes addObjectsFromArray:attributes];
            compareTag = nil;
        }
        
        
    }
    
    return finalAttributes;
}

- (NSArray*)traveseTagStack:(NSArray*)stack withOffset:(NSUInteger)offset
{
    NSMutableArray * attributes = [NSMutableArray array];
    NSMutableArray * mutableStack = [NSMutableArray arrayWithArray:stack];
    
    NSUInteger openingOffset = offset;
    NSUInteger closingOffset = offset;
    // Fist we go through the start tags,
    // We also check if the start of the next tag is after the current end tag.
    // If so, add the current tag to the offset, process the tag, keep going
    // keep going
    
    NSUInteger index = 0;
    for(HTMLTag * tag in stack){
        HTMLTag * nextTag;
        if(tag != stack.lastObject){
            nextTag = stack[index + 1];
        } else {
            //break;
        }
        
        // Add the opening tag to the offset
        offset += tag.openRange.length;
        
        if(nextTag.openRange.location > tag.closingRange.location + tag.closingRange.length){
            [self processTag:tag withOpeningOffset:openingOffset closingOffset:closingOffset];
            openingOffset += tag.closingRange.length;
            [mutableStack removeObject:tag];
        }
        
        NSDictionary * attribute = [self processTag:tag withOpeningOffset:openingOffset closingOffset:closingOffset];
        [attributes addObject:attribute];
    }
    
    // Now we process everything left
    /*while(mutableStack.count > 0){
        HTMLTag * tag = mutableStack.lastObject;
        [mutableStack removeObject:tag];
        

        closingOffset += tag.closingRange.length - 1;
        NSDictionary * attribute = [self processTag:tag withOpeningOffset:openingOffset closingOffset:closingOffset];
        openingOffset += tag.openRange.length;
        
        [attributes addObject:attribute];
    }*/
    
    return attributes;
}

- (NSDictionary *)processTag:(HTMLTag*)tag withOpeningOffset:(NSUInteger)openingOffset closingOffset:(NSUInteger)closingOffset
{
    NSMutableDictionary * attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForTag:tag]];
    NSValue * rangeValue = attributes[@"range"];
    NSRange range = rangeValue.rangeValue;
    range = NSMakeRange(range.location + openingOffset, range.length - closingOffset);
    rangeValue = [NSValue valueWithRange:range];
    attributes[@"range"] = rangeValue;
    
    return attributes;
}

- (NSDictionary*)attributesForTag:(HTMLTag*)tag
{
    NSString * type = tag.type.lowercaseString;
    
    NSMutableDictionary * attribute = [NSMutableDictionary dictionary];
    
    if([type isEqualToString:@"em"]){
        attribute[@"attribute"] = @{NSFontAttributeName: [UIFont italicSystemFontOfSize:12]};
    } else if([type isEqualToString:@"strong"]){
        attribute[@"attribute"] = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:12]};
    }
    
    attribute[@"range"] = [NSValue valueWithRange:NSMakeRange(tag.openRange.length + tag.openRange.location, tag.closingRange.location - (tag.openRange.length + tag.openRange.location))];
    
    return attribute;
}

/**
 *  Parses html string into tag pairs, and figuring out ranges.
 *  If a tag is not properly nested or closed it just discards it,
 *  For now, assumes thats it's invalid and ignores it.
 *
 *
 *  @return an array of HTMLTag elements
 */

- (NSArray*)parseHTMLString
{
    // Create a stack for tags
    NSMutableArray * stack = [NSMutableArray array];
    NSMutableArray * nodeList = [NSMutableArray array];
    
    NSUInteger location = 0;
    while(location < self.length){
        NSRange tagRange = [self getRangeOfNextTagInHTMLString:self.string fromLocation:location];
        if(tagRange.location >= self.string.length){
            break;
        }
        
        NSString * tagText = [self.string substringWithRange:tagRange];
        NSString * tagType = [self tagNameFromTagString:tagText];
        // We need to check if this is a closing tag
        // according to the html spec it starts like this </tag
        char nextCharacter = [tagText characterAtIndex:1];
        if(nextCharacter == '/'){
            tagType = [tagType substringFromIndex:1];
            // This is a closing tag, so let's look at the stack
            HTMLTag * mostRecentTag = [stack lastObject];
            if(![mostRecentTag.type isEqualToString:tagType]){
                // If it's not properly nested we assume it goes on forever
                mostRecentTag.closingRange = NSMakeRange(self.length, 0);
            } else {
                mostRecentTag.closingRange = tagRange;
                NSUInteger textStartIndex = mostRecentTag.openRange.location + mostRecentTag.openRange.length;
                NSUInteger lengthOfText = mostRecentTag.closingRange.location - textStartIndex;
                if(textStartIndex + lengthOfText > self.string.length){
                    lengthOfText = self.string.length - textStartIndex;
                }
                
                mostRecentTag.internalText = [self.string substringWithRange:NSMakeRange(textStartIndex, lengthOfText)];
            }
            
            [nodeList addObject:mostRecentTag];
            [stack removeObject:mostRecentTag];
        } else {
            NSDictionary * attributes = [self quotedAttributesFromTagString:tagText];
            // for html we also need to get unquoted attributes here, but let's not get ahead of ourselves.
            HTMLTag * tag = [[HTMLTag alloc] initWithType:tagType openingRange:tagRange closingRange:NSMakeRange(0, 0) attributes:attributes internalText:nil];
            
            // if the string is self closed, add it to the node list, not the stack
            if([tagText characterAtIndex:tagText.length - 1] == '/'){
                [nodeList addObject:tag];
            } else {
                [stack addObject:tag];
            }
        }
        
        
        location = tagRange.location + tagRange.length;
    }
    
    return [NSArray arrayWithArray:nodeList];
}

- (NSRange)getRangeOfNextTagInHTMLString:(NSString*)html fromLocation:(NSUInteger)index
{
    // First, start looking for the start of tags '<'
    NSScanner * scanner = [NSScanner scannerWithString:html];
    [scanner setCharactersToBeSkipped:nil];
    scanner.scanLocation = index;
    
    BOOL scanStatus = [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"<"]
                                              intoString: nil];
    NSUInteger startIndex = scanner.scanLocation;
    NSUInteger endIndex = 0;
    // If the scanner finds a '<' keep going
    if(scanner.scanLocation < html.length) {
        // We need to find the closing tag '>'
        
        // We have to make sure that it's not in a " though.
        // To do that, we keep track of the " inbetween, if it's odd, it's in one, so we ignore it
        NSUInteger quoteCount = 0;
        
        
        char currentCharacter = [html characterAtIndex:scanner.scanLocation];
        while(scanner.scanLocation < html.length && currentCharacter != '>'){
            scanStatus = [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\">"] intoString:NULL];
            currentCharacter = [html characterAtIndex:scanner.scanLocation];
            if(currentCharacter == '\"'){
                quoteCount++;
            }
            
            if(currentCharacter == '>' && quoteCount % 2 == 0){
                break;
            }
            
            scanner.scanLocation++;
        }
        
        endIndex = scanner.scanLocation + 1;
    }
    
    return NSMakeRange(startIndex, endIndex - startIndex);
}

- (NSString*)tagNameFromTagString:(NSString*)tagString
{
    NSError * error;
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:@"<[\\/]{0,1}([\\w]+)" options:0 error:&error];
    NSArray * matches = [regex matchesInString:tagString options:0 range:NSMakeRange(0, tagString.length)];
    
    if(matches.count > 0){
        NSTextCheckingResult * result = matches[0];
        
        NSString * name = [tagString substringWithRange:result.range];
        return [name stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"< "]];
    }
    
    return nil;
}

- (NSDictionary*)quotedAttributesFromTagString:(NSString*)tagString
{
    // NOTE: this doesn't care if a quote is escaped. Fix this later...
    // Now we use a regex to extract quoted attributes
    NSError * error;
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:@"[\\w]*[\\s]*=[\\s]*\"[^\"]*\"" options:0 error:&error];
    NSArray * quotedAttributeMatches = [regex matchesInString:tagString options:0 range:NSMakeRange(0, tagString.length)];
    
    NSMutableDictionary * attributes = [NSMutableDictionary dictionary];
    NSRegularExpression * attributeNameRegex = [NSRegularExpression regularExpressionWithPattern:@"\\w+[\\s]*=" options:0 error:&error];
    NSRegularExpression * attributeValueRegex = [NSRegularExpression regularExpressionWithPattern:@"=[\\s]*\"[^\"]*" options:0 error:&error];
    
    for(NSTextCheckingResult * attributeResult in quotedAttributeMatches) {
        NSString * attribute = [tagString substringWithRange:attributeResult.range];
        NSArray * attributeNameMatches = [attributeNameRegex matchesInString:attribute options:0 range:NSMakeRange(0, attribute.length)];
        NSArray * attributeValueMatches = [attributeValueRegex matchesInString:attribute options:0 range:NSMakeRange(0, attribute.length)];
        
        if(attributeNameMatches.count == 0){
            NSLog(@"Damn");
        }
        
        NSTextCheckingResult * nameResult = attributeNameMatches[0];
        NSTextCheckingResult * valueResult = attributeValueMatches[0];
        
        attributes[[tagString substringWithRange:nameResult.range]] = attributes[[tagString substringWithRange:valueResult.range]];
    }
    
    return [NSDictionary dictionaryWithDictionary:attributes];
}

- (BOOL)isCharacterAtIndex:(NSUInteger)index escapedInString:(NSString*)string
{
    char testChar = [string characterAtIndex:index];
    
    NSInteger numberOfBackspaces = 0;
    
    while(index > 0){
        index--;
        testChar = [string characterAtIndex:index];
        
        if(strncmp(&testChar, "\\", 1)){
            numberOfBackspaces++;
        } else {
            break;
        }
    }
    
    if(numberOfBackspaces % 2 == 0){
        return false;
    } else {
        return true;
    }
}

@end
