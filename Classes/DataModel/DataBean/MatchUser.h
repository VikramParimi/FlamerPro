//
//  MatchUser.h
//  Tinder
//
//  Created by Elluminati - macbook on 28/04/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MatchUser : NSObject

@property(nonatomic,copy)NSString *Boost;
@property(nonatomic,copy)NSString *age;
@property(nonatomic,copy)NSString *fbId;
@property(nonatomic,copy)NSString *firstName;
@property(nonatomic,copy)NSString *lat;
@property(nonatomic,copy)NSString *lon;
@property(nonatomic,copy)NSString *pPic;
@property(nonatomic,copy)NSString *percentage;
@property(nonatomic,copy)NSString *persDesc;
@property(nonatomic,copy)NSString *sex;

-(id)initWithDict:(NSDictionary *)dictData;

@end

/*
 {
 Boost = 1;
 age = 21;
 fbId = 100001778249167;
 firstName = Tanvir;
 lat = "22.282419";
 long = "70.759299";
 pPic = "http://192.168.0.114/PHP_ServerF/phpserver/pics/1959610_612879215448014_89809865_n.jpg";
 percentage = "20%";
 persDesc = "";
 sex = 1;
 }
*/