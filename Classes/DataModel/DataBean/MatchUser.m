//
//  MatchUser.m
//  Tinder
//
//  Created by Elluminati - macbook on 28/04/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "MatchUser.h"

@implementation MatchUser

@synthesize Boost;
@synthesize age;
@synthesize fbId;
@synthesize firstName;
@synthesize lat;
@synthesize lon;
@synthesize pPic;
@synthesize percentage;
@synthesize persDesc;
@synthesize sex;

-(id)initWithDict:(NSDictionary *)dictData
{
    self=[super init];
    if (self) {
        if (dictData) {
            Boost=[dictData objectForKey:@"Boost"];
            age=[dictData objectForKey:@"age"];
            fbId=[dictData objectForKey:@"fbId"];
            firstName=[dictData objectForKey:@"firstName"];
            lat=[dictData objectForKey:@"lat"];
            lon=[dictData objectForKey:@"long"];
            pPic=[dictData objectForKey:@"pPic"];
            percentage=[dictData objectForKey:@"percentage"];
            persDesc=[dictData objectForKey:@"persDesc"];
            sex=[dictData objectForKey:@"sex"];
        }
    }
    return self;
}

@end
