//
//  Moment.m
//  Tinder
//
//  Created by Sanskar on 31/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "Moment.h"

@implementation Moment
@synthesize moment_id,moment_img_url,moment_Created_Time,message,moment_elapsed_time,moment_expiration_time,moment_Creator_id,moment_Creator_firstName,moment_Creator_lastName,moment_Creator_profilePic,moment_likersArray,moment_Created_System_Time,moment_expires_at;

-(id)initWithDict:(NSDictionary *)dictData
{
    self=[super init];
    if (self) {
        if (dictData)
        {
            NSString *tempstr = [dictData objectForKey:@"moment_expiration_time"];
            int tempIndex = (int)([tempstr rangeOfString:@":" options:NSBackwardsSearch].location);
            NSString *strTimeRemain = [tempstr substringWithRange:NSMakeRange(0, tempIndex)];

            
            
            moment_id             =     [dictData objectForKey:@"moment_id"];
            moment_img_url        =     [dictData objectForKey:@"moment_img_url"];
            moment_Created_Time   =     [dictData objectForKey:@"created_date"];
            moment_Created_System_Time =[dictData objectForKey:@"system_created_datetime"];
            message=                    [dictData objectForKey:@"message"];
            moment_elapsed_time   =     [dictData objectForKey:@"elapsed_time"];
            moment_expiration_time=     strTimeRemain;
            moment_Creator_id     =     [dictData objectForKey:@"fb_id"];
            moment_Creator_firstName=   [dictData objectForKey:@"first_name"];
            moment_Creator_lastName =   [dictData objectForKey:@"last_name"];
            moment_Creator_profilePic=  [dictData objectForKey:@"profile_pic_url"];
            moment_likersArray       =  [dictData objectForKey:@"likes"];
            moment_expires_at        =  [dictData objectForKey:@"expire_at"];
        }
    }
    return self;
}


@end
