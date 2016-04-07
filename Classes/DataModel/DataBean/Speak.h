//
//  Speak.h
//  Tinder
//
//  Created by Elluminati - macbook on 25/04/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Speak : NSObject

@property(nonatomic,copy)NSString *lang;
@property(nonatomic,copy)NSString *frean;

-(id)initWithDict:(NSDictionary *)dictData;

@end
