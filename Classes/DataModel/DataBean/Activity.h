//
//  Activity.h
//  Tinder
//
//  Created by Sanskar on 05/01/15.
//  Copyright (c) 2015 AppDupe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Activity : NSObject

@property(nonatomic,copy) NSString *activity_type;
@property(nonatomic,copy) NSString *activity_image;
@property(nonatomic,copy) NSString *activity_Created_date;
@property(nonatomic,copy) NSString *activity_Creator_id;
@property(nonatomic,copy) NSString *activity_Creator_firstName;
@property(nonatomic,copy) NSString *activity_Creator_lastName;
@property(nonatomic,copy) NSString *activity_Creator_profilePic;
@property(nonatomic,copy) NSString *activity_Creator_entity_id;
@property(nonatomic,retain) NSDictionary *activity_momentDict;

-(id)initWithDict:(NSDictionary *)dictData;

@end
