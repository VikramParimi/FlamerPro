//
//  JSONParser.m
//  TopBuy
//
//  Created by Rahul Sharma on 10/04/13.
//  Copyright (c) 2013 Rahul Sharma. All rights reserved.
//


#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) 


#import "JSONParser.h"

//#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
@implementation JSONParser


- (NSDictionary *)dictionaryWithContentsOfJSONURLString:(NSData*)data{
  
    NSDictionary *result;
    
    
    NSString *strResponse = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding: NSASCIIStringEncoding];
    result=
    [NSJSONSerialization JSONObjectWithData: [strResponse dataUsingEncoding:NSUTF8StringEncoding]
                                    options: NSJSONReadingMutableContainers
                                      error: nil];
    
    return result;
 
}


//- (NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSData*)data
//{
//    
//    NSDictionary *result;
//    
//    NSError* error = nil;
//    
//    result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//    
//    return result;
//}

@end
