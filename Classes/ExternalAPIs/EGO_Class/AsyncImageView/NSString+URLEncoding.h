//
// NSString+URLEncoding.h
// YOAuth
//
// Created by Zach Graves on 3/4/09.
// Copyright (c) 2009 Yahoo! Inc. All rights reserved.
//
// The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license.
//


#import <Foundation/Foundation.h>

/**
 * Adds methods to URL encode/decode strings.
 */
@interface NSString (URLEncodingAdditions)

/**
 * Encodes the string.
 * @return A url encoded string.
 */
- (NSString *)URLEncodedString;

/**
 * Decodes an encoded string.
 * @return A decoded string.
 */
- (NSString *)URLDecodedString;

@end

// Comparing HTTP content types is tricky because a) they are case insensitive and 
// b) there can be parameters at the end of the string.

@interface NSString (HTTPExtensions)

- (BOOL)isHTTPContentType:(NSString *)prefixStr;

@end
