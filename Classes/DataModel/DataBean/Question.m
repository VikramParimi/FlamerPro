//
//  Question.m
//  Tinder
//
//  Created by Elluminati - macbook on 23/04/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "Question.h"

@implementation Question

@synthesize id_Que,option_a,option_b,option_c,option_d,pref_a,pref_b,pref_c,pref_d,quetion,your_ans;

-(id)initWithDict:(NSDictionary *)dictData
{
    self=[super init];
    if (self) {
        if (dictData) {
            id_Que=[dictData objectForKey:@"id"];
            option_a=[dictData objectForKey:@"option_a"];
            option_b=[dictData objectForKey:@"option_b"];
            option_c=[dictData objectForKey:@"option_c"];
            option_d=[dictData objectForKey:@"option_d"];
            pref_a=[dictData objectForKey:@"pref_a"];
            pref_b=[dictData objectForKey:@"pref_b"];
            pref_c=[dictData objectForKey:@"pref_c"];
            pref_d=[dictData objectForKey:@"pref_d"];
            quetion=[dictData objectForKey:@"quetion"];
            your_ans=[dictData objectForKey:@"your_ans"];
        }
    }
    return self;
}

@end
