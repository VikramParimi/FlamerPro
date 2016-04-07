//
//  Moment.h
//  Tinder
//
//  Created by Sanskar on 31/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Moment : NSObject

@property(nonatomic,copy) NSString *moment_id;
@property(nonatomic,copy) NSString *moment_img_url;
@property(nonatomic,copy) NSString *moment_Created_Time;
@property(nonatomic,copy) NSString *moment_Created_System_Time;
@property(nonatomic,copy) NSString *message;
@property(nonatomic,copy) NSString *moment_elapsed_time;
@property(nonatomic,copy) NSString *moment_expiration_time;
@property(nonatomic,copy) NSString *moment_Creator_id;
@property(nonatomic,copy) NSString *moment_Creator_firstName;
@property(nonatomic,copy) NSString *moment_Creator_lastName;
@property(nonatomic,copy) NSString *moment_Creator_profilePic;
@property(nonatomic,copy) NSArray  *moment_likersArray;
@property(nonatomic,copy) NSString *moment_expires_at;

-(id)initWithDict:(NSDictionary *)dictData;

@end
