//
//  XmppFriendHandler.h
//  Karmic
//
//  Created by Sanskar on 08/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XmppFriend.h"

@interface XmppFriendHandler : NSObject
{
    NSString *postUrl;
    NSString *postMsg;
    NSString *sessionToken;
    NSString *deviceID;
}

+ (id)sharedInstance ;

-(BOOL)isFriendAlreadyExistInDatabase : (NSString *)friendName;
-(void)removeFriendFromDatabase : (NSString *)friendName;
-(void)insertFriendInfoInDatabase : (NSDictionary *)dictFriendInfo;
-(void)updateFriendInfoInDatabase : (NSDictionary *)dictFriendInfo;
-(void)insertOrUpdateFriendInfoInDatabase :(NSDictionary *)dictFriendInfo;
-(NSArray *)getAllXmppFriendsFromDB;
-(XmppFriend *)getXmppFriendWithName : (NSString *)friendName;
-(void)updatePresenceStatusOfFriend : (NSString *)friendName andStatus : (NSString *)currentStatus;
//-(void)updatePendingMessageOfFriend  : (NSString *)friendName message : (NSString *)lastMessage messageTime :(NSString *)lastMsgTime;
-(void)updatePendingMessageCounter : (NSString *)friendName isResetting : (BOOL)isResetCounter;
-(void)deleteAllFriendsRecordsFromDb;
-(NSDictionary *)getFriendInformationDictFromWebservice:(NSString *)friendFbID;
-(NSArray *)getFriendsWithPendingMsgs;

-(void)blockFriend : (NSString *)friendName;
-(void)unBlockFriend : (NSString *)friendName;
-(void)updatePendingMessageOfFriend  : (NSString *)friendName message : (NSString *)lastMessage messageTime :(NSString *)lastMsgTime messageStatus:(NSString *)lastMsgStatus messageID : (NSString *)lastMessageID;
-(void)updateLastMessageStatusOfFriend  : (NSString *)friendName messageID : (NSString *)lastMessageID  messageStatus:(NSString *)lastMsgStatus;
@end
