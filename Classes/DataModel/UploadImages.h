//
//  UploadImages.h
//  Tinder
//
//  Created by Rahul Sharma on 06/12/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UploadImages : NSManagedObject
@property (nonatomic, retain) NSString * imageUrlLocal;
@property (nonatomic, retain) NSString * imageUrlFB;
@property (nonatomic, retain) NSString * fbId;

@end
