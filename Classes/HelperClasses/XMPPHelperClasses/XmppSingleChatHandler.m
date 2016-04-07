//
//  XmppSingleChatHandler.m
//  Karmic
//
//  Created by Sanskar on 08/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "XmppSingleChatHandler.h"
#import "XmppFriendHandler.h"
#import "SingleChatMessage.h"
#import "FacebookUtility.h"

@implementation XmppSingleChatHandler

static XmppSingleChatHandler *xmppSingleChatHandler;

+ (id)sharedInstance
{
    if (!xmppSingleChatHandler) {
        xmppSingleChatHandler  = [[self alloc] init];
    }
    return xmppSingleChatHandler;
}

//////////////////////////////////////////////////////////////////////////////////////////
///////////////////    Method To Load All Chat MSGS With Friend   ////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

-(NSMutableArray *)loadAllMesssagesForFriendName : (NSString *)friendName
{
    
    NSMutableArray * allChatMessagesArray = [[NSMutableArray alloc]init];
    NSManagedObjectContext *context = [APPDELEGATE managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"SingleChatMessages" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDesc];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(sender = %@) OR (reciever = %@)",friendName,friendName ];
    [request setPredicate:pred];
    NSManagedObject *matches = nil;
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error ];
    
    if([objects count] == 0)
    {
        
    }
    else
    {
        for (int i=0;i<[objects count];i++)
        {
            matches = objects[i];
            
            NSMutableDictionary *dictMsgObj = [[NSMutableDictionary alloc]initWithObjects:[NSMutableArray arrayWithObjects:[matches valueForKey:@"sender"],[matches valueForKey:@"reciever"],[matches valueForKey:@"message"] ,[matches valueForKey:@"messageID"],[matches valueForKey:@"messageStatus"],[matches valueForKey:@"mediaType"], nil] forKeys:[NSMutableArray arrayWithObjects:@"senderName",@"recieverName",@"msg",@"msgID",@"msgStatus",@"mediaType", nil] ];
          
            SingleChatMessage *message = [[SingleChatMessage alloc]initWithDict:dictMsgObj];
            [allChatMessagesArray addObject:message];
        }
    }
    
    return allChatMessagesArray;
}

//////////////////////////////////////////////////////////////////////////////////////////
///////////////////    Method To Get Time String From Date   /////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

-(NSString *)relativeDateStringForDate:(NSDate*)bDate

{
    
    const int SECOND = 1;
    
    const int MINUTE = 60 * SECOND;
    
    const int HOUR = 60 * MINUTE;
    
    //    const int DAY = 24 * HOUR;
    
    //    const int MONTH = 30 * DAY;
    
    
    
    NSDate *now = [NSDate date];
    
    NSTimeInterval delta = [bDate timeIntervalSinceDate:now] * -1.0;
    
    //NSTimeInterval delta =  1.0;
    
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSUInteger units = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit);
    
    NSDateComponents *components = [calendar components:units fromDate:bDate toDate:now options:0];
    
    
    
    NSString *relativeString;
    
    
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    
    
    if (delta < 0)
    {
        
       // relativeString = @"1 sec ago";
        
        [dateFormat setDateFormat:@"hh:mm a"];
        
        relativeString = [dateFormat stringFromDate:bDate];
        
        
    } else if (delta < 1 * MINUTE) {
        
      //  relativeString = (components.second == 1) ? @"1 sec ago" : [NSString stringWithFormat:@"%d secs ago",components.second];
        
        [dateFormat setDateFormat:@"hh:mm a"];
        
        relativeString = [dateFormat stringFromDate:bDate];
        
        
    } else if (delta < 2 * MINUTE) {
        
       // relativeString =  @"1 min ago";
        
        [dateFormat setDateFormat:@"hh:mm a"];
        
        relativeString = [dateFormat stringFromDate:bDate];
        
        
    }
    else if (delta < 45 * MINUTE) {
        
      //  relativeString = [NSString stringWithFormat:@"%d mins ago",components.minute];
        
        [dateFormat setDateFormat:@"hh:mm a"];
        
        relativeString = [dateFormat stringFromDate:bDate];
        
    }
    else if (delta < 90 * MINUTE) {
        
       // relativeString = @"1 hr ago";
        
        [dateFormat setDateFormat:@"hh:mm a"];
        
        relativeString = [dateFormat stringFromDate:bDate];
        
        
    }
    else if (delta < 24 * HOUR)
    {
        
       // relativeString = [NSString stringWithFormat:@"%d hrs ago",components.hour];
       
        [dateFormat setDateFormat:@"hh:mm a"];
        
        relativeString = [dateFormat stringFromDate:bDate];
    }
    else
    {
        
        [dateFormat setDateFormat:@"MMMM dd 'at' hh:mm a"];
        
        relativeString = [dateFormat stringFromDate:bDate];//(components.year <= 1) ? @"1 y ago" : [NSString stringWithFormat:@"%d y ago",components.year];
        
    }
    
    return relativeString;
    
}



-(void)clearConversationForFriendName:(NSString *)friendName
{
    NSString *recieverName = friendName;
    NSManagedObjectContext *context = [APPDELEGATE managedObjectContext];
    
    NSError*        error        = nil;
    NSFetchRequest* request      = [NSFetchRequest fetchRequestWithEntityName:@"SingleChatMessages"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"(sender = %@) OR (reciever = %@)",recieverName,recieverName ]];
    NSArray*         deleteArray = [context executeFetchRequest:request error:&error];
    
    if (deleteArray != nil)
    {
        for (NSManagedObject* object in deleteArray)
        {
            [context deleteObject:object];
        }
        [context save:&error];
        
        
        [[XmppFriendHandler sharedInstance] updatePendingMessageOfFriend:friendName message:@"" messageTime:@"" messageStatus:@"" messageID:@""];
        //### Error handling.
    }
    else
    {
        //### Error handling.
    }
}


-(NSDictionary *)getMessageDictWithMessageId:(NSString *)messageID
{
    
    NSMutableDictionary *dictMsgObj = [[NSMutableDictionary alloc] init];
    NSManagedObjectContext *context = [APPDELEGATE managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"SingleChatMessages" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDesc];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(messageID = %@)",messageID ];
    [request setPredicate:pred];
    NSManagedObject *matches = nil;
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error ];
    
    if([objects count] == 0)
    {
        
    }
    else
    {
        matches = objects[0];
        dictMsgObj = [[NSMutableDictionary alloc]initWithObjects:[NSMutableArray arrayWithObjects:[matches valueForKey:@"sender"],[matches valueForKey:@"reciever"],[matches valueForKey:@"message"] ,[matches valueForKey:@"messageID"],[matches valueForKey:@"messageStatus"],[matches valueForKey:@"mediaType"], nil] forKeys:[NSMutableArray arrayWithObjects:@"senderName",@"recieverName",@"msg",@"msgID",@"msgStatus",@"mediaType", nil] ];
    }
    return dictMsgObj;
}


-(void)deleteMessageDictWithMessageId:(NSString *)messageID
{

    NSManagedObjectContext *context = [APPDELEGATE managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"SingleChatMessages" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDesc];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(messageID = %@)",messageID ];
    [request setPredicate:pred];
    NSManagedObject *matches = nil;
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error ];
    
    if([objects count])
    {
        matches = objects[0];
        [context deleteObject:matches];
        [context save:&error];
    }

}

////by sanket for updating status of sent message

-(void)updateMessageStatusOnDataBase:(NSString *)msgID MsgStatus:(NSString *)status
{
    NSManagedObjectContext *context = [APPDELEGATE managedObjectContext];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"SingleChatMessages" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDesc];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(messageID = %@)",msgID ];
    [request setPredicate:pred];
    NSManagedObject *matches = nil;
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error ];
    
    if([objects count] == 0)
    {
        //_status.text = @"No matches found";
    }
    else
    {
        for (NSManagedObject *object in objects) {
            [object setValue:status forKey:@"messageStatus"];
            [context save:&error];
        }
        
    }
}

/*
-(void)extractSingleChatMessage:(XMPPMessage *)message :(NSString *)name
{
    NSString *msgID = [[message attributeForName:@"id"]stringValue];
    NSString *body = [[message elementForName:@"body"] stringValue];
    NSString *displayName = @"";//[user displayName];
   
    
    NSString *attachment = [[message elementForName:@"attachement"] stringValue];
    NSString *mediaType = @"";
    
    NSDictionary *msgDictFromDB;
    
    if([body isEqualToString:@"msgWithJId"])
    {
        msgDictFromDB = [self isMessageForGettingMessageStatus:msgID];
    }
    
    if([displayName isEqualToString:@""] || displayName == nil)
    {
        NSString *jid=[[NSArray arrayWithArray:[[[message attributeForName:@"from"] stringValue]componentsSeparatedByString:@"/"] ] objectAtIndex:0];
        displayName=[[NSArray arrayWithArray:[jid componentsSeparatedByString: @"@"] ]objectAtIndex:0];
    }
    
    
    if (msgDictFromDB)
    {
        if([[msgDictFromDB objectForKey:@"msgID"] isEqualToString:msgID])
        {
            [self updateMessageStatusOnDataBase:msgID MsgStatus:@"D"];
        }
        
        if ([[[XmppCommunicationHandler sharedInstance] currentFriendName] isEqualToString:displayName] )
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_XMPP_MESSAGE_STATUS_CHANGED object:self userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:msgDictFromDB,@"D", nil] forKeys:[NSArray arrayWithObjects:@"msdDict",@"status", nil] ]];
        }
        //updating last message status
        
        [[XmppFriendHandler sharedInstance] updateLastMessageStatusOfFriend:displayName messageID:msgID messageStatus:@"D"];
    }
    else
    {
        
        if (attachment.length)
        {
            
            if (body.length)
            {
                
                NSString *attachMentType =[[body componentsSeparatedByString:@"#$"] objectAtIndex:0];
                
                mediaType = attachMentType;
                body = [attachment stringByAppendingString:@"#$"];
                
                if ([attachMentType isEqualToString:@"IMAGE"])
                {
                    mediaType = @"IMAGE";
                    
                    body = [attachment stringByAppendingString:@"#$"];
                }
            }
        }
        else if ([body rangeOfString:@"TindercloneImage_"].location != NSNotFound)
        {
            NSArray *tempArr = [body componentsSeparatedByString:@"_"];
            
            if (tempArr.count > 1)
            {
                mediaType = @"IMAGE";
                body = [body stringByReplacingOccurrencesOfString:@"TindercloneImage_" withString:@""];
            }
        }
        
        
        
        
        
        {
            //for name with sever address
            
            if( [displayName rangeOfString:CHAT_SERVER_ADDRESS].location != NSNotFound)
            {
                displayName=[[NSArray arrayWithArray:[displayName componentsSeparatedByString: @"@"] ]objectAtIndex:0];
            }
            
            NSString *friendJID = [NSString stringWithFormat:@"%@@%@/%@",displayName,CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
            NSString *myJID = [NSString stringWithFormat:@"%@@%@/%@",MY_USER_NAME,CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
            
            
            //Updated By Sanskar
            NSInteger timestampMin = [[NSDate date] timeIntervalSince1970];
            
            NSString *timeStamp = [UtilityClass getTimeStampWithDate:[NSDate date]];
            
            XmppFriendHandler *friendHandler = [XmppFriendHandler sharedInstance];
            XmppFriend *friendObj = [friendHandler getXmppFriendWithName:displayName];
            
            if (![friendObj.isBlocked isEqualToString:@"YES"])
            {
                
                NSString *msgTime ;
                
                if ([body rangeOfString:@"#$"].location != NSNotFound)
                {
                    NSArray* tempArr = [body componentsSeparatedByString: @"#$"];
                    msgTime = [tempArr objectAtIndex:[tempArr count]-1 ];
                    NSString *tempStr2 = @"";
                    for(int i=0;i<[tempArr count]-1;i++)
                    {
                        if(i == [tempArr count]-2)
                        {
                            tempStr2 = [tempStr2 stringByAppendingString:[NSString stringWithString: [tempArr objectAtIndex:i]]];
                        }
                        else
                        {
                            tempStr2 = [tempStr2 stringByAppendingString:[NSString stringWithString: [tempArr objectAtIndex:i]]];
                            tempStr2 = [tempStr2 stringByAppendingString:@"#$"];
                        }
                    }
                    // body = tempStr2;
                }
                
                if (!msgTime.length) {
                    
                    body = [NSString stringWithFormat:@"%@#$%ld",body,(long)timestampMin];
                }
                
                
                
                if (friendObj)
                {
                    [friendHandler updatePendingMessageOfFriend:displayName message:body messageTime:timeStamp messageStatus:@"" messageID:@""];
                    
                    if(![displayName isEqualToString:[[XmppCommunicationHandler sharedInstance] currentFriendName]])
                    {
                        [friendHandler updatePendingMessageCounter:displayName isResetting:NO];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_XMPP_UPDATE_MESSAGE_COUNTER object:self userInfo:nil];
                        
                    }
                }
                
                if([displayName isEqualToString:[[XmppCommunicationHandler sharedInstance] currentFriendName]])
                {
                    NSMutableDictionary *dictMsgObj = [[NSMutableDictionary alloc]initWithObjects:[NSMutableArray arrayWithObjects:displayName,MY_USER_NAME,body ,msgID,@"recieved",mediaType, nil] forKeys:[NSMutableArray arrayWithObjects:@"senderName",@"recieverName",@"msg",@"msgID",@"messageStatus",@"mediaType", nil] ];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"recieveMessage" object:self userInfo:dictMsgObj];
                    
                }
                
                //
                //                [[XmppCommunicationHandler sharedInstance] sendMessage:friendJID Sender:myJID Message:@"msgWithJId" MessageID:msgID MessageType:@"chat"];
                //
                
                [[XmppCommunicationHandler sharedInstance] saveSingleChatMessage:MY_USER_NAME Sender:displayName Message:body MessageID:msgID MediaType:mediaType];
                
                
                if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName message:body delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                     [alertView show];
                }
                else
                    
                {
                    
                    
                    // We are not active, so use a local notification instead
                    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                    localNotification.alertAction = @"Ok";
                    
                    
                    NSRange range = [body rangeOfString:@"#"];
                    
                    
                    
                    NSString *newString = [body substringToIndex:range.location];
                                     localNotification.alertBody = [NSString stringWithFormat:@"You have a new message\n\n%@",newString];
                    
                    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                }
            }
        }
    }
}
*/

-(NSDictionary *)isMessageForGettingMessageStatus:(NSString *)messageID
{
    NSMutableDictionary *getDict;
    BOOL isExist = NO;
    
    getDict = [NSMutableDictionary dictionaryWithDictionary:[self getMessageDictWithMessageId:messageID]];
    
    return getDict;
}

-(void)sendOfflineMessages
{
    NSManagedObjectContext *context = [APPDELEGATE managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"SingleChatMessages" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDesc];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(sender = %@) AND (messageStatus = %@)",MY_USER_NAME,@"W"];
    [request setPredicate:pred];
    NSManagedObject *matches = nil;
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error ];
    
    if([objects count] == 0)
    {
        
    }
    else
    {
        for (int i=0;i<[objects count];i++)
        {
            matches = objects[i];
            
            NSString *recieverJid = [NSString stringWithFormat:@"%@@%@/%@",[matches valueForKey:@"reciever"],CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
            NSString *senderJid = [NSString stringWithFormat:@"%@@%@/%@",MY_USER_NAME,CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
            
            [[XmppCommunicationHandler sharedInstance] sendMessage:recieverJid Sender:senderJid Message:[matches valueForKey:@"message"] MessageID:[matches valueForKey:@"messageID"] MessageType:@"chat"];
        }
    }
}



@end
