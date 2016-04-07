//
//  UserSettings.m
//  Tinder
//
//  Created by Elluminati - macbook on 27/05/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "UserSettings.h"

@implementation UserSettings

@synthesize sex,prRad,prSex,prLAge,prUAge,prDiscovery;

#pragma mark -
#pragma mark - Init

-(id)init{
    
    if((self = [super init]))
    {
        
    }
    return self;
}

+(UserSettings *)currentSetting
{
    static UserSettings *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[UserSettings alloc] init];
    });
    return obj;
}

@end
