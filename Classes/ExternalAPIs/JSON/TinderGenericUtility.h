//
//  TinderGenericUtility.h
//  Tinder
//
//  Created by Vinay Raja on 07/12/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import <Foundation/Foundation.h>



#define flStrForInt(x) [TinderGenericUtility nonNullStringForInteger:x]
#define flStrForBool(x) [TinderGenericUtility nonNullStringForBool:x]
#define flStrForDate(x) [TinderGenericUtility nonNullStringForDate:x]
#define flStrForStr(x) [TinderGenericUtility nonNullStringForString:x]
#define flStrForLong(x) [TinderGenericUtility nonNullStringForLong:x]
#define flStrForDouble(x) [TinderGenericUtility nonNullStringForDouble:x]
#define flIntForStr(x) [TinderGenericUtility intFromString:x]
#define flBoolForStr(x) [TinderGenericUtility boolFromString:x]
#define flDateForStr(x) [TinderGenericUtility dateFromString:x]
#define flLongForStr(x) [TinderGenericUtility longFromString:x]
#define flDoubleForStr(x) [TinderGenericUtility doubleFromString:x]
#define flIntForObj(x) [TinderGenericUtility intFromObject:x]
#define flBoolForObj(x) [TinderGenericUtility boolFromObject:x]
#define flDateForObj(x) [TinderGenericUtility dateFromObject:x]
#define flLongForObj(x) [TinderGenericUtility longFromObject:x]
#define flDoubleForObj(x) [TinderGenericUtility doubleFromObject:x]
#define flStrForObj(x) [TinderGenericUtility stringFromObject:x]
#define flStrEqualsIgnoreCase(x,y) [TinderGenericUtility isString1:x equalsIgnoreCaseToString2:y]
#define flHTMLEscapeStr(x) [TinderGenericUtility stringByHTMLEscaping:x]

#define flNonEmptyString(str,default) str&&str.length>0?str:default

//Singleton to  provide the OS version check.
#define IS_OS_MAJOR_VERSION_LESS_THAN(x) ([TinderGenericUtility DeviceSystemMajorVersion] < x)

#define startTiming(x) double x = [[NSDate date] timeIntervalSince1970];
#define endTiming(x) double x = [[NSDate date] timeIntervalSince1970];

@interface TinderGenericUtility : NSObject


+ (NSUInteger)DeviceSystemMajorVersion;


//Conversion functions
+ (NSString *) nonNullStringForInteger:(NSInteger) value;
+ (NSString *) nonNullStringForBool:(NSInteger) value;
+ (NSString *) nonNullStringForDate:(NSDate *) date;
+ (NSString *) nonNullStringForString:(NSString *) string;
+ (NSString *) nonNullStringForLong:(long) string;
+ (NSString *) nonNullStringForDouble:(double) string;

+ (NSInteger) intFromString:(NSString *) string;
+ (NSDate *) dateFromString:(NSString *) string;
+ (BOOL) boolFromString:(NSString *) string;
+ (long) longFromString:(NSString *) string;
+ (double) doubleFromString:(NSString *) string;

+ (NSInteger) intFromObject:(id) obj;
+ (NSDate *) dateFromObject:(id) obj;
+ (BOOL) boolFromObject:(id) obj;
+ (long) longFromObject:(id) obj;
+ (double) doubleFromObject:(id) obj;
+ (NSString *) stringFromObject:(id) obj;

@end
