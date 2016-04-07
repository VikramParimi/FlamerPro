//
//  Question.h
//  Tinder
//
//  Created by Elluminati - macbook on 23/04/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Question : NSObject

@property(nonatomic,copy)NSString *id_Que;
@property(nonatomic,copy)NSString *option_a;
@property(nonatomic,copy)NSString *option_b;
@property(nonatomic,copy)NSString *option_c;
@property(nonatomic,copy)NSString *option_d;
@property(nonatomic,copy)NSString *pref_a;
@property(nonatomic,copy)NSString *pref_b;
@property(nonatomic,copy)NSString *pref_c;
@property(nonatomic,copy)NSString *pref_d;
@property(nonatomic,copy)NSString *quetion;
@property(nonatomic,copy)NSString *your_ans;

-(id)initWithDict:(NSDictionary *)dictData;

@end
