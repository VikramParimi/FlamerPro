//
//  Photo.m
//  Flamer Pro
//
//  Created by Caroll on 3/18/16.
//  Copyright © 2016 AppDupe. All rights reserved.
//

#import "Photo.h"

@implementation Photo

@synthesize width = _width, height = _height, url = _url, orderId = _orderId;

+(Photo*) create
{
    Photo *photo = [[Photo alloc] init];
    return photo;
}

-(id)init
{
    self = [super init];
    return self;
}

@end
