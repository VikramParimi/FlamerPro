//
//  Login.h
//  Tinder
//
//  Created by Rahul Sharma on 05/12/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Login : NSManagedObject

@property (nonatomic, retain) NSString * firstname;
@property (nonatomic, retain) NSString * lastname;
@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSString * fbId;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSNumber * prefsex;
@property (nonatomic, retain) NSNumber * lowerage;
@property (nonatomic, retain) NSNumber * maxage;
@property (nonatomic, retain) NSString * likes;
@property (nonatomic, retain) NSString * about;
@property (nonatomic, retain) NSString * dob;
@property (nonatomic, retain) NSString * email;

@end
