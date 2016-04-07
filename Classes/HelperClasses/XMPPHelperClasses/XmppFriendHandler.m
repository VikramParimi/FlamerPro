//
//  XmppFriendHandler.m
//  Karmic
//
//  Created by Sanskar on 08/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "XmppFriendHandler.h"
#import "NSData+Base64Encoding.h"

@implementation XmppFriendHandler

static XmppFriendHandler *xmppFriendhandler;

+ (id)sharedInstance
{
    if (!xmppFriendhandler) {
        xmppFriendhandler  = [[self alloc] init];
    }
    return xmppFriendhandler;
}

//////////////////////////////////////////////////////////////////////////////////////////
///////////////////    Method to check if friend is already exist in db   ////////////////
//////////////////////////////////////////////////////////////////////////////////////////

-(BOOL)isFriendAlreadyExistInDatabase : (NSString *)friendName
{
    NSManagedObjectContext *managedObjectContext = [APPDELEGATE managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XmppFriend"  inManagedObjectContext: managedObjectContext];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"friend_Name == %@",friendName]];
    NSError * error = nil;
    
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetch error:&error];
    
    if([fetchedObjects count])
        return YES;
    else
        return NO;
}

//////////////////////////////////////////////////////////////////////////////////////////
///////////////////    Method to remove friend exist in db   ////////////////
//////////////////////////////////////////////////////////////////////////////////////////

-(void)removeFriendFromDatabase : (NSString *)friendName
{
    NSManagedObjectContext *managedObjectContext = [APPDELEGATE managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XmppFriend"  inManagedObjectContext: managedObjectContext];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"friend_Name == %@",friendName]];
    NSError *error;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetch error:&error];
    
    if([fetchedObjects count])
    {
        [managedObjectContext deleteObject:[fetchedObjects lastObject]];
    }
       if (![managedObjectContext save:&error])
    {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}


//////////////////////////////////////////////////////////////////////////////////////////
///////////////////    Method to Insert new Friend Record in db  /////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

-(void)insertFriendInfoInDatabase : (NSDictionary *)dictFriendInfo
{
    
    NSManagedObjectContext *managedObjectContext = [APPDELEGATE managedObjectContext];
   
    XmppFriend *friendObject = [NSEntityDescription insertNewObjectForEntityForName:@"XmppFriend"
                                                             inManagedObjectContext:managedObjectContext];
    
    friendObject.friend_Name = [dictFriendInfo valueForKey:@"friendName"];
    friendObject.friend_JID = [dictFriendInfo valueForKey:@"friendJid"];
    friendObject.presenceStatus = [dictFriendInfo valueForKey:@"presenceStatus"];
    friendObject.messageCount = [dictFriendInfo valueForKey:@"messageCount"];
    friendObject.lastMessage = [dictFriendInfo valueForKey:@"lastMessage"];
    friendObject.lastMessageTime = [dictFriendInfo valueForKey:@"lastMessageTime"];
    friendObject.profileImage = [dictFriendInfo valueForKey:@"friendImage"];
    friendObject.friend_DisplayName=[dictFriendInfo valueForKey:@"friendDisplayName"];
    friendObject.isBlocked = [dictFriendInfo valueForKey:@"isBlocked"];
    NSError *error;
    if (![managedObjectContext save:&error])
    {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

//////////////////////////////////////////////////////////////////////////////////////////
///////////////////    Method To Update Existing Friend Record   /////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

-(void)updateFriendInfoInDatabase:(NSDictionary *)dictFriendInfo
{
    NSManagedObjectContext *managedObjectContext = [APPDELEGATE managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XmppFriend"  inManagedObjectContext: managedObjectContext];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"friend_Name == %@",[dictFriendInfo valueForKey:@"friendName"]]];
    NSError * error = nil;
    
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetch error:&error];
    
    if([fetchedObjects count])
    {
        XmppFriend *friendObject = [fetchedObjects lastObject];
        
       // friendObject.friend_Name = [dictFriendInfo valueForKey:@"friendName"];
       // friendObject.friend_JID = [dictFriendInfo valueForKey:@"friendJid"];
        
       // friendObject.messageCount = [dictFriendInfo valueForKey:@"messageCount"];
       // friendObject.lastMessage = [dictFriendInfo valueForKey:@"lastMessage"];
       // friendObject.lastMessageTime = [dictFriendInfo valueForKey:@"lastMessageTime"];
        
       // friendObject.presenceStatus = [dictFriendInfo valueForKey:@"presenceStatus"];
        friendObject.profileImage = [dictFriendInfo valueForKey:@"friendImage"];
        friendObject.friend_DisplayName=[dictFriendInfo valueForKey:@"friendDisplayName"];
       // friendObject.isBlocked = [dictFriendInfo valueForKey:@"isBlocked"];
        NSError *error;
        if (![managedObjectContext save:&error])
        {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }

}

//////////////////////////////////////////////////////////////////////////////////////////
///////////////////    Method To Insert Or Update Friend Record   ////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

-(void)insertOrUpdateFriendInfoInDatabase : (NSDictionary *)dictFriendInfo
{
    
    NSManagedObjectContext *managedObjectContext = [APPDELEGATE managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XmppFriend"  inManagedObjectContext: managedObjectContext];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"friend_Name == %@",[dictFriendInfo valueForKey:@"friendName"]]];
    NSError * error = nil;
    
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetch error:&error];
    
    if([fetchedObjects count])
    {
        XmppFriend *friendObject = [fetchedObjects lastObject];
       // friendObject.friend_Name = [dictFriendInfo valueForKey:@"friendName"];
       // friendObject.friend_JID = [dictFriendInfo valueForKey:@"friendJid"];
       // friendObject.presenceStatus = [dictFriendInfo valueForKey:@"presenceStatus"];
        //friendObject.messageCount = [dictFriendInfo valueForKey:@"messageCount"];
        //friendObject.lastMessage = [dictFriendInfo valueForKey:@"lastMessage"];
        //friendObject.lastMessageTime = [dictFriendInfo valueForKey:@"lastMessageTime"];
        friendObject.profileImage = [dictFriendInfo valueForKey:@"friendImage"];
        friendObject.isBlocked = [dictFriendInfo valueForKey:@"isBlocked"];
        friendObject.friend_DisplayName=[dictFriendInfo valueForKey:@"friendDisplayName"];
        NSError *error;
        if (![managedObjectContext save:&error])
        {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
    else
    {
        XmppFriend *friendObject = [NSEntityDescription insertNewObjectForEntityForName:@"XmppFriend"
                                                             inManagedObjectContext:managedObjectContext];
        
        friendObject.friend_Name = [dictFriendInfo valueForKey:@"friendName"];
        friendObject.friend_JID = [dictFriendInfo valueForKey:@"friendJid"];
        friendObject.presenceStatus = [dictFriendInfo valueForKey:@"presenceStatus"];
        friendObject.messageCount = [dictFriendInfo valueForKey:@"messageCount"];
        friendObject.lastMessage = [dictFriendInfo valueForKey:@"lastMessage"];
        friendObject.lastMessageTime = [dictFriendInfo valueForKey:@"lastMessageTime"];
        friendObject.profileImage = [dictFriendInfo valueForKey:@"friendImage"];
        friendObject.isBlocked = [dictFriendInfo valueForKey:@"isBlocked"];
        friendObject.friend_DisplayName=[dictFriendInfo valueForKey:@"friendDisplayName"];
        NSError *error;
        if (![managedObjectContext save:&error])
        {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
    }
}

//////////////////////////////////////////////////////////////////////////////////////////
///////////////////    Method To Fetch All Existing Friend Records   /////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

-(NSArray *)getAllXmppFriendsFromDB
{
    NSManagedObjectContext *managedObjectContext = [APPDELEGATE managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XmppFriend"  inManagedObjectContext: managedObjectContext];
    [fetch setEntity:entityDescription];
    NSError * error = nil;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetch error:&error];
    return fetchedObjects;
}

//////////////////////////////////////////////////////////////////////////////////////////
///////////////////    Method To Fetch Friend Record With Name  //////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

-(XmppFriend *)getXmppFriendWithName : (NSString *)friendName
{
    if ([friendName rangeOfString:XmppJidPrefix].location == NSNotFound) {
        friendName = [NSString stringWithFormat:@"%@%@",XmppJidPrefix,friendName];
    }
    
    NSManagedObjectContext *managedObjectContext = [APPDELEGATE managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XmppFriend"  inManagedObjectContext: managedObjectContext];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"friend_Name == %@",friendName]];
    NSError * error = nil;
    
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetch error:&error];
    
    if([fetchedObjects count])
    {
        XmppFriend *friendObject = [fetchedObjects lastObject];
        return friendObject;
    }
    else
        return nil;
}

//////////////////////////////////////////////////////////////////////////////////////////
///////////////////    Method To Update Presence Status Of Friend   //////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

-(void)updatePresenceStatusOfFriend : (NSString *)friendName andStatus : (NSString *)currentStatus
{
    NSManagedObjectContext *managedObjectContext = [APPDELEGATE managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XmppFriend"  inManagedObjectContext: managedObjectContext];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"friend_Name == %@",friendName]];
    NSError * error = nil;
    
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetch error:&error];
    
    if([fetchedObjects count])
    {
        XmppFriend *friendObject = [fetchedObjects lastObject];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_XMPP_FRIENDS_PRESENCE_UPDATE object:self userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:friendObject,currentStatus, nil] forKeys:[NSArray arrayWithObjects:@"friendObj",@"status", nil] ]];
        
        
        friendObject.presenceStatus = currentStatus;
        
        
        NSError *error;
        if (![managedObjectContext save:&error])
        {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
    else
    {
        //If Not yet friend then enter dummy info
        
        NSString *deviceID = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbID"];
        NSString *myXMMPID =  [NSString stringWithFormat:@"%@%@",@"fb_", deviceID];
        
        
        NSMutableDictionary *dictFriend = [[NSMutableDictionary alloc] init];
        
        if (friendName.length && ![friendName isEqualToString:myXMMPID])
        {
            NSString *jid = [NSString stringWithFormat:@"%@@%@/%@",friendName,CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
            
            [dictFriend setObject:friendName forKey:@"friendName"];
            [dictFriend setObject:jid forKey:@"friendJid"];
            [dictFriend setObject:[NSNumber numberWithInt:0] forKey:@"messageCount"];
            [dictFriend setObject:@"You 're a match! Now say Hi :)" forKey:@"lastMessage"];
            [dictFriend setObject:@"" forKey:@"lastMessageTime"];//
            [dictFriend setObject:currentStatus forKey:@"presenceStatus"];
            [dictFriend setObject:@"" forKey:@"friendDisplayName"];
            [dictFriend setObject:@"NO" forKey:@"isBlocked"];
            [dictFriend setObject:[NSData dataFromBase64String:@""] forKey:@"friendImage"];
            [dictFriend setObject:@"NO" forKey:@"isRequestTransactionCompleted"];
            
            [[XmppFriendHandler sharedInstance] insertOrUpdateFriendInfoInDatabase:dictFriend];
            
            
        }
        
    }
    
}


//////////////////////////////////////////////////////////////////////////////////////////
///////////////////    Method To Update Last Msg And Time Sent By Friend   ///////////////
//////////////////////////////////////////////////////////////////////////////////////////


-(void)updatePendingMessageOfFriend  : (NSString *)friendName message : (NSString *)lastMessage messageTime :(NSString *)lastMsgTime messageStatus:(NSString *)lastMsgStatus messageID : (NSString *)lastMessageID
{
    NSManagedObjectContext *managedObjectContext = [APPDELEGATE managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XmppFriend"  inManagedObjectContext: managedObjectContext];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"friend_Name == %@",friendName]];
    NSError * error = nil;
    
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetch error:&error];
    
    if([fetchedObjects count])
    {
        XmppFriend *friendObject = [fetchedObjects lastObject];
        
        
        NSString *timeStamp = @"";
        NSString *msgstr = @"";
        
        if ([lastMessage rangeOfString:@"#$"].location != NSNotFound)
        {
            NSArray* tempArr = [lastMessage componentsSeparatedByString: @"#$"];
            timeStamp = [tempArr lastObject];
            
            msgstr = [tempArr objectAtIndex:[tempArr count]-1 ];
            
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
            
            msgstr = tempStr2;
            
        }
        else
            msgstr = lastMessage;
        
        
        if (!timeStamp.length) {
            lastMsgTime = timeStamp;
        }
        
        friendObject.lastMessage = msgstr;
        friendObject.lastMessageTime = lastMsgTime;
        friendObject.lastMessageStatus = lastMsgStatus;
        friendObject.lastMessageID = lastMessageID;
        
        NSError *error;
        if (![managedObjectContext save:&error])
        {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
}

/*
-(void)updatePendingMessageOfFriend  : (NSString *)friendName message : (NSString *)lastMessage messageTime :(NSString *)lastMsgTime
{
    NSManagedObjectContext *managedObjectContext = [APPDELEGATE managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XmppFriend"  inManagedObjectContext: managedObjectContext];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"friend_Name == %@",friendName]];
    NSError * error = nil;
    
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetch error:&error];
    
    if([fetchedObjects count])
    {
        XmppFriend *friendObject = [fetchedObjects lastObject];
        
        
        NSString *timeStamp = @"";
        NSString *msgstr = @"";
        
        if ([lastMessage rangeOfString:@"#$"].location != NSNotFound)
        {
            NSArray* tempArr = [lastMessage componentsSeparatedByString: @"#$"];
            timeStamp = [tempArr lastObject];
            
            msgstr = [tempArr objectAtIndex:[tempArr count]-1 ];
            
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
            
            msgstr = tempStr2;
            
        }
        else
            msgstr = lastMessage;
        
        
        
        
        friendObject.lastMessage = msgstr;
        
        if (!timeStamp.length) {
            lastMsgTime = timeStamp;
        }
        friendObject.lastMessageTime = lastMsgTime;
        
        NSError *error;
        if (![managedObjectContext save:&error])
        {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
}*/

//////////////////////////////////////////////////////////////////////////////////////////
///////////////////    Method To Update Pending MSG Counter   ////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

-(void)updatePendingMessageCounter : (NSString *)friendName isResetting : (BOOL)isResetCounter
{
    NSManagedObjectContext *managedObjectContext = [APPDELEGATE managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XmppFriend"  inManagedObjectContext: managedObjectContext];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"friend_Name == %@",friendName]];
    NSError * error = nil;
    
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetch error:&error];
    
    if([fetchedObjects count])
    {
        XmppFriend *friendObject = [fetchedObjects lastObject];
        
        if (isResetCounter)
        {
            friendObject.messageCount = [NSNumber numberWithInt:0];
        }
        else
        {
            int msgCount = [friendObject.messageCount integerValue];
            friendObject.messageCount = [NSNumber numberWithInt:msgCount+1];
        }
       
        
        NSError *error;
        if (![managedObjectContext save:&error])
        {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }

}

//////////////////////////////////////////////////////////////////////////////////////////
///////////////////    Method To Remove All Friends Data   ///////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

-(void)deleteAllFriendsRecordsFromDb
{
    NSManagedObjectContext *managedObjectContext = [APPDELEGATE managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"XmppFriend" inManagedObjectContext:managedObjectContext]];
    [fetch setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * friends = [managedObjectContext executeFetchRequest:fetch error:&error];
   
    
    for (NSManagedObject * friend in friends) {
        [managedObjectContext deleteObject:friend];
    }
    NSError *saveError = nil;
    if (![managedObjectContext save:&saveError])
    {
        NSLog(@"Whoops, couldn't save: %@", [saveError localizedDescription]);
    }
   
}


//////////////////////////////////////////////////////////////////////////////////////////
///////////////////    Method To Get Friends Data From Server  ///////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

-(NSDictionary *)getFriendInformationDictFromWebservice:(NSString *)friendFbID
{
    NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];
    sessionToken = [stdDefaults objectForKey:@"userSessionToken"];
    deviceID = [stdDefaults objectForKey:@"fbID"];
    
    postUrl = [NSString stringWithFormat:@"%@%@",API_URL,METHOD_GETPROFILE];
    postMsg = [NSString stringWithFormat:@"ent_sess_token=%@&ent_dev_id=%@&ent_user_fbid=%@",sessionToken,deviceID,friendFbID];
    NSDictionary *matchedDict = [self postMethodWithMsg:postMsg URL:postUrl];
   
    return matchedDict;
}


-(NSDictionary *)postMethodWithMsg:(NSString *)postStr URL:(NSString *)postURL {
    NSData *postData = [postStr dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //    NSLog(@"%lu",(unsigned long)[postData length]);
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:postURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSData *responseData = [NSMutableData dataWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil]];
    NSDictionary *returnData;
    if (responseData != nil) {
        NSString *s = [[NSString alloc] initWithData:responseData encoding: NSASCIIStringEncoding] ;
        NSLog(@"%@",s);
        returnData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves  error:nil];
    }
    return returnData;
}


//////////////////////////////////////////////////////////////////////////////////////////
///////////////////    Method To Get Friends With Pending Msgs  //////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

-(NSArray *)getFriendsWithPendingMsgs
{
    NSManagedObjectContext *managedObjectContext = [APPDELEGATE managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"XmppFriend" inManagedObjectContext:managedObjectContext]];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"messageCount > %d",0]];
    [fetch setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * friends = [managedObjectContext executeFetchRequest:fetch error:&error];
    
    return friends;
}

#pragma mark -- block/unblock


-(void)blockFriend : (NSString *)friendName
{
    /*  <iq from='juliet@capulet.com/chamber' type='set' id='block1'>
     <block xmlns='urn:xmpp:blocking'>
     <item jid='romeo@montague.net'/>
     </block>
     </iq>*/
    
    
    
    NSString *myJID = [NSString stringWithFormat:@"%@@%@/%@",MY_USER_NAME,CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
    NSString *friendJID = [NSString stringWithFormat:@"%@@%@/%@",friendName,CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
    
    
    /// get service list
    
    
    /*    <iq from='juliet@capulet.com/chamber' to='capulet.com' type='get' id='disco1'>
     <query xmlns='http://jabber.org/protocol/disco#info'/>
     </iq>
     
     
     
     XMPPIQ *iq = [XMPPIQ iqWithType:@"get" ];
     [iq addAttributeWithName:@"id" stringValue:@"disco1"];
     [iq addAttributeWithName:@"from" stringValue:myJID];
     [iq addAttributeWithName:@"to" stringValue:CHAT_SERVER_ADDRESS];
     
     NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
     [query addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/disco#info"];
     [iq addChild:query];
     [APP_DELEGATE.xmppStream sendElement:iq];*/
    
    
    
    //get privacy list
    
    /*  <iq from='romeo@example.net/orchard' type='get' id='getlist1'>
     <query xmlns='jabber:iq:privacy'/>
     </iq>
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" ];
    [iq addAttributeWithName:@"id" stringValue:@"getlist1"];
    [iq addAttributeWithName:@"from" stringValue:myJID];
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:privacy"];
    [iq addChild:query];
    [[[XmppCommunicationHandler sharedInstance] xmppStream] sendElement:iq];*/
    
    //block user
    
    /*   XMPPIQ *iq = [XMPPIQ iqWithType:@"set" ];
     [iq addAttributeWithName:@"id" stringValue:@"blockUser"];
     [iq addAttributeWithName:@"from" stringValue:myJID];
     
     NSXMLElement *block = [NSXMLElement elementWithName:@"block"];
     [block addAttributeWithName:@"xmlns" stringValue:@"urn:xmpp:blocking"];
     
     NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
     [item addAttributeWithName:@"jid" stringValue:friendJID];
     
     [block addChild:item];
     [iq addChild:block];
     [APP_DELEGATE.xmppStream sendElement:iq];*/
    
    /*
     
     XMPPIQ *iq = [XMPPIQ iqWithType:@"set" ];
     [iq addAttributeWithName:@"id" stringValue:@"roster"];
     [iq addAttributeWithName:@"from" stringValue:myJID];
     
     NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
     [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:roster"];
     
     NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
     [item addAttributeWithName:@"jid" stringValue:friendJID];
     [item addAttributeWithName:@"subscription" stringValue:@"remove"];
     
     [query addChild:item];
     [iq addChild:query];
     [APP_DELEGATE.xmppStream sendElement:iq];*/
    
    
    
    
    NSManagedObjectContext *managedObjectContext = [APPDELEGATE managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XmppFriend"  inManagedObjectContext: managedObjectContext];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"friend_Name == %@",friendName]];
    NSError * error = nil;
    
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetch error:&error];
    
    if([fetchedObjects count])
    {
        XmppFriend *friendObject = [fetchedObjects lastObject];
        
        friendObject.isBlocked = @"YES";
        
        NSError *error;
        if (![managedObjectContext save:&error])
        {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
    
}

-(void)unBlockFriend : (NSString *)friendName
{
    NSManagedObjectContext *managedObjectContext = [APPDELEGATE managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XmppFriend"  inManagedObjectContext: managedObjectContext];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"friend_Name == %@",friendName]];
    NSError * error = nil;
    
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetch error:&error];
    
    if([fetchedObjects count])
    {
        XmppFriend *friendObject = [fetchedObjects lastObject];
        
        friendObject.isBlocked = @"NO";
        
        NSError *error;
        if (![managedObjectContext save:&error])
        {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
    
}


-(void)updateLastMessageStatusOfFriend  : (NSString *)friendName messageID : (NSString *)lastMessageID  messageStatus:(NSString *)lastMsgStatus
{
    NSManagedObjectContext *managedObjectContext = [APPDELEGATE managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XmppFriend"  inManagedObjectContext: managedObjectContext];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"(friend_Name == %@) AND (lastMessageID == %@)",friendName,lastMessageID]];
    NSError * error = nil;
    
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetch error:&error];
    
    if([fetchedObjects count])
    {
        XmppFriend *friendObject = [fetchedObjects lastObject];
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_XMPP_LAST_MESSAGE_STATUS_CHANGED object:self userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:friendObject,lastMsgStatus, nil] forKeys:[NSArray arrayWithObjects:@"friendObj",@"lastMsgStatus", nil] ]];
        
        
        friendObject.lastMessageStatus = lastMsgStatus;
        
        NSError *error;
        if (![managedObjectContext save:&error])
        {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
}


@end
