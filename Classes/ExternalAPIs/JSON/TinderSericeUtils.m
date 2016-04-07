//
//  TinderSericeUtils.m
//  Tinder
//
//  Created by Vinay Raja on 07/12/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import "TinderSericeUtils.h"

@implementation TinderSericeUtils

+(NSString*)paramDictionaryToString:(NSDictionary*)params
{
    NSMutableString *request = [[NSMutableString alloc] init];
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request appendFormat:@"&%@=%@", key, obj];
    }];
    
    NSString *finalRequest = request;
    if ([request hasPrefix:@"&"]) {
        finalRequest = [request substringFromIndex:1];
    }
    
    return finalRequest;
}

@end
