//
// NSString+URLEncoding.h
// YOAuth
//
// Created by Zach Graves on 3/4/09.
// Copyright (c) 2009 Yahoo! Inc. All rights reserved.
//
// The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license.
//

#import "NSString+URLEncoding.h"

@implementation NSString (URLEncodingAdditions)

- (NSString *)URLEncodedString
{
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)self,
                                                                           NULL, CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8);
    [result autorelease];
	return result;
}

- (NSString*)URLDecodedString
{
	NSString *result = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
																						   (CFStringRef)self,
																						   CFSTR(""),
																						   kCFStringEncodingUTF8);
    [result autorelease];
	return result;
}

@end


@implementation NSString (HTTPExtensions)

- (BOOL)isHTTPContentType:(NSString *)prefixStr
{
    BOOL    result;
    NSRange foundRange;
    
    result = NO;
    
    foundRange = [self rangeOfString:prefixStr options:NSAnchoredSearch | NSCaseInsensitiveSearch];
    if (foundRange.location != NSNotFound) {
        assert(foundRange.location == 0);            // because it's anchored
        if (foundRange.length == self.length) {
            result = YES;
        } else {
            unichar nextChar;
            
            nextChar = [self characterAtIndex:foundRange.length];
            result = nextChar <= 32 || nextChar >= 127 || (strchr("()<>@,;:\\<>/[]?={}", nextChar) != NULL);
        }
		/*
		 From RFC 2616:
		 
		 token          = 1*<any CHAR except CTLs or separators>
		 separators     = "(" | ")" | "<" | ">" | "@"
		 | "," | ";" | ":" | "\" | <">
		 | "/" | "[" | "]" | "?" | "="
		 | "{" | "}" | SP | HT
		 
		 media-type     = type "/" subtype *( ";" parameter )
		 type           = token
		 subtype        = token
		 */
    }
    return result;
}

@end