//
//  Activity.m
//  Tinder
//
//  Created by Sanskar on 05/01/15.
//  Copyright (c) 2015 AppDupe. All rights reserved.
//

#import "Activity.h"

@implementation Activity

@synthesize activity_type;
@synthesize activity_image;
@synthesize activity_Created_date;
@synthesize activity_Creator_id;
@synthesize activity_Creator_firstName;
@synthesize activity_Creator_lastName;
@synthesize activity_Creator_profilePic;
@synthesize activity_Creator_entity_id;
@synthesize activity_momentDict;

-(id)initWithDict:(NSDictionary *)dictData
{
    self=[super init];
    if (self) {
        if (dictData)
        {
          
            activity_type             =     [dictData objectForKey:@"activity_type"];
            activity_image            =     [dictData objectForKey:@"moment_img_url"];
            activity_Created_date     =     [dictData objectForKey:@"created_date"];
            activity_Creator_id       =     [dictData objectForKey:@"fb_id"];
            activity_Creator_firstName  =   [dictData objectForKey:@"first_name"];
            activity_Creator_lastName   =   [dictData objectForKey:@"last_name"];
            activity_Creator_profilePic =   [dictData objectForKey:@"profile_pic_url"];
            activity_Creator_entity_id  =   [dictData objectForKey:@"moment_creator_entity_id"];
            activity_momentDict         =   [dictData objectForKey:@"moment"];
          
        }
    }
    return self;
}


@end
