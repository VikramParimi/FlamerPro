//
//  User.h
//  Tinder
//
//  Created by Elluminati - macbook on 07/05/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Photo;
@interface User : NSManagedObject

@property(nonatomic,copy)NSString *fbid;
@property(nonatomic,copy)NSString *fbToken;
@property(nonatomic,copy)NSString *first_name;
@property(nonatomic,copy)NSString *last_name;
@property(nonatomic,copy)NSString *sex;
@property(nonatomic,copy)NSString *push_token;
@property(nonatomic,copy)NSString *curr_lat;
@property(nonatomic,copy)NSString *curr_long;
@property(nonatomic,copy)NSString *dob;
@property(nonatomic,copy)NSString *profile_pic;
@property(nonatomic,assign)int flag;

// for tinder.
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *bio;
@property (nonatomic,copy) NSString *gender;
@property (nonatomic,copy) NSNumber *discoverable;
@property (nonatomic,copy) NSDate   *dateCreated;
@property (nonatomic,copy) NSDate   *dateOfBirth;
@property (nonatomic,copy) NSDate   *lastActive;
@property (nonatomic,copy) NSString *xAuthToken;
@property (nonatomic,copy) NSString *tinderID;
@property (nonatomic,copy) NSNumber *ageFilterMin;
@property (nonatomic,copy) NSNumber *ageFilterMax;
@property (nonatomic,copy) NSNumber *distanceFilter;
@property (nonatomic,copy) NSNumber* liked;
@property (nonatomic,copy) NSNumber* match;
@property (nonatomic,copy) NSNumber* mainUser;
@property (nonatomic,copy) NSNumber* commonLikesCount;
@property (nonatomic,copy) NSNumber* commonFriendsCount;
@property (nonatomic,copy) NSMutableSet* photos;

// for chatting.
@property (nonatomic, retain) NSString * friend_JID;
@property (nonatomic, retain) NSString * friend_Name;
@property (nonatomic, retain) NSString * friend_DisplayName;
//@property (nonatomic, retain) NSNumber * messageCount;

@property (nonatomic, retain) NSString * lastMessageTime;
@property (nonatomic, retain) NSData   * profileImage;
@property (nonatomic, retain) NSString * presenceStatus;
@property (nonatomic, retain) NSString * lastMessageStatus;
@property (nonatomic, retain) NSString * lastMessageID;
@property (nonatomic, retain) NSString * isBlocked;

@property (nonatomic,copy) NSMutableArray* messages;


-(int) messageCount;
-(NSString*) lastMessage;

+(User*) currentUser;
+(User*) create;
-(void)  setUser;
- (int)  getAge;

-(void)save;
-(void)addPhotos:(NSMutableSet*)photos;
-(void)removePhotos:(NSMutableSet*)photos;
-(int) photoCount;
-(Photo*) photoIndex:(int)index;
-(NSString*) lastActiveString;

// for message.


@end
