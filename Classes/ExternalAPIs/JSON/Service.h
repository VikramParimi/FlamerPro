//
//  Service.h
//  Tinder
//
//  Created by Rahul Sharma on 04/12/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TinderAppDelegate.h"
@interface Service : NSObject

+(NSMutableURLRequest *)parseLogin :(NSDictionary *)params;

+(NSMutableURLRequest *)parseGetUserProfile :(NSDictionary *)params;
+(NSMutableURLRequest*)parseGetUpdatePrefrences :(NSDictionary *)params;
+(NSMutableURLRequest *)parseGetFindMatches :(NSDictionary *)params;
+(NSMutableURLRequest *)parseLogOut :(NSDictionary *)params;
+(NSMutableURLRequest *)parseEditProfile :(NSDictionary *)params;
+(NSMutableURLRequest *)parseInviteAction :(NSDictionary *)params;
+(NSMutableURLRequest *)parseMethod:(NSString*)method withParams:(NSDictionary *)params;
+(NSMutableURLRequest *)parseDeleteAccount :(NSDictionary *)params;

@end
