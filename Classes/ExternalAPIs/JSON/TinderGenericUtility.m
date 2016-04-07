//
//  TinderGenericUtility.m
//  Tinder
//
//  Created by Vinay Raja on 07/12/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import "TinderGenericUtility.h"


NSInteger const INVALID_NUM = -111111;

@implementation TinderGenericUtility


+ (NSUInteger) DeviceSystemMajorVersion
{
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion]
                                       componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion;
}

+ (BOOL)amIRunningOnIPadDevice
{
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
		// The device is an iPad running iPhone 3.2 or later.
		return YES;
    }
    else
#endif
    {
		// The device is an iPhone or iPod touch.
		return NO;
    }
}

+ (NSString *) convertIntToString:(NSInteger) intValue
{
    NSString* str = [NSString stringWithFormat:@"%d", intValue];
    return str;
    
}

+ (NSInteger) converStringToInt:(NSString *) stringValue
{
    NSInteger intValue = INVALID_NUM;
    
    if(stringValue != nil)
    {
        intValue = [stringValue integerValue];
    }
    return intValue;
}




+ (BOOL) getBoolValueForString:(NSString *) string
{
    BOOL value = false;
    
    if (string == nil) {
        return value;
    }
    
    if(([string compare:@"YES" options:NSCaseInsensitiveSearch] == NSOrderedSame) ||
       ([string compare:@"true" options:NSCaseInsensitiveSearch] == NSOrderedSame) ||
       ([string compare:@"1"] == NSOrderedSame) )
    {
        value = true;
    }
    return value;
}

+ (NSString *) getStringForBool:(BOOL) value
{
    NSString *boolString = nil;
    if(value)
    {
        boolString = @"true";
    }
    else
    {
        boolString = @"false";
    }
    return boolString;
}

+ (BOOL) doesString:(NSString *) string1 contains:(NSString *) string2
{
    BOOL bRet = false;
    NSUInteger len1 = [string1 length];
    NSUInteger len2 = [string2 length];
    if(len1 > 0 && len2 > 0 && len1 >= len2)
    {
        NSRange range= [string1 rangeOfString:string2 options: NSLiteralSearch];
        if(range.location != NSNotFound && range.length > 0)
            bRet = true;
    }
    return bRet;
}

+ (NSString*)getPercentEscapeString:(NSString *)string
{
    CFStringRef newStr = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                 (__bridge CFStringRef)string,
                                                                 NULL,
                                                                 (CFStringRef) @"*'();:@&=+$,/?%#[]",
                                                                 kCFStringEncodingUTF8);
    if (newStr)
    {
        NSString *encodedString = [[NSString alloc] initWithFormat:@"%@", (__bridge NSString *)newStr];
        CFRelease(newStr);
        return encodedString;
    }
    return nil;
}

+ (NSString*)geURLEscapeString:(NSString *)string forCharacterSet:(NSString *) charSet
{
    CFStringRef newStr = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                 (__bridge CFStringRef)string,
                                                                 NULL,
                                                                 (CFStringRef) charSet,
                                                                 kCFStringEncodingUTF8);
    if (newStr)
    {
        NSString *encodedString = [[NSString alloc] initWithFormat:@"%@", (__bridge NSString *)newStr];
        CFRelease(newStr);
        return encodedString;
    }
    return nil;
}


+ (NSString *) getNonNulledDescription:(NSObject *) obj
{
    NSString *value = @"";
    if(obj != nil)
    {
        NSString *desc = [obj description];
        if(desc != nil)
        {
            value = desc;
        }
    }
    return value;
}


+ (NSString *) concatinateStringsOfArray:(NSArray *) strings seperatedBy:(NSString *) delim
{
    return [strings componentsJoinedByString:delim];
}



+ (NSString *) nonNullStringForInteger:(NSInteger) value
{
    return [@(value) stringValue];
}

+ (NSString *) nonNullStringForBool:(NSInteger) value
{
    return [@(value) stringValue];
}

+ (NSString *) nonNullStringForDate:(NSDate *) date
{
    NSString *dateString = @"";
    if(date != nil)
        dateString = [@([date timeIntervalSince1970]) stringValue];
    
    return dateString;
}

+ (NSString *) nonNullStringForString:(NSString *) string
{
    return (string == nil) ? @""  : string;
}

+ (NSString *) nonNullStringForLong:(long) value
{
    return [@(value) stringValue];
    
}

+ (NSString *) nonNullStringForDouble:(double) value
{
    return [@(value) stringValue];
}


+ (NSInteger) intFromString:(NSString *) string
{
    NSInteger value = 0;
    value = [string integerValue];
    return value;
}

+ (NSDate *) dateFromString:(NSString *) string
{
    NSDate *date = nil;
    if(string != nil && [string length] > 0)
    {
        double value = [string doubleValue];
        date = [[NSDate alloc] initWithTimeIntervalSince1970:value];
    }
    return date;
}

+ (BOOL) boolFromString:(NSString *) string
{
    BOOL value = NO;
    if([string length] > 0)
        value = [string boolValue];
    return value;
}


+ (long) longFromString:(NSString *) string
{
    long value = 0;
    if([string length] > 0)
        value = (long)[string longLongValue];
    return value;
    
}

+ (double) doubleFromString:(NSString *) string
{
    double value = 0;
    if([string length] > 0)
        value = [string doubleValue];
    return value;
    
}

+ (NSInteger) intFromObject:(id) obj
{
    NSInteger value = 0;
    if([obj isKindOfClass:[NSNull class]] || obj == nil)
    {
        value = 0;
    }
    else if ([obj isKindOfClass:[NSString class]] ||
             [obj isKindOfClass:[NSNumber class]])
    {
        value = [obj integerValue];
    }
    return value;
}

+ (NSDate *) dateFromObject:(id) obj
{
    NSDate *date = nil;
    if([obj isKindOfClass:[NSNull class]] || obj == nil )
    {
        date = nil;
    }
    else if ([obj isKindOfClass:[NSString class]] ||
             [obj isKindOfClass:[NSNumber class]])
    {
        if([obj isKindOfClass:[NSString class]] && [obj length] == 0)
        {
            date = nil;
        }
        else
        {
            double value = [obj doubleValue];
            date = [[NSDate alloc] initWithTimeIntervalSince1970:value];
        }
        
    }
    
    return date;
}

+(NSDate *)getDateFromMiliSeconds:(id)obj
{
    
    NSDate *date = nil;
    if([obj isKindOfClass:[NSNull class]] || obj == nil )
    {
        date = nil;
    }
    else if ([obj isKindOfClass:[NSString class]] ||
             [obj isKindOfClass:[NSNumber class]])
    {
        if([obj isKindOfClass:[NSString class]] && [obj length] == 0)
        {
            date = nil;
        }
        else
        {
            double value = [obj doubleValue]/1000;
            date = [[NSDate alloc] initWithTimeIntervalSince1970:value];
        }
        
    }
    
    return date;
}


+ (BOOL) boolFromObject:(id) obj
{
    BOOL value = NO;
    if([obj isKindOfClass:[NSNull class]] || obj == nil)
    {
        value = NO;
    }
    else if ([obj isKindOfClass:[NSString class]] ||
             [obj isKindOfClass:[NSNumber class]])
    {
        value = [obj boolValue];
    }
    
    return value;
}


+ (long) longFromObject:(id) obj
{
    long value = 0;
    if([obj isKindOfClass:[NSNull class]] || obj == nil)
    {
        value = 0;
    }
    else if ([obj isKindOfClass:[NSString class]] ||
             [obj isKindOfClass:[NSNumber class]])
    {
        value = (long)[obj longLongValue];
    }
    return value;
    
}

+ (double) doubleFromObject:(id) obj
{
    double value = 0;
    if([obj isKindOfClass:[NSNull class]] || obj == nil)
    {
        value = 0;
    }
    else if ([obj isKindOfClass:[NSString class]] ||
             [obj isKindOfClass:[NSNumber class]])
    {
        value = [obj doubleValue];
    }
    return value;
    
}

+ (NSString *) stringFromObject:(id) obj
{
    NSString *value = @"";
    if([obj isKindOfClass:[NSString class]])
    {
        if([obj length] > 0)
        {
            value = obj;
        }
    }
    else if([obj isKindOfClass:[NSNull class]])
    {
        value = @"";
    }
    else if([obj isKindOfClass:[NSNumber class]] && obj != nil)
    {
        NSNumber *numValue = (NSNumber *)obj;
        value = [numValue stringValue];
    }
    return value;
    
}


+ (id)getNSNullObjectIfNil:(id)object
{
    if(object == nil)
    {
        NSNull * nullObject = [[NSNull alloc]init];
        return nullObject;
    }
    return object;
}

+ (NSString *) getSqlWildCardEscapedString:(NSString *)string
{
    //order of this wild cards is important, always first in the wildcard sequence should be /
    NSArray *wildCards = @[@"/",@"%",@"_"];
    NSArray *wildCardSequences = @[@"//",@"/%",@"/_"];
    
    NSString *encodedString =string;
    int index=0;
    for(NSString *pattern in wildCards)
    {
        encodedString = [encodedString stringByReplacingOccurrencesOfString:pattern withString:[wildCardSequences objectAtIndex:index]];
        index++;
    }
    return encodedString;
}

+ (NSString *) getSqliteEscapeSequence
{
    return @"Escape '/'";
}

+(BOOL)doesStringContainsOnlyNumericChars:(NSString *)input
{
    BOOL isStringNumneric = FALSE;
    //This is the string that is going to be compared to the input string
    NSString *testString = [NSString string];
    
    NSScanner *scanner = [NSScanner scannerWithString:input];
    
    //This is the character set containing all digits. It is used to filter the input string
    NSCharacterSet *skips = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
    
    //This goes through the input string and puts all the
    //characters that are digits into the new string
    [scanner scanCharactersFromSet:skips intoString:&testString];
    
    if([input length] == [testString length]) {
        
        //The input contains only number
        isStringNumneric = TRUE;
        
    }
    return isStringNumneric;
}


+ (NSString *)appBundleGenericName
{
    return @"MDM";
}


+(NSArray *)sortArray:(NSArray *)array basedOnSequenceInArray:(NSArray *)customArray
{
    
    NSArray * sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber * index1 = @([customArray indexOfObject:a]);
        NSNumber * index2 = @([customArray indexOfObject:b]);
        return [index1 compare:index2];
    }];
    
    return sortedArray;
}

+ (NSString*)decodeToPercentEscapeString:(NSString *)string
{
    CFStringRef newStr = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                 (__bridge CFStringRef)string,CFSTR(""),
                                                                                 kCFStringEncodingUTF8);
    
    if (newStr)
    {
        NSString *decodedString = [[NSString alloc] initWithFormat:@"%@", (__bridge NSString *)newStr];
        CFRelease(newStr);
        return decodedString;
    }
    return @"";
}

+ (BOOL) isString1:(NSString *)string1 equalsIgnoreCaseToString2:(NSString *) string2
{
    if(string1 == nil || string2 == nil)
        return false;
    
    string1 = flStrForObj(string1);
    string2 = flStrForObj(string2);
    
    string1 = [string1 uppercaseString];
    string2 = [string2 uppercaseString];
    
    if([string1 isEqualToString:string2])
    {
        return YES;
    }
    
    return NO;
}

+(NSString *) transformSeedByteZero:(NSString *)seed
{
    if([seed length] == 0) {
        return nil;
    }
    
    NSData *seedData=[seed dataUsingEncoding:NSUTF8StringEncoding];
    if([seedData length] == 0) {
        return nil;
    }
    
    char *bytes = (char *)[seedData bytes];
    bytes[0] = 0;
    seedData = [NSData dataWithBytes:bytes length:[seedData length]];
    return [[NSString alloc] initWithData:seedData encoding:NSUTF8StringEncoding];
}

+ (BOOL)isDeviceLockedForFirstAuthenticationOnReboot
{
    if(![[UIApplication sharedApplication] isProtectedDataAvailable])
    {
        BOOL expandTilde = YES;
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, expandTilde);
        NSString *filePath;
        filePath = [[paths lastObject] stringByAppendingPathComponent:@"app_passcode_check"];
        
        NSMutableData *testData;
        testData = [NSMutableData dataWithLength:256];
        NSError *error = nil;
        
        //Check is the device locked for first auth on device reboot
        if (![testData writeToFile:filePath options:NSDataWritingFileProtectionCompleteUntilFirstUserAuthentication error:&error]) {
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            return YES;
        }
    }
    return NO;
}


// return a new autoreleased UUID string
+ (NSString *)generateUuidString
{
    // create a new UUID which you own
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    
    // create a new CFStringRef (toll-free bridged to NSString)
    // that you own
    NSString *uuidString = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid));
    
    // transfer ownership of the string
    // to the autorelease pool
    //[uuidString autorelease];
    
    
    // release the UUID
    CFRelease(uuid);
    
    return uuidString;
}

+ (NSString*) stringByHTMLEscaping:(NSString*)string
{
    if(string == nil) return @"";
    
    NSString *returnString = [string stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    returnString = [returnString stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    returnString = [returnString stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
    returnString = [returnString stringByReplacingOccurrencesOfString:@"'" withString:@"&#39;"];
    
    return returnString;
}

@end
