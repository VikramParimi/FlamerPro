//
//  Photo.h
//  Flamer Pro
//
//  Created by Caroll on 3/18/16.
//  Copyright © 2016 AppDupe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Photo : NSObject

@property (nonatomic,copy) NSString *url;
@property (nonatomic,copy) NSNumber *width;
@property (nonatomic,copy) NSNumber *height;
@property (nonatomic,copy) NSNumber *orderId;

+(Photo*) create;
-(id)init;
@end
