//
//  XmppFriend.h
//  Karmic
//
//  Created by Sanskar on 08/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface XmppFriend : NSManagedObject

@property (nonatomic, retain) NSString * friend_JID;
@property (nonatomic, retain) NSString * friend_Name;
@property (nonatomic, retain) NSString * friend_DisplayName;

@property (nonatomic, retain) NSNumber * messageCount;
@property (nonatomic, retain) NSString * lastMessage;
@property (nonatomic, retain) NSString * lastMessageTime;
@property (nonatomic, retain) NSData   * profileImage;
@property (nonatomic, retain) NSString * presenceStatus;
@property (nonatomic, retain) NSString * lastMessageStatus;
@property (nonatomic, retain) NSString * lastMessageID;

@property (nonatomic, retain) NSString* isBlocked;

@end
