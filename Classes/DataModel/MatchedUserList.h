//
//  MatchedUserList.h
//  Tinder
//
//  Created by Rahul Sharma on 06/12/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MatchedUserList : NSManagedObject

@property (nonatomic, retain) NSString * fId;
@property (nonatomic, retain) NSString * fName;
@property (nonatomic, retain) NSString * lastActive;
@property (nonatomic, retain) NSString * proficePic;
@property (nonatomic, retain) NSString * status;

@end
