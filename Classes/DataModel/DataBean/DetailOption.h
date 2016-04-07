//
//  DetailOption.h
//  Tinder
//
//  Created by Elluminati - macbook on 24/04/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DetailOption : NSObject

@property(nonatomic,copy)NSString *idD;
@property(nonatomic,copy)NSString *flag;
@property(nonatomic,copy)NSString *options;

-(id)initWithDict:(NSDictionary *)dictData;

@end
