//
//  XmppSingleChatHandler.h
//  Karmic
//
//  Created by Sanskar on 08/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPMessage.h"


@interface XmppSingleChatHandler : NSObject
{
    __block NSString *name;
}

+ (id)sharedInstance ;

-(NSMutableArray *)loadAllMesssagesForFriendName : (NSString *)friendName;
-(NSString *)relativeDateStringForDate:(NSDate*)bDate;
-(void)clearConversationForFriendName:(NSString *)friendName;
-(NSDictionary *)getMessageDictWithMessageId:(NSString *)messageID;
-(void)updateMessageStatusOnDataBase:(NSString *)msgID MsgStatus:(NSString *)status;
-(void)extractSingleChatMessage:(XMPPMessage *)message :(NSString *)name;
-(void)sendOfflineMessages;
-(void)deleteMessageDictWithMessageId:(NSString *)messageID;
@end
