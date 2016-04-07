//
//  XmppCommunicationHandler.m
//  Karmic
//
//  Created by Sanskar on 09/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "XmppCommunicationHandler.h"
#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"

#import "DDLog.h"
#import "DDTTYLogger.h"

#import <CFNetwork/CFNetwork.h>

#import "XMPPMessageArchivingCoreDataStorage.h"
#import "XMPPMessageArchiving.h"
#import "XMPPMessageDeliveryReceipts.h"
#import "XMPPRoomMemoryStorage.h"
#import "NSData+Base64Encoding.h"

#import "XmppFriend.h"
#import "XmppFriendHandler.h"

#import "TURNSocket.h"
#import "XmppSingleChatHandler.h"


// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface XmppCommunicationHandler()

- (void)setupStream;
- (void)teardownStream;

- (void)goOnline;
- (void)goOffline;

@end

static XmppCommunicationHandler *xmppCommHandler;

@implementation XmppCommunicationHandler

//Updated By Sanskar
@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;
@synthesize friendsArray;
@synthesize allChatMessagesArray;
@synthesize allPendingMsgCountsArray;
@synthesize recentChatFriendsArray;
@synthesize arrAllCrowds,arrSelectedCroudFriendsToBeInvited,arrAllCroudChatMessages,isAutoSendCrowdRequestForFirstTime,arrAllCrowdsImages;
@synthesize arrAllEvents;
@synthesize elementsArray,isUserNameNotAlreadyExist;
@synthesize arrBlockedFriends;
@synthesize xmppMessageArchivingCoreDataStorage;
@synthesize xmppMessageArchivingModule;
@synthesize isregisteringWithExternalApp,isRegister;

+(id)sharedInstance
{
    if (!xmppCommHandler){
        xmppCommHandler = [[self alloc] init];
    }
    return xmppCommHandler;
}

-(void)initialSetup
{
    // Configure logging framework
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [self setupStream];
    
    self.currentFriendName = @"";
    self.friendsArray = [[NSMutableArray alloc] init];
    self.arrSelectedCroudFriendsToBeInvited = [[NSMutableArray alloc]init];
    self.allChatMessagesArray =[[NSMutableArray alloc]init];
    self.recentChatFriendsArray =[[NSMutableArray alloc]init];
    self.allPendingMsgCountsArray =[[NSMutableArray alloc]init];
    self.arrAllEvents = [[NSMutableArray alloc] init];
    self.arrAllCrowds = [[NSMutableArray alloc] init];
    self.arrAllCrowdsImages = [[NSMutableArray alloc] init];
    self.friendList = [[NSMutableArray alloc]init];

}

- (void) dealloc
{
    [self teardownStream];
}

#pragma mark - core data for XMPP

- (NSManagedObjectContext *)managedObjectContext_roster
{
    return [xmppRosterStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
    return [xmppCapabilitiesStorage mainThreadManagedObjectContext];
}

#pragma mark Private

- (void)setupStream
{
    NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
    
    // Setup xmpp stream
    //
    // The XMPPStream is the base class for all activity.
    // Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    
    xmppStream = [[XMPPStream alloc] init];
    
#if !TARGET_IPHONE_SIMULATOR
    {
        // Want xmpp to run in the background?
        //
        // P.S. - The simulator doesn't support backgrounding yet.
        //        When you try to set the associated property on the simulator, it simply fails.
        //        And when you background an app on the simulator,
        //        it just queues network traffic til the app is foregrounded again.
        //        We are patiently waiting for a fix from Apple.
        //        If you do enableBackgroundingOnSocket on the simulator,
        //        you will simply see an error message from the xmpp stack when it fails to set the property.
        
        xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    
    // Setup reconnect
    //
    // The XMPPReconnect module monitors for "accidental disconnections" and
    // automatically reconnects the stream for you.
    // There's a bunch more information in the XMPPReconnect header file.
    
    xmppReconnect = [[XMPPReconnect alloc] init];
    
    // Setup roster
    //
    // The XMPPRoster handles the xmpp protocol stuff related to the roster.
    // The storage for the roster is abstracted.
    // So you can use any storage mechanism you want.
    // You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
    // or setup your own using raw SQLite, or create your own storage mechanism.
    // You can do it however you like! It's your application.
    // But you do need to provide the roster with some storage facility.
    
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    //	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
    
    xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
    
    xmppRoster.autoFetchRoster = YES;
    xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    // Setup vCard support
    //
    // The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
    // The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
    
    xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    
    xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
    
    // Setup capabilities
    //
    // The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
    // Basically, when other clients broadcast their presence on the network
    // they include information about what capabilities their client supports (audio, video, file transfer, etc).
    // But as you can imagine, this list starts to get pretty big.
    // This is where the hashing stuff comes into play.
    // Most people running the same version of the same client are going to have the same list of capabilities.
    // So the protocol defines a standardized way to hash the list of capabilities.
    // Clients then broadcast the tiny hash instead of the big list.
    // The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
    // and also persistently storing the hashes so lookups aren't needed in the future.
    //
    // Similarly to the roster, the storage of the module is abstracted.
    // You are strongly encouraged to persist caps information across sessions.
    //
    // The XMPPCapabilitiesCoreDataStorage is an ideal solution.
    // It can also be shared amongst multiple streams to further reduce hash lookups.
    
    xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    // Activate xmpp modules
    
    [xmppReconnect         activate:xmppStream];
    [xmppRoster            activate:xmppStream];
    [xmppvCardTempModule   activate:xmppStream];
    [xmppvCardAvatarModule activate:xmppStream];
    [xmppCapabilities      activate:xmppStream];
    
    // Add ourself as a delegate to anything we may be interested in
    
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // Optional:
    //
    // Replace me with the proper domain and port.
    // The example below is setup for a typical google talk account.
    //
    // If you don't supply a hostName, then it will be automatically resolved using the JID (below).
    // For example, if you supply a JID like 'user@quack.com/rsrc'
    // then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
    //
    // If you don't specify a hostPort, then the default (5222) will be used.
    
    [xmppStream setHostName:CHAT_SERVER_ADDRESS];
    [xmppStream setHostPort:XMPP_HOST_PORT];
    
    
    //	// You may need to alter these settings depending on the server you're connecting to
    //	allowSelfSignedCertificates = NO;
    //	allowSSLHostNameMismatch = NO;
}

- (void)teardownStream
{
    [xmppStream removeDelegate:self];
    [xmppRoster removeDelegate:self];
    
    [xmppReconnect         deactivate];
    [xmppRoster            deactivate];
    [xmppvCardTempModule   deactivate];
    [xmppvCardAvatarModule deactivate];
    [xmppCapabilities      deactivate];
    
    [xmppStream disconnect];
    
    xmppStream = nil;
    xmppReconnect = nil;
    xmppRoster = nil;
    xmppRosterStorage = nil;
    xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
    xmppvCardAvatarModule = nil;
    xmppCapabilities = nil;
    xmppCapabilitiesStorage = nil;
}

// It's easy to create XML elments to send and to read received XML elements.
// You have the entire NSXMLElement and NSXMLNode API's.
//
// In addition to this, the NSXMLElement+XMPP category provides some very handy methods for working with XMPP.
//
// On the iPhone, Apple chose not to include the full NSXML suite.
// No problem - we use the KissXML library as a drop in replacement.
//
// For more information on working with XML elements, see the Wiki article:
// https://github.com/robbiehanson/XMPPFramework/wiki/WorkingWithElements

- (void) goOnline
{
    XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
    
    [[self xmppStream] sendElement:presence];
}

- (void) goOffline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    
    [[self xmppStream] sendElement:presence];
}

#pragma mark Connect/disconnect

- (BOOL)connect
{
    if (![xmppStream isDisconnected])
        return YES;
    
    
    
    // code by sanket nagar for recieveing msg status
    
    
    XMPPMessageDeliveryReceipts* xmppMessageDeliveryRecipts = [[XMPPMessageDeliveryReceipts alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    xmppMessageDeliveryRecipts.autoSendMessageDeliveryReceipts = YES;
    xmppMessageDeliveryRecipts.autoSendMessageDeliveryRequests = YES;
    [xmppMessageDeliveryRecipts activate:self.xmppStream];
    
    
    NSString *myJID = [NSString stringWithFormat:@"%@@%@/%@",MY_USER_NAME,CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
    
    //NSString *myJID = [NSString stringWithFormat:@"%@@%@",MY_USER_NAME,CHAT_SERVER_ADDRESS];
    password        =  MY_PASSWORD;
    
    if ([USER_DEFAULT stringForKey:kKeyUDAMNUserName] == nil)
        return NO;
    
    if (myJID == nil || password == nil)
        return NO;
    
    [xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
    
    NSError *error = nil;
    
    //my changes===
    
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting" message:@"See console for error details." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        
        DDLogError(@"Error connecting: %@", error);
        
        return NO;
    }
    //	else
    //	{
    //		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"SuccsesFully Done." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    //		[alertView show];
    //	}
    //
    return YES;
}

- (void) disconnect
{
    [self goOffline];
    [xmppStream disconnect];
}

#pragma mark - Register on XMPP
- (void) registerOnXMPPWithUsername:(NSString *) username andPassword:(NSString *)userPassword
{
    isRegister = YES;
    [USER_DEFAULT setValue:username forKey:kKeyUDAMNUserName];
    [USER_DEFAULT setValue:userPassword forKey:kKeyUDAMNPassword];
    USER_DEFAULT_SYNC;
    
    [self connect];
}

#pragma mark - Login on XMPP
- (void) loginOnXMPPWithUsername:(NSString *) username andPassword:(NSString *)userPassword
{
    isLogging = YES;
    [USER_DEFAULT setValue:username forKey:kKeyUDAMNUserName];
    [USER_DEFAULT setValue:userPassword forKey:kKeyUDAMNPassword];
    USER_DEFAULT_SYNC;
    
    [self connect];
}


-(void)registerOnXMPPWithElements:(NSString *) username Password:(NSString *)userPassword Email:(NSString *)email FBid:(NSString *)fbId
{
    isRegister = YES;
    [USER_DEFAULT setValue:username forKey:kKeyUDAMNUserName];
    [USER_DEFAULT setValue:userPassword forKey:kKeyUDAMNPassword];
    USER_DEFAULT_SYNC;
    [self connect];
    
    
    
    self.elementsArray = [NSMutableArray array];
    [elementsArray addObject:[NSXMLElement elementWithName:@"username" stringValue:username]];
    [elementsArray addObject:[NSXMLElement elementWithName:@"password" stringValue:password]];
    [elementsArray addObject:[NSXMLElement elementWithName:@"name" stringValue:fbId]];
    
    [elementsArray addObject:[NSXMLElement elementWithName:@"email" stringValue:email]];
    //[elementsArray addObject:[NSXMLElement elementWithName:@"nick" stringValue:username]];
    
    [xmppStream registerWithElements:elementsArray error:nil];
    
    
}



- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    
    /*
    //updated by sanket nagar
    if(![self.currentFriendReuestJID isEqualToString:[NSString stringWithFormat:@"%@",[presence from]]])
    {
        self.currentFriendReuestJID = [NSString stringWithFormat:@"%@",[presence from]];
        
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Friend Request from"
                              message:[NSString stringWithFormat:@"%@",[presence from]]//@"Add to friendlist"
                              delegate:self
                              cancelButtonTitle:@"Reject"
                              otherButtonTitles:@"Accept", nil];
        [alert show];
    }
    */
     [xmppRoster acceptPresenceSubscriptionRequestFrom:[presence from] andAddToRoster:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // the user clicked OK
    if (buttonIndex == 1)
    {
        [xmppRoster acceptPresenceSubscriptionRequestFrom:[XMPPJID jidWithString:alertView.message] andAddToRoster:YES];
    }
    else if (buttonIndex == 0)
    {
        [xmppRoster rejectPresenceSubscriptionRequestFrom:[XMPPJID jidWithString:alertView.message]];
    }
    
}


//Updated By Sanskar
-(void)acceptFriendRequestWithFriendName : (NSString *)friendName friendDisplayName:(NSString *)displayName friendImageUrl:(NSString *)imageUrl
{
    NSString *friendJID = [NSString stringWithFormat:@"%@@%@",friendName,CHAT_SERVER_ADDRESS];
    
    [xmppRoster acceptPresenceSubscriptionRequestFrom:[XMPPJID jidWithString:friendJID] andAddToRoster:YES];
    
    
    
    NSString *timeStamp = [UtilityClass getTimeStampWithDate:[NSDate date]];
    
    NSString *name=[[NSArray arrayWithArray:[friendJID componentsSeparatedByString: @"@"] ]objectAtIndex:0];
    
    NSData * imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
    
    NSDictionary *dictFriend = nil;
    
    if (imgData)
    {
         dictFriend = [[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:name,friendJID,displayName ,@"Available",[NSNumber numberWithInt:0],@"I m Using Tinder",timeStamp,imgData,@"NO", nil] forKeys:[NSArray arrayWithObjects:@"friendName",@"friendJid",@"friendDisplayName",@"presenceStatus",@"messageCount",@"lastMessage",@"lastMessageTime",@"friendImage",@"isBlocked",nil] ];
    }
    else
    {
        dictFriend = [[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:name,friendJID,displayName ,@"Available",[NSNumber numberWithInt:0],@"I m Using Tinder",timeStamp,@"",@"NO", nil] forKeys:[NSArray arrayWithObjects:@"friendName",@"friendJid",@"friendDisplayName",@"presenceStatus",@"messageCount",@"lastMessage",@"lastMessageTime",@"friendImage",@"isBlocked",nil] ];

    }
    
    XmppFriendHandler *friendHandler = [XmppFriendHandler sharedInstance];
    BOOL isAlreadyExistInDb;
    
    isAlreadyExistInDb = [friendHandler isFriendAlreadyExistInDatabase:name];
    
    if (!isAlreadyExistInDb)
    {
        [friendHandler insertFriendInfoInDatabase:dictFriend];
    }
    
   // [self disconnect];
   // [self connect];
}

-(void)decineFriendRequestWithFriendName : (NSString *)friendName
{
    NSString *friendJID = [NSString stringWithFormat:@"%@@%@",friendName,CHAT_SERVER_ADDRESS];
    [xmppRoster rejectPresenceSubscriptionRequestFrom:[XMPPJID jidWithString:friendJID]];
}


//by sanket for get all registered users (not working)

- (void)getAllRegisteredUsers {
    
    
    NSError *error = [[NSError alloc] init];
    NSXMLElement *query = [[NSXMLElement alloc] initWithXMLString:@"<query xmlns='http://jabber.org/protocol/disco#items' node='all users'/>"
                                                            error:&error];
    
    
    NSString *myJID = [NSString stringWithFormat:@"%@@%@/%@",MY_USER_NAME,CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
    
    NSLog(@"jiddd    is %@",[XMPPJID jidWithString:myJID]);
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get"
                                 to:[XMPPJID jidWithString:myJID]
                          elementID:[xmppStream generateUUID] child:query];
    [xmppStream sendElement:iq];
    
    
    
    
}

////by sanket for send message

-(void)sendMessage:(NSString *)recieverJID Sender:(NSString *)senderJID Message:(NSString *)mgsString MessageID:(NSString *)msgID MessageType:(NSString *)msgType
{
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:mgsString];
    
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"id" stringValue:msgID];
    [message addAttributeWithName:@"type" stringValue:msgType];//@"chat"
    [message addAttributeWithName:@"from" stringValue:senderJID];
    [message addAttributeWithName:@"to" stringValue:recieverJID];
    [message addChild:body];
    
    [xmppStream sendElement:message];
    
    //[self saveSingleChatMessage:recieverJID Message:mgsString];
    
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    NSString *msgID = [[message attributeForName:@"id"]stringValue];
    
    NSMutableDictionary *getDict;
    getDict = [NSMutableDictionary dictionaryWithDictionary:[[XmppSingleChatHandler sharedInstance] getMessageDictWithMessageId:msgID]];
    
    if ([[getDict valueForKey:@"recieverName"] isEqualToString:[[XmppCommunicationHandler sharedInstance] currentFriendName]])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_XMPP_MESSAGE_STATUS_CHANGED object:self userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:getDict,@"S", nil] forKeys:[NSArray arrayWithObjects:@"msdDict",@"status", nil] ]];
    }
    
    if (getDict)
    {
        [[XmppSingleChatHandler sharedInstance] updateMessageStatusOnDataBase:msgID MsgStatus:@"S"];
        [[XmppFriendHandler sharedInstance] updateLastMessageStatusOfFriend:[getDict valueForKey:@"recieverName"] messageID:msgID messageStatus:@"Sa"];
    }
}


////by sanket for save  message into coredata


-(void)saveSingleChatMessage:(NSString *)recieverName Sender:(NSString *)senderName Message:(NSString *)mgsString MessageID:(NSString *)msgID
{
    NSManagedObjectContext *context = [APPDELEGATE managedObjectContext];
    NSManagedObject *newContact;
    newContact = [NSEntityDescription insertNewObjectForEntityForName:@"SingleChatMessages" inManagedObjectContext:context];
    [newContact setValue:senderName  forKey:@"sender"];
    [newContact setValue:recieverName forKey:@"reciever"];
    [newContact setValue:mgsString forKey:@"message"];
    [newContact setValue:msgID forKey:@"messageID"];
    [newContact setValue:@"W" forKey:@"messageStatus"];
    NSError *error;
    [context save:&error];
}

////by sanket for save  message into coredata

-(void)saveSingleChatMessage:(NSString *)recieverName Sender:(NSString *)senderName Message:(NSString *)mgsString MessageID:(NSString *)msgID MediaType:(NSString *)mediaType
{
    NSManagedObjectContext *context = [APPDELEGATE managedObjectContext];
    NSManagedObject *newContact;
    newContact = [NSEntityDescription insertNewObjectForEntityForName:@"SingleChatMessages" inManagedObjectContext:context];
    [newContact setValue:senderName  forKey:@"sender"];
    [newContact setValue:recieverName forKey:@"reciever"];
    [newContact setValue:mgsString forKey:@"message"];
    [newContact setValue:msgID forKey:@"messageID"];
    [newContact setValue:@"W" forKey:@"messageStatus"];
    [newContact setValue:mediaType forKey:@"mediaType"];
    NSError *error;
    [context save:&error];
}


////by sanket for save group chat message

-(void)saveGroupChatMessage:(NSString *)groupName Sender:(NSString *)senderName Message:(NSString *)mgsString MessageID:(NSString *)msgID
{
    NSManagedObjectContext *context = [APPDELEGATE managedObjectContext];
    NSManagedObject *newContact;
    newContact = [NSEntityDescription insertNewObjectForEntityForName:@"GroupChatMessages" inManagedObjectContext:context];
    [newContact setValue:senderName  forKey:@"sender"];
    [newContact setValue:groupName forKey:@"groupName"];
    [newContact setValue:mgsString forKey:@"message"];
    [newContact setValue:msgID forKey:@"messageID"];
    [newContact setValue:@"Sent" forKey:@"messageStatus"];
    [newContact setValue:MY_USER_NAME forKey:@"userName"];
    //[newContact setValue:@"Sent" forKey:@"messageStatus"];
    NSError *error;
    [context save:&error];
}


////by sanket for Loading all crouwd chat messages

-(void)loadAllCroudChatMesssages
{
    arrAllCroudChatMessages = [[NSMutableArray alloc]init];
    NSManagedObjectContext *context = [APPDELEGATE managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"GroupChatMessages" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDesc];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(userName == %@)",MY_USER_NAME ];
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
        
        for (int i=0;i<[objects count];i++)
        {
            matches = objects[i];
            NSMutableDictionary *dictMsgObj = [[NSMutableDictionary alloc]init];
            [dictMsgObj setObject:[matches valueForKey:@"sender"] forKey:@"senderName"];
            [dictMsgObj setObject:[matches valueForKey:@"groupName"] forKey:@"crowdName"];
            [dictMsgObj setObject:[matches valueForKey:@"message"] forKey:@"msg"];
            if([matches valueForKey:@"messageID"] != nil)
            {
                [dictMsgObj setObject:[matches valueForKey:@"messageID"] forKey:@"msgID"];
            }
            else
            {
                [dictMsgObj setObject:@"" forKey:@"msgID"];
            }
            
            [dictMsgObj setObject:[matches valueForKey:@"messageStatus"] forKey:@"msgStatus"];
            [arrAllCroudChatMessages addObject:dictMsgObj];
        }
        
    }
}


-(void)testMessageArchiving
{
    XMPPMessageArchivingCoreDataStorage *storage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    NSManagedObjectContext *moc = [storage mainThreadManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
                                                         inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDescription];
    NSError *error;
    NSArray *messages = [moc executeFetchRequest:request error:&error];
    
    // [self print:[[NSMutableArray alloc]initWithArray:messages]];
}


/*-(void)print:(NSMutableArray*)messages{
 @autoreleasepool {
 for (XMPPMessageArchiving_Message_CoreDataObject *message in messages) {
 NSLog(@"messageStr param is %@",message.messageStr);
 NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message.messageStr error:nil];
 
 
 
 
 NSString *senderName = [NSString stringWithString:[[NSArray arrayWithArray:[[[element attributeForName:@"from"] stringValue] componentsSeparatedByString: @"@"] ]objectAtIndex:0]];
 
 NSString *recieverName = [NSString stringWithString:[[NSArray arrayWithArray:[[[element attributeForName:@"to"] stringValue] componentsSeparatedByString: @"@"] ]objectAtIndex:0]];
 
 NSString *mgsString = message.body;
 
 NSMutableDictionary *dictMsgObj = [[NSMutableDictionary alloc]initWithObjects:[NSMutableArray arrayWithObjects:senderName,recieverName,mgsString , nil] forKeys:[NSMutableArray arrayWithObjects:@"senderName",@"recieverName",@"msg", nil] ];
 
 //[allChatMessagesArray addObject:dictMsgObj];
 }
 }
 }*/


////by sanket for checking that recieved message is for getting message status

-(BOOL)isMessageForGettingMessageStatus:(NSString *)messageID
{
    NSMutableDictionary *getDict;
    BOOL isExist = NO;
    
    for (int i=0; i<[allChatMessagesArray count]; i++)
    {
        getDict = [NSMutableDictionary dictionaryWithDictionary:[self.allChatMessagesArray objectAtIndex:i]];
        
        if([[getDict objectForKey:@"msgID"] isEqualToString:messageID])
        {
            [self updateMessageStatusOnDataBase:messageID];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_XMPP_MESSAGE_STATUS_CHANGED object:self userInfo:getDict];
            [getDict setObject:@"Sent" forKey:@"msgStatus"];
            [allChatMessagesArray replaceObjectAtIndex:i withObject:getDict];
            
            isExist = YES;
            break;
        }
    }
    
    
    
    return isExist;
}


////by sanket for updating status of sent message

-(void)updateMessageStatusOnDataBase:(NSString *)msgID
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
            [object setValue:@"Sent" forKey:@"messageStatus"];
            [context save:&error];
        }
    }
}

////by sanket for recieve message

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    //checking for message is single chat message
    if ([message isComposingChatMessage])
    {
        XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from] xmppStream:xmppStream managedObjectContext:[self managedObjectContext_roster]];
        
        NSString *msgID = [[message attributeForName:@"id"]stringValue];
        NSString *body = [[message elementForName:@"body"] stringValue];
        NSString *displayName = [[[user displayName] componentsSeparatedByString:@"@"] objectAtIndex:0];
        
        if([displayName isEqualToString:self.currentFriendName])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_XMPP_MESSAGE_RECEIVE_TYPING_STATUS object:self userInfo:[NSDictionary dictionaryWithObject:body forKey:@"typingStatus"]];
        }
    }
    else if ([message isChatMessageWithBody])
    {
//        [[XmppSingleChatHandler sharedInstance] extractSingleChatMessage:message];
        
        XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from] xmppStream:xmppStream managedObjectContext:[self managedObjectContext_roster]];
          NSString *displayName2 = [[[user displayName] componentsSeparatedByString:@"@"] objectAtIndex:0];
       

        [[XmppSingleChatHandler sharedInstance] extractSingleChatMessage:message :displayName2];

    }
}

//by sanket for save an event in all events

-(void)saveNewEventObjIntoAllInvitaions:(NSDictionary *)dictMsg
{
    //arrAllEvents = [[NSMutableArray alloc]init];
    
    NSArray *splitArr =[[dictMsg objectForKey:@"invitationMsg"] componentsSeparatedByString:@"friendlist:"];
    NSArray *tempArr = [[splitArr objectAtIndex:0] componentsSeparatedByString:@"##"];
    
    NSMutableArray *frndsNameArr = [[NSMutableArray alloc] init];
    NSMutableArray *eventFriends = [[NSMutableArray alloc]init];
    
    if([splitArr count]>0)
    {
        frndsNameArr= [NSMutableArray arrayWithArray:[[splitArr objectAtIndex:1] componentsSeparatedByString:@"##"]] ;
    }
    
    
    for (int i=0; i<[frndsNameArr count ]; i++)
    {
        if([frndsNameArr objectAtIndex:i] != nil && ![[frndsNameArr objectAtIndex:i] isEqualToString:@""])
        {
            [eventFriends addObject:[frndsNameArr objectAtIndex:i]];
        }
    }
    NSMutableDictionary *newDict = [[NSMutableDictionary alloc]init];
    
    [newDict setObject:[dictMsg objectForKey:@"eventName"] forKey:@"eventName"];
    [newDict setObject:[dictMsg objectForKey:@"invitationMsg"] forKey:@"invitationMsg"];
    [newDict setObject:eventFriends forKey:@"eventFriends"];
    
    if([tempArr objectAtIndex:0])
    {
        [newDict setObject:[tempArr objectAtIndex:0] forKey:@"title"];
    }
    else
    {
        [newDict setObject:@"" forKey:@"title"];
    }
    
    if([tempArr objectAtIndex:1])
    {
        [newDict setObject:[tempArr objectAtIndex:1] forKey:@"msg"];
    }
    else
    {
        [newDict setObject:@"" forKey:@"msg"];
    }
    
    if([tempArr objectAtIndex:2])
    {
        [newDict setObject:[tempArr objectAtIndex:2] forKey:@"vanue"];
    }
    else
    {
        [newDict setObject:@"" forKey:@"vanue"];
    }
    
    if([tempArr objectAtIndex:3])
    {
        [newDict setObject:[tempArr objectAtIndex:3] forKey:@"time"];
    }
    else
    {
        [newDict setObject:@"" forKey:@"time"];
    }
    
    if([tempArr objectAtIndex:4])
    {
        [newDict setObject:[tempArr objectAtIndex:4] forKey:@"invited"];
    }
    else
    {
        [newDict setObject:@"" forKey:@"invited"];
    }
    
    if([tempArr objectAtIndex:5])
    {
        [newDict setObject:[tempArr objectAtIndex:5] forKey:@"invitorName"];
    }
    else
    {
        [newDict setObject:@"" forKey:@"invitorName"];
    }
    //[newDict setObject:@"" forKey:@"sendMsgBody"];
    
    [newDict setObject:MY_USER_NAME forKey:@"userName"];
    
    [arrAllEvents addObject:newDict];
    
    NSMutableArray *arrTempEvents = [[NSMutableArray alloc]init];
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"allEvents"])
    {
        arrTempEvents =[NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"allEvents"]];
    }
    
    [arrTempEvents addObject:newDict];
    
    [[NSUserDefaults standardUserDefaults]setObject:arrTempEvents forKey:@"allEvents"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    // [[NSNotificationCenter defaultCenter] postNotificationName:@"eventS" object:self userInfo:nil];
    
}


//checking for Event is already exist or not

-(BOOL)isEventAlreadyExistWithName:(NSString *)evenName UserName:(NSString *)userName
{
    NSMutableDictionary *getFrndObj;
    BOOL isExist = NO;
    
    //    arrAllEvents = [[NSMutableArray alloc]init];
    //
    //    if([[NSUserDefaults standardUserDefaults]objectForKey:@"allEvents"])
    //    {
    //        arrAllEvents =[[NSUserDefaults standardUserDefaults]objectForKey:@"allEvents"];
    //    }
    
    
    for(int i=0; i<[self.arrAllEvents count]; i++)
    {
        getFrndObj = [self.arrAllEvents objectAtIndex:i];
        
        
        
        if([[getFrndObj valueForKey:@"eventName"] isEqualToString:evenName] )
        {
            if (userName != nil)
            {
                if ([[getFrndObj valueForKey:@"userName"] isEqualToString:userName])
                {
                    isExist = YES;
                    break;
                    
                }
            }
            else
            {
                isExist = YES;
                break;
            }
            
        }
    }
    
    
    if(isExist)
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
}


//by sanket for checking that crowd is already exist or not

-(BOOL)isCrowdAlreadyExist:(NSString *)crowdName
{
    NSMutableDictionary *getFrndObj;
    BOOL isExist = NO;
    
    for(int i=0; i<[self.arrAllCrowds count]; i++)
    {
        getFrndObj = [self.arrAllCrowds objectAtIndex:i];
        
        if([[getFrndObj valueForKey:@"crowdName"] isEqualToString:crowdName])
        {
            isExist = YES;
            break;
        }
    }
    
    
    if(isExist)
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
}

#pragma mark---
#pragma  mark - blocking/unclocking


-(void)loadAllBlockedFriends
{
    self.arrBlockedFriends= [[NSMutableArray alloc]init];
    
    if( [[NSUserDefaults standardUserDefaults]objectForKey:@"allBlockedFriends"])
    {
        self.arrBlockedFriends =[NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"allBlockedFriends"] ];
    }
    
    if([arrBlockedFriends containsObject:MY_USER_NAME])
    {
        [arrBlockedFriends removeObject:MY_USER_NAME];
    }
    
}


-(void)addFriendInBlockedUserList:(NSString *)friendName
{
    arrBlockedFriends = [[NSMutableArray alloc] init];
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"allBlockedFriends"])
    {
        arrBlockedFriends =[NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"allBlockedFriends"] ];
    }
    
    if([arrBlockedFriends containsObject:MY_USER_NAME])
    {
        [arrBlockedFriends removeObject:MY_USER_NAME];
    }
    
    if(![arrBlockedFriends containsObject:friendName])
    {
        
        [arrBlockedFriends addObject:friendName];
        [[NSUserDefaults standardUserDefaults]setObject:arrBlockedFriends forKey:@"allBlockedFriends"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
}

-(void)removeFriendFromBlockedUserList:(NSString *)friendName
{
    arrBlockedFriends = [[NSMutableArray alloc] init];
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"allBlockedFriends"])
    {
        arrBlockedFriends =[NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"allBlockedFriends"] ];
    }
    
    if([arrBlockedFriends containsObject:MY_USER_NAME])
    {
        [arrBlockedFriends removeObject:MY_USER_NAME];
    }
    
    if([arrBlockedFriends containsObject:friendName])
    {
        
        [arrBlockedFriends removeObject:[NSString stringWithString:friendName]];
    }
    [[NSUserDefaults standardUserDefaults]setObject:arrBlockedFriends forKey:@"allBlockedFriends"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
}

-(BOOL)isFriendBlocked:(NSString *)friendName
{
    arrBlockedFriends = [[NSMutableArray alloc] init];
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"allBlockedFriends"])
    {
        arrBlockedFriends =[[NSUserDefaults standardUserDefaults]objectForKey:@"allBlockedFriends"];
    }
    
    if([arrBlockedFriends containsObject:friendName])
    {
        return YES;
    }
    return NO;
}


- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(NSXMLElement *)item
{
    
}


#pragma mark -- xmpp stream -- didReceiveIQ delegate

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    
    if ([TURNSocket isNewStartTURNRequest:iq])
    {
        NSLog(@"IS NEW TURN request..");
        TURNSocket *turnSocket = [[TURNSocket alloc] initWithStream:[self xmppStream] incomingTURNRequest:iq];
        [turnSockets addObject:turnSocket];
        [turnSocket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }

    
    NSString *xmppIqID = [[iq attributeForName:@"id"] stringValue];
    
/*
       //////for getting all friends of a users
    {
        
        
        {
            NSXMLElement *queryElement =[iq elementForName: @"query" xmlns: @"jabber:iq:roster"];
            
            if (queryElement)
            {
                NSArray *itemElements = [queryElement elementsForName: @"item"];
                // self.friendsArray = [[NSMutableArray alloc] init];
                
                
                if([itemElements count] >0)
                {
                    
                    //for getting friendssssssss
                    for (int i=0; i<[itemElements count]; i++)
                    {
                        NSString *jid=[[[itemElements objectAtIndex:i] attributeForName:@"jid"] stringValue];
                        NSString *name=[[[itemElements objectAtIndex:i] attributeForName:@"name"] stringValue];
                        
                        NSString *subscription=[[[itemElements objectAtIndex:i] attributeForName:@"subscription"] stringValue];
                        
                       // NSString *ask = [[[itemElements objectAtIndex:i] attributeForName:@"ask"] stringValue];
                        
                        if([subscription isEqualToString:@"none"])
                        {
                            // friend request canceled
                            
                            // break ;
                        }
                        else if ([subscription isEqualToString:@"both"])
                        {
                            if([name isEqualToString:@""] || name == nil)
                            {
                                name=[[NSArray arrayWithArray:[jid componentsSeparatedByString: @"@"] ]objectAtIndex:0];
                            }
                            
                            NSString *timeStamp = [UtilityClass getTimeStampWithDate:[NSDate date]];
                            
                            NSString *fbId = [[name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]]lastObject];
                            NSDictionary *matchedDict = [[XmppFriendHandler sharedInstance]getFriendInformationDictFromWebservice:fbId];

                            NSString *matchname = [matchedDict objectForKey:@"firstName"];
                            NSString *matchProfilePic = nil;
                            
                            if ([[matchedDict objectForKey:@"images"] count]>0)
                            {
                                  matchProfilePic = [[matchedDict objectForKey:@"images"] objectAtIndex:0];
                            }
                          
                            NSData * imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:matchProfilePic]];
                            
                            NSDictionary *dictFriend = nil;
                            if (imgData)
                            {
                                dictFriend = [[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:name,jid,(matchname)?matchname:name ,@"unvailable",[NSNumber numberWithInt:0],@"I m Using Tinder",timeStamp,imgData,@"NO", nil] forKeys:[NSArray arrayWithObjects:@"friendName",@"friendJid",@"friendDisplayName",@"presenceStatus",@"messageCount",@"lastMessage",@"lastMessageTime",@"friendImage",@"isBlocked",nil] ];
                            }
                            else
                            {
                                NSData *imgEmpty = [NSData dataFromBase64String:@""];
                                
                                dictFriend = [[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:name,jid,(matchname)?matchname:name ,@"unvailable",[NSNumber numberWithInt:0],@"I m Using Tinder",timeStamp,imgEmpty,@"NO", nil] forKeys:[NSArray arrayWithObjects:@"friendName",@"friendJid",@"friendDisplayName",@"presenceStatus",@"messageCount",@"lastMessage",@"lastMessageTime",@"friendImage",@"isBlocked",nil] ];
                            }
                            
                          
                            XmppFriendHandler *friendHandler = [XmppFriendHandler sharedInstance];
                            BOOL isAlreadyExistInDb;
                            
                            isAlreadyExistInDb = [friendHandler isFriendAlreadyExistInDatabase:name];
                            
                            if (!isAlreadyExistInDb)
                            {
                                [friendHandler insertFriendInfoInDatabase:dictFriend];
                            }
                            else
                            {
                                [friendHandler updateFriendInfoInDatabase:dictFriend];
                            }
                            
                        }

                }
               
                }
                
                // [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_XMPP_FRIENDS_PRESENCE_UPDATE object:nil  ];
            }
            
        }}*/
    return YES;
}

//by sanket for check that a friend is already exist in friendlist or not


-(BOOL)isFriendAlreadyExistInFriendList:(NSString *)friendName
{
    NSMutableDictionary *getFrndObj;
    BOOL isExist = NO;
    
    
    if(friendName != nil)
    {
        for(int i=0; i<[self.friendsArray count]; i++)
        {
            getFrndObj = [self.friendsArray objectAtIndex:i];
            
            if([[getFrndObj valueForKey:@"friendName"] isEqualToString:friendName])
            {
                isExist = YES;
                break;
            }
        }
        
    }
    
    return isExist;
}



//by sanket for save vcard data for friend

-(void)saveVcardDataForFriend:(NSString *)friendName  VCard:(NSXMLElement *)iq
{
    
    
    NSMutableDictionary *getFrndObj;
    if([MY_USER_NAME isEqualToString:friendName])
    {
        
        NSMutableDictionary *dictUserInfo = [[NSMutableDictionary alloc]init];
        
        if ([[NSUserDefaults standardUserDefaults]valueForKey:@"userInfo"])
        {
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"userInfo"];
            // dictUserInfo =[[NSUserDefaults standardUserDefaults]valueForKey:@"userInfo"];
            
        }
        
        XMPPElement *vCardPhotoElement = (XMPPElement *)[[iq elementForName:@"vCard"] elementForName:@"PHOTO"];
        
        NSString *displayName =[[[iq elementForName:@"vCard"] elementForName:@"DISPLAY_NAME"] stringValue];
        NSString *Dob =[[[iq elementForName:@"vCard"] elementForName:@"BDAY"] stringValue];
        NSString *gender =[[[iq elementForName:@"vCard"] elementForName:@"GENDER"] stringValue];
        NSString *interest =[[[iq elementForName:@"vCard"] elementForName:@"INTEREST"] stringValue];
        NSString *emailID =[[[iq elementForName:@"vCard"] elementForName:@"EMAIL"] stringValue];
        NSString *status =[[[iq elementForName:@"vCard"] elementForName:@"STATUS"] stringValue];
        
        
        if (vCardPhotoElement != nil)
        {
            // avatar data
            NSString *base64DataString = [vCardPhotoElement  stringValue];
            
            
            [dictUserInfo setObject:base64DataString forKey:@"myImage"];
            [dictUserInfo setObject:MY_USER_NAME forKey:@"myName"];
            
        }
        
        if(displayName)
        {
            [dictUserInfo setObject:displayName forKey:@"myDisplayName"];
        }
        else
        {
            [dictUserInfo setObject:@"" forKey:@"myName"];
        }
        
        if(Dob)
        {
            [dictUserInfo setObject:Dob forKey:@"myDOB"];
        }
        else
        {
            [dictUserInfo setObject:@"" forKey:@"myDOB"];
        }
        
        if(gender)
        {
            [dictUserInfo setObject:gender forKey:@"myGender"];
        }
        else
        {
            [dictUserInfo setObject:@"" forKey:@"myGender"];
        }
        
        if(interest)
        {
            [dictUserInfo setObject:interest forKey:@"myInterest"];
        }
        else
        {
            [dictUserInfo setObject:@"" forKey:@"myInterest"];
        }
        
        if(emailID)
        {
            [dictUserInfo setObject:emailID forKey:@"myEmail"];
        }
        else
        {
            [dictUserInfo setObject:@"" forKey:@"myEmail"];
        }
        
        if(status)
        {
            [dictUserInfo setObject:status forKey:@"myStatus"];
        }
        else
        {
            [dictUserInfo setObject:@"" forKey:@"myStatus"];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:dictUserInfo forKey:@"userInfo"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        BOOL isExist = NO;
        int POS = -1;
        
        
        if(friendName != nil)
        {
            for(int i=0; i<[self.friendsArray count]; i++)
            {
                getFrndObj = [NSMutableDictionary dictionaryWithDictionary:[friendsArray objectAtIndex:i]];
                
                if([[getFrndObj valueForKey:@"friendName"] isEqualToString:friendName])
                {
                    isExist = YES;
                    POS = i;
                    break;
                }
            }
            
        }
        
        if(isExist)
        {
            XMPPElement *vCardPhotoElement = (XMPPElement *)[[iq elementForName:@"vCard"] elementForName:@"PHOTO"];
            NSString *displayName =[[[iq elementForName:@"vCard"] elementForName:@"DISPLAY_NAME"] stringValue];
            NSString *Dob =[[[iq elementForName:@"vCard"] elementForName:@"BDAY"] stringValue];
            NSString *gender =[[[iq elementForName:@"vCard"] elementForName:@"GENDER"] stringValue];
            NSString *interest =[[[iq elementForName:@"vCard"] elementForName:@"INTEREST"] stringValue];
            NSString *emailID =[[[iq elementForName:@"vCard"] elementForName:@"EMAIL"] stringValue];
            NSString *status =[[[iq elementForName:@"vCard"] elementForName:@"STATUS"] stringValue];
            
            if (vCardPhotoElement != nil) {
                // avatar data
                NSString *base64DataString = [vCardPhotoElement stringValue];//[[vCardPhotoElement
                // elementForName:@"BINVAL"] stringValue];
                
                if(base64DataString)
                {
                    [getFrndObj setObject:base64DataString forKey:@"friendImage"];
                }
                
                
                
                if(displayName)
                {
                    [getFrndObj setObject:emailID forKey:@"friendDisplayName"];
                }
                
                if(emailID)
                {
                    [getFrndObj setObject:emailID forKey:@"friendEmailId"];
                }
                if(Dob)
                {
                    [getFrndObj setObject:Dob forKey:@"friendDOB"];
                }
                if(gender)
                {
                    [getFrndObj setObject:gender forKey:@"friendGender"];
                }
                if(interest)
                {
                    [getFrndObj setObject:emailID forKey:@"friendInterest"];
                }
                if(status)
                {
                    [getFrndObj setObject:emailID forKey:@"friendStatus"];
                }
                
                [friendsArray replaceObjectAtIndex:POS withObject:getFrndObj];
                
            }
        }
    }
}

//by sanket for loading all recent chat list

-(void)loadAllRecentChatList
{
    self.recentChatFriendsArray= [[NSMutableArray alloc]init];
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"recentChatFriendsArr"])
    {
        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"recentChatFriendsArr"]];
        
        NSMutableDictionary *getFrndObj;
        
        for (int i=0; i<[tempArr count]; i++)
        {
            getFrndObj = [tempArr objectAtIndex:i];
            
            if([[getFrndObj valueForKey:@"userName"] isEqualToString:MY_USER_NAME])
            {
                [self.recentChatFriendsArray addObject:getFrndObj];
            }
        }
        
    }
    
}


//by sanket for Loading all pending messages

-(void)loadAllPendingMessages
{
    self.allPendingMsgCountsArray = [[NSMutableArray alloc]init];
    
    if( [[NSUserDefaults standardUserDefaults]objectForKey:@"allPendingMsgsCount"])
    {
        
        //NSLog(@"array descrrrr %@",[[NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"allPendingMsgsCount"]]description]);
        
        self.allPendingMsgCountsArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"allPendingMsgsCount"]];
    }
}

//by sanket for Loading all crowds

-(void)loadAllCroudsImages
{
    
    if( [[NSUserDefaults standardUserDefaults]objectForKey:@"AllCrowdsImages"])
    {
        self.arrAllCrowdsImages = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"AllCrowdsImages"]];
        
    }
    
}

//by sanket for add new crowd into all crowds array

-(void)addNewCroudIntoAllCroudArr:(NSString *)croudName  CroudDict:(NSDictionary *)newCroudObj
{
    if(newCroudObj != nil)
    {
        NSMutableDictionary *getFrndObj;
        BOOL isExist = NO;
        
        for(int i=0; i<[self.arrAllCrowds count]; i++)
        {
            getFrndObj = [self.arrAllCrowds objectAtIndex:i];
            
            if([[getFrndObj valueForKey:@"crowdName"] isEqualToString:croudName])
            {
                isExist = YES;
                break;
            }
        }
        
        if(!isExist)
        {
            [arrAllCrowds addObject:newCroudObj];
            
            [self createCrowdWithCrowdName:croudName];
            
            [self saveCrowdImageForCrowdName:croudName CrowdImage:nil];
            // [[NSUserDefaults standardUserDefaults]setObject:arrAllCrowds forKey:@"AllCrouds"];
            //[[NSUserDefaults standardUserDefaults]synchronize];
            // [[NSNotificationCenter defaultCenter] postNotificationName:@"recieveMessage" object:nil];
        }
    }
}




//By sanket nagar for saving crowdimage

-(void)saveCrowdImageForCrowdName:(NSString *)crowdName CrowdImage:(NSData *)imageData
{
    
    NSMutableDictionary *getCrowdObj;
    BOOL isExist = NO;
    
    if([self.arrAllCrowdsImages count] >0)
    {
        for (int i=0; i<[self.arrAllCrowdsImages count]; i++)
        {
            getCrowdObj = [self.arrAllCrowdsImages objectAtIndex:i];
            
            if([[getCrowdObj valueForKey:@"crowdName"] isEqualToString:crowdName] )
            {
                isExist = YES;
                break;
            }
            
        }
    }
    
    
    
    if (!isExist)
    {
        
        if(!imageData)
        {
            imageData = [self getImageDataForCrowdName:crowdName];
            
        }
        
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        
        [dict setObject:crowdName forKey:@"crowdName"];
        
        if(imageData)
        {
            [dict setObject:imageData forKey:@"crowdImage"];
        }
        else
        {
            [dict setObject:nil forKey:@"crowdImage"];
        }
        
        [arrAllCrowdsImages addObject:dict];
        
        [[NSUserDefaults standardUserDefaults]setObject:arrAllCrowdsImages forKey:@"AllCrowdsImages"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
    }
}


//By sanket nagar for getting crowdimage

-(UIImage *)getImageForCrowdName:(NSString *)crowdName
{
    
    NSMutableDictionary *getCrowdObj;
    BOOL isExist = NO;
    
    if(crowdName != nil)
    {
        
        for(int i=0; i<[self.arrAllCrowdsImages count]; i++)
        {
            getCrowdObj = [self.arrAllCrowdsImages objectAtIndex:i];
            
            if([[getCrowdObj valueForKey:@"crowdName"] isEqualToString:crowdName])
            {
                isExist = YES;
                break;
            }
        }
        
        if(isExist)
        {
            NSData *imgData = [getCrowdObj valueForKey:@"crowdImage"] ;
            if(imgData)
            {
                
                UIImage *img =   [UIImage imageWithData:imgData];
                
                return img;
            }
            
        }
    }
    return nil;
}

//by sanket for Loading all Events

-(void)loadAllEvents
{
    self.arrAllEvents = [[NSMutableArray alloc]init];
    
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"allEvents"])
    {
        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"allEvents"]];
        
        NSMutableDictionary *getFrndObj;
        
        for (int i=0; i<[tempArr count]; i++)
        {
            getFrndObj = [tempArr objectAtIndex:i];
            
            if([[getFrndObj valueForKey:@"userName"] isEqualToString:MY_USER_NAME])
            {
                [self.arrAllEvents addObject:getFrndObj];
            }
        }
        
    }
    
    
}

//by sanket for adding friend in recent chat message array

-(void)addFriendObjInRecentChatArray:(NSString *)friendName FriendObj:(NSObject *)friendObj
{
    if(friendObj != nil)
    {
        NSObject *getFrndObj;
        BOOL isExist = NO;
        for(int i=0; i<[self.recentChatFriendsArray count]; i++)
        {
            getFrndObj = [self.recentChatFriendsArray objectAtIndex:i];
            
            if([[getFrndObj valueForKey:@"friendName"] isEqualToString:friendName])
            {
                isExist = YES;
                break;
            }
        }
        
        if(!isExist)
        {
            [recentChatFriendsArray addObject:friendObj];
            [[NSUserDefaults standardUserDefaults]setObject:recentChatFriendsArray forKey:@"recentChatFriendsArr"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"recieveMessage" object:nil];
        }
    }
}

//by sanket for sending friendrequest

-(void)SendFriendRequestWithFriendName:(NSString *)friendName
{
    
    //friendName = @"aa22";
    
    NSString *friendId = [NSString stringWithFormat:@"%@@%@/%@",friendName,CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
    
    XMPPJID *newBuddy = [XMPPJID jidWithString:friendId];
    
    [xmppRoster addUser:newBuddy withNickname:friendName];
    
}

/*
 - (void)xmppStream:(XMPPStream *)sender socketWillConnect:(GCDAsyncSocket *)socket
 {
 // XMPPStream is preparing to connect.
 // Add the voip flag to the socket.
 
 CFReadStreamSetProperty([socket getCFReadStream], kCFStreamNetworkServiceType, kCFStreamNetworkServiceTypeVoIP);
 CFWriteStreamSetProperty([socket getCFWriteStream], kCFStreamNetworkServiceType, kCFStreamNetworkServiceTypeVoIP);
 }
*/

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    /**
     if (allowSelfSignedCertificates)
     {
     [settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
     }
     
     if (allowSSLHostNameMismatch)
     {
     [settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
     }
     else
     {
     // Google does things incorrectly (does not conform to RFC).
     // Because so many people ask questions about this (assume xmpp framework is broken),
     // I've explicitly added code that shows how other xmpp clients "do the right thing"
     // when connecting to a google server (gmail, or google apps for domains).
     
     NSString *expectedCertName = nil;
     
     NSString *serverDomain = xmppStream.hostName;
     NSString *virtualDomain = [xmppStream.myJID domain];
     
     if ([serverDomain isEqualToString:@"talk.google.com"])
     {
     if ([virtualDomain isEqualToString:@"gmail.com"])
     {
     expectedCertName = virtualDomain;
     }
     else
     {
     expectedCertName = serverDomain;
     }
     }
     else if (serverDomain == nil)
     {
     expectedCertName = virtualDomain;
     }
     else
     {
     expectedCertName = serverDomain;
     }
     
     if (expectedCertName)
     {
     [settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
     }
     }
     */
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}


#pragma mark -- stream did connect

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if (_XMPPDelegate && [_XMPPDelegate respondsToSelector:@selector(XMPPDidConnect:)])
    {
         [_XMPPDelegate XMPPDidConnect:sender];
    }
   
    
    //NSLog(@"the password %@",MY_PASSWORD);
    //NSError *error = nil;
    
    
    if (isRegister)
    {
        isRegister = NO;
        NSError *error = nil;
        
        self.elementsArray = [[NSMutableArray alloc] init];
        [elementsArray addObject:[NSXMLElement elementWithName:@"username" stringValue:MY_USER_NAME]];
        [elementsArray addObject:[NSXMLElement elementWithName:@"password" stringValue:MY_PASSWORD]];
        [[self xmppStream] registerWithElements:self.elementsArray error:&error];
    }
    
    if (isLogging)
    {
        isLogging = NO;
        NSError *error = nil;
        [[self xmppStream] authenticateWithPassword:MY_PASSWORD error:&error];
    }
    
    
   /* if (![[self xmppStream] authenticateWithPassword:MY_PASSWORD error:&error])
    {
        DDLogError(@"Error authenticating: %@", error);
    }*/
    
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    //[self sendPresence];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"RemoveHood" object:nil];
    NSLog(@"error ********is %@",[error description]);
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
     if (_XMPPDelegate && [_XMPPDelegate respondsToSelector:@selector(XMPPDidAuthenticate:)])
     {
        [_XMPPDelegate XMPPDidAuthenticate:sender];
     }
  
    [self goOnline];
    
     if (_XMPPDelegate && [_XMPPDelegate respondsToSelector:@selector(XMPPDidLogin:)])
     {
        [_XMPPDelegate XMPPDidLogin:sender];
     }
    
  ///  [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_XMPP_STREAM_CONNECTED object:nil];
    [[XmppSingleChatHandler sharedInstance] sendOfflineMessages];

}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    if (_XMPPDelegate && [_XMPPDelegate respondsToSelector:@selector(XMPPDidNotAuthenticate:)])
    {
        [_XMPPDelegate XMPPDidNotAuthenticate:sender];
    }
   
}


- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    NSError *error = nil;
    if (![[self xmppStream] authenticateWithPassword:MY_PASSWORD error:&error])
    {
        DDLogError(@"Error authenticating: %@", error);
    }
    
    //[_XMPPDelegate XMPPDidRegistered:sender];
}


- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error{
    
    DDXMLElement *errorXML = [error elementForName:@"error"];
     NSString *errorCode  = [[errorXML attributeForName:@"code"] stringValue];
    
    if ([errorCode isEqualToString:@"409"])
    {
        NSError *error = nil;
        [[self xmppStream] authenticateWithPassword:MY_PASSWORD error:&error];
    }
    else
    {
        NSString *regError = [NSString stringWithFormat:@"ERROR :- %@",error.description];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration Failed!" message:regError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
   
    }
    
    //    NSLog(@"is registering with external app %hhd",isregisteringWithExternalApp);
    //    NSLog(@"my username =%@ and password = %@",MY_USER_NAME,MY_PASSWORD);
    //
    //    if(isregisteringWithExternalApp)
    //    {
    //        NSLog(@"the password %@",MY_PASSWORD);
    //        NSError *error = nil;
    //
    //
    //        if (![[self xmppStream] authenticateWithPassword:MY_PASSWORD error:&error])
    //        {
    //            DDLogError(@"Error authenticating: %@", error);
    //        }
    //
    //    }
    
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
    
    NSXMLElement *queryElement =[presence elementForName: @"status" xmlns:@"jabber:client"];
    
    if([[[presence attributeForName:@"from"] stringValue] rangeOfString:@"conference"].location == NSNotFound)
    {
        NSString *from = [[NSArray arrayWithArray:[[[presence attributeForName:@"from"]stringValue] componentsSeparatedByString: @"@"] ]objectAtIndex:0];
        NSString *status = [queryElement stringValue];
        
        if(status == nil)
        {
            status = [[presence attributeForName:@"type"]stringValue];
        }
        
        if(![status isEqualToString:@""] && status != nil && [status isEqualToString:@"unavailable"])
        {
            [[XmppFriendHandler sharedInstance] updatePresenceStatusOfFriend:from andStatus:@"Offline"];
        }
        else
        {
            [[XmppFriendHandler sharedInstance] updatePresenceStatusOfFriend:from andStatus:@"Online"];
        }
        
    }
}

/*- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
 
    NSXMLElement *queryElement =[presence elementForName: @"status" xmlns:@"jabber:client"];
    
    
    if([[[presence attributeForName:@"from"] stringValue] rangeOfString:@"conference"].location == NSNotFound)
    {
        
        // presence for single chat users
        
 
        {
            NSString *from = [[NSArray arrayWithArray:[[[presence attributeForName:@"from"]stringValue] componentsSeparatedByString: @"@"] ]objectAtIndex:0];
            NSString *status = [queryElement stringValue];
            
            if(status == nil)
            {
                status = [[presence attributeForName:@"type"]stringValue];
            }
      
            if(![status isEqualToString:@""] && status != nil && [status isEqualToString:@"unavailable"])
            {
                [self updatePresenceStatusOfFriends:from PRESENCE:status];
                
            }
            else
            {
                //NSXMLElement *queryElement1 =[presence elementForName: @"c" xmlns:@"jabber:client"];
                [self updatePresenceStatusOfFriends:from PRESENCE:@"Available"];
            }
            
            if ([status isEqualToString:@"subscribed"])
            {
                XmppFriendHandler *friendHandler = [XmppFriendHandler sharedInstance];
                BOOL isAlreadyExistInDb;
                NSString *friendName = from;
                NSString *presenceStatus = @"Available";
                
                isAlreadyExistInDb = [friendHandler isFriendAlreadyExistInDatabase:friendName];
                
                if (!isAlreadyExistInDb && ![friendName isEqualToString:MY_USER_NAME])
                {
                    NSString *timeStamp = [UtilityClass getTimeStampWithDate:[NSDate date]];
                    
                    NSString *fbId = [[friendName componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]]lastObject];
                    NSDictionary *matchedDict = [[XmppFriendHandler sharedInstance]getFriendInformationDictFromWebservice:fbId];
                    
                    NSString *matchname = [matchedDict objectForKey:@"firstName"];
                    NSString *matchProfilePic = nil;
                    
                    if ([[matchedDict objectForKey:@"images"] count]>0)
                    {
                        matchProfilePic = [[matchedDict objectForKey:@"images"] objectAtIndex:0];
                    }
                    
                    NSData * imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:matchProfilePic]];
                    
                    NSDictionary *dictFriend = nil;
                    NSString *jid = [NSString stringWithFormat:@"%@@%@",friendName,CHAT_SERVER_ADDRESS];
                    if (imgData)
                    {
                        dictFriend = [[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:friendName,jid,matchname ,presenceStatus,[NSNumber numberWithInt:0],@"I m Using Tinder",timeStamp,imgData,@"NO", nil] forKeys:[NSArray arrayWithObjects:@"friendName",@"friendJid",@"friendDisplayName",@"presenceStatus",@"messageCount",@"lastMessage",@"lastMessageTime",@"friendImage",@"isBlocked",nil] ];
                    }
                    else
                    {
                        dictFriend = [[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:friendName,jid,matchname ,presenceStatus,[NSNumber numberWithInt:0],@"I m Using Tinder",timeStamp,"",@"NO", nil] forKeys:[NSArray arrayWithObjects:@"friendName",@"friendJid",@"friendDisplayName",@"presenceStatus",@"messageCount",@"lastMessage",@"lastMessageTime",@"friendImage",@"isBlocked",nil] ];
                    }
                    
                    [friendHandler insertFriendInfoInDatabase:dictFriend];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_XMPP_FRIENDS_PRESENCE_UPDATE object:nil];
                }
                
            }
            
        }
        
    }
}*/

//updated by sanket nagar for update presence
-(void)updatePresenceStatusOfFriends:(NSString *)friendName PRESENCE:(NSString *)presenceStatus
{
    /*
    XmppFriendHandler *friendHandler = [XmppFriendHandler sharedInstance];
    BOOL isAlreadyExistInDb;

    isAlreadyExistInDb = [friendHandler isFriendAlreadyExistInDatabase:friendName];
    
    if (!isAlreadyExistInDb && ![friendName isEqualToString:MY_USER_NAME])
    {
        NSString *presenceStatus = @"Available";
        NSString *timeStamp = [UtilityClass getTimeStampWithDate:[NSDate date]];
        
        NSString *fbId = [[friendName componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]]lastObject];
        NSDictionary *matchedDict = [[XmppFriendHandler sharedInstance]getFriendInformationDictFromWebservice:fbId];
        
        NSString *matchname = [matchedDict objectForKey:@"firstName"];
        NSString *matchProfilePic = nil;
        
        if ([[matchedDict objectForKey:@"images"] count]>0)
        {
            matchProfilePic = [[matchedDict objectForKey:@"images"] objectAtIndex:0];
        }
        
        NSData * imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:matchProfilePic]];
        
        NSDictionary *dictFriend = nil;
        NSString *jid = [NSString stringWithFormat:@"%@@%@",friendName,CHAT_SERVER_ADDRESS];
        if (imgData)
        {
            dictFriend = [[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:friendName,jid,matchname ,presenceStatus,[NSNumber numberWithInt:0],@"I m Using Karmic",timeStamp,imgData,@"NO", nil] forKeys:[NSArray arrayWithObjects:@"friendName",@"friendJid",@"friendDisplayName",@"presenceStatus",@"messageCount",@"lastMessage",@"lastMessageTime",@"friendImage",@"isBlocked",nil] ];
        }
        else
        {
            dictFriend = [[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:friendName,jid,matchname ,presenceStatus,[NSNumber numberWithInt:0],@"I m Using Karmic",timeStamp,"",@"NO", nil] forKeys:[NSArray arrayWithObjects:@"friendName",@"friendJid",@"friendDisplayName",@"presenceStatus",@"messageCount",@"lastMessage",@"lastMessageTime",@"friendImage",@"isBlocked",nil] ];
        }
        
        [friendHandler insertFriendInfoInDatabase:dictFriend];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_XMPP_FRIENDS_PRESENCE_UPDATE object:nil];
    }
    else
    {
    
        // if (![friend.presenceStatus isEqualToString:presenceStatus])
        {
            [[XmppFriendHandler sharedInstance] updatePresenceStatusOfFriend:friendName andStatus:presenceStatus];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_XMPP_FRIENDS_PRESENCE_UPDATE object:nil];
        }
    }*/
   
}



-(void)sendPresence
{
    NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];
    [xmppStream sendElement:presence];
    
}

#pragma mark XMPPRosterDelegate

- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[presence from] xmppStream:xmppStream managedObjectContext:[self managedObjectContext_roster]];
    
    NSString *displayName = [user displayName];
    NSString *jidStrBare = [presence fromStr];
    NSString *body = nil;
    
    if (![displayName isEqualToString:jidStrBare])
    {
        body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
    }
    else
    {
        body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
    }
    
        // We are not active, so use a local notification instead
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertAction = @"New Request in Flamer Pro";
        localNotification.alertBody = body;
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
   
}

//by sanket for creating new crowd

-(void)createCrowdWithCrowdName:(NSString *)CrowdName
{
    XMPPRoomMemoryStorage * _roomMemory = [[XMPPRoomMemoryStorage alloc]init];
    NSString* roomID =  [NSString stringWithFormat:@"%@@conference.%@",CrowdName,CHAT_SERVER_ADDRESS];//[NSString stringWithFormat:@"%@@%@/%@",GroupName,CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];;
    XMPPJID * roomJID = [XMPPJID jidWithString:roomID];
    xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:_roomMemory
                                                 jid:roomJID
                                       dispatchQueue:dispatch_get_main_queue()];
    [xmppRoom activate:self.xmppStream];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoom joinRoomUsingNickname:MY_USER_NAME
                            history:nil
                           password:nil];
    
}


-(void)createEventWithEventName:(NSString *)eventName
{
    //eventName = @"theEvent";
    XMPPRoomMemoryStorage * _roomMemory = [[XMPPRoomMemoryStorage alloc]init];
    //NSString* roomID =  [NSString stringWithFormat:@"%@@events.%@",eventName,CHAT_SERVER_ADDRESS];//[NSString stringWithFormat:@"%@@%@/%@",GroupName,CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];;
    
    NSString* roomID =  [NSString stringWithFormat:@"%@@%@",eventName,CHAT_SERVER_ADDRESS_Event];
    XMPPJID * roomJID = [XMPPJID jidWithString:roomID];
    xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:_roomMemory
                                                 jid:roomJID
                                       dispatchQueue:dispatch_get_main_queue()];
    [xmppRoom activate:self.xmppStream];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoom joinRoomUsingNickname:MY_USER_NAME
                            history:nil
                           password:nil];
    
}


- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    [self performSelector:@selector(ConfigureNewRoom:) withObject:sender afterDelay:2];
}



-(void)ConfigureNewRoom:(XMPPRoom*)sender{
    [sender fetchConfigurationForm];
    [sender configureRoomUsingOptions:nil];}


- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm
{
    //DDLogVerbose(@"%@: %@ -> %@", THIS_FILE, THIS_METHOD, sender.roomJID.user);//roomconfig_persistentroom
    
    NSLog(@"sender room ki jid %@",sender.roomJID);
    
    if([[NSString stringWithFormat:@"%@",sender.roomJID ] rangeOfString:CHAT_SERVER_ADDRESS_Event].location != NSNotFound)
    {
        NSString *eventName =[[[NSString stringWithFormat:@"%@",sender.roomJID] componentsSeparatedByString:@"@"] objectAtIndex:0];
        
        NSMutableDictionary *eventDict = [self getEventDictForEventName:eventName];
        
        if (eventDict != nil)
        {
            NSString *invitationMsg = [eventDict valueForKey:@"invitationMsg"];
            
            NSXMLElement *newConfig = [configForm copy];
            NSArray* fields = [newConfig elementsForName:@"field"];
            for (NSXMLElement *field in fields) {
                NSString *var = [field attributeStringValueForName:@"var"];
                if ([var isEqualToString:@"muc#roomconfig_roomdesc"]) {
                    [field removeChildAtIndex:0];
                    //[field addChild:[NSXMLElement elementWithName:@"name" stringValue:@"1"]];
                    [field addChild:[NSXMLElement elementWithName:@"value" stringValue:invitationMsg]];
                    
                }
                if ([var isEqualToString:@"muc#roomconfig_persistentroom"])
                {
                    [field removeChildAtIndex:0];
                    //[field addChild:[NSXMLElement elementWithName:@"name" stringValue:@"1"]];
                    [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
                }
            }
            [sender configureRoomUsingOptions:newConfig];
            
        }
        
    }
    else if ([[NSString stringWithFormat:@"%@",sender.roomJID ] rangeOfString:@"@conference"].location != NSNotFound)
    {
        NSString *crowdName =[[[NSString stringWithFormat:@"%@",sender.roomJID] componentsSeparatedByString:@"@"] objectAtIndex:0];
        
        NSMutableDictionary *crowdDict = [self getCrowdDictForCrowdName:crowdName];
        
        if (crowdDict != nil)
        {
            
            NSString *invitationMsg = [crowdDict valueForKey:@"crowdInvitationMsg"];
            
            if(![invitationMsg isEqualToString:@""])
            {
                NSXMLElement *newConfig = [configForm copy];
                NSArray* fields = [newConfig elementsForName:@"field"];
                for (NSXMLElement *field in fields) {
                    NSString *var = [field attributeStringValueForName:@"var"];
                    if ([var isEqualToString:@"muc#roomconfig_roomdesc"]) {
                        [field removeChildAtIndex:0];
                        //[field addChild:[NSXMLElement elementWithName:@"name" stringValue:@"1"]];
                        [field addChild:[NSXMLElement elementWithName:@"value" stringValue:invitationMsg]];
                        
                    }
                    if ([var isEqualToString:@"muc#roomconfig_persistentroom"])
                    {
                        [field removeChildAtIndex:0];
                        //[field addChild:[NSXMLElement elementWithName:@"name" stringValue:@"1"]];
                        [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
                    }
                }
                [sender configureRoomUsingOptions:newConfig];
            }
            
            
        }
        
        
    }
    
}

-(NSMutableDictionary *)getEventDictForEventName:(NSString *)eventName
{
    NSMutableDictionary *getFrndObj;
    BOOL isExist = NO;
    
    for(int i=0; i<[self.arrAllEvents count]; i++)
    {
        getFrndObj = [self.arrAllEvents objectAtIndex:i];
        
        if([[getFrndObj valueForKey:@"eventName"] isEqualToString:eventName])
        {
            
            isExist = YES;
            break;
        }
    }
    
    if(isExist)
    {
        return getFrndObj;
    }
    else
        return nil;
    
}

- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult{
    //[self showAlert:@"Room Created And Configured. Invite Users Now"];
    [self inviteUsers:sender];
}

//by sanket for getting friends for a crowd

-(NSArray *)getFriendsForCrowdName:(NSString *)crowdName
{
    NSMutableDictionary *getFrndObj;
    BOOL isExist = NO;
    
    for(int i=0; i<[self.arrAllCrowds count]; i++)
    {
        getFrndObj = [self.arrAllCrowds objectAtIndex:i];
        
        if([[getFrndObj valueForKey:@"crowdName"] isEqualToString:crowdName])
        {
            isExist = YES;
            break;
        }
    }
    
    if(isExist)
    {
        return [NSArray arrayWithArray:[getFrndObj objectForKey:@"crowdFriends"]];
    }
    else
        return nil;
}

//by sanket for getcrowd dict fro crowd

-(NSMutableDictionary *)getCrowdDictForCrowdName:(NSString *)crowdName
{
    NSMutableDictionary *getFrndObj;
    BOOL isExist = NO;
    
    for(int i=0; i<[self.arrAllCrowds count]; i++)
    {
        getFrndObj = [self.arrAllCrowds objectAtIndex:i];
        
        if([[getFrndObj valueForKey:@"crowdName"] isEqualToString:crowdName])
        {
            
            isExist = YES;
            break;
        }
    }
    
    if(isExist)
    {
        return getFrndObj;
    }
    else
        return nil;
    
}

//by sanket for invite users to crowd

-(void)inviteUsers:(XMPPRoom*)sender{
    if(1)// This has to be done only when we intended add condition
    {
        // NSLog(@"sender room ki jid %@",sender.roomSubject);
        NSLog(@"sender room ki jid %@",sender.roomJID);
        
        if([[NSString stringWithFormat:@"%@",sender.roomJID ] rangeOfString:@"@conference"].location != NSNotFound)
        {
            NSString *crowdName =[[[NSString stringWithFormat:@"%@",sender.roomJID] componentsSeparatedByString:@"@"] objectAtIndex:0];
            
            NSMutableDictionary *crowdDict = [self getCrowdDictForCrowdName:crowdName];
            
            NSMutableArray *crowdsFriends = [crowdDict valueForKey:@"crowdFriends"];
            NSString *joinMsgWithFriendList = [crowdDict valueForKey:@"crowdInvitationMsg"];//@"Join Group friendlist:";
            
            if([crowdsFriends containsObject:MY_USER_NAME])
            {
                [crowdsFriends removeObject:MY_USER_NAME];
            }
            
            if(crowdsFriends.count > 0)
            {
                for(int i=0; i< crowdsFriends.count; i++)
                {
                    NSString *frndJID = [NSString stringWithFormat:@"%@@%@/%@",[crowdsFriends objectAtIndex:i],CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
                    XMPPJID *xmppJID=[XMPPJID jidWithString:frndJID];
                    [sender inviteUser:xmppJID withMessage:joinMsgWithFriendList];
                }
                
            }
            //arrSelectedCroudFriendsToBeInvited = [[NSMutableArray alloc]init];
        }
        else if([[NSString stringWithFormat:@"%@",sender.roomJID ] rangeOfString:CHAT_SERVER_ADDRESS_Event].location != NSNotFound)
        {
            NSString *eventName =[[[NSString stringWithFormat:@"%@",sender.roomJID] componentsSeparatedByString:@"@"] objectAtIndex:0];
            
            NSMutableDictionary *eventDict = [self getEventDictForEventName:eventName];
            
            
            NSMutableArray *eventFriends = [eventDict valueForKey:@"eventFriends"];
            
            if([eventFriends containsObject:MY_USER_NAME])
            {
                [eventFriends removeObject:MY_USER_NAME];
            }
            
            //[eventFriends addObject:MY_USER_NAME];
            
            NSString *invitationMsg = [eventDict valueForKey:@"invitationMsg"];
            
            
            if(eventFriends.count > 0)
            {
                for(int i=0; i< eventFriends.count; i++)
                {
                    NSString *frndJID = [NSString stringWithFormat:@"%@@%@/%@",[eventFriends objectAtIndex:i],CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
                    XMPPJID *xmppJID=[XMPPJID jidWithString:frndJID];
                    [sender inviteUser:xmppJID withMessage:invitationMsg];
                }
                
            }
        }
        
        
    }
    
}

- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *) roomJID didReceiveInvitation:(XMPPMessage *)message
{
    
}
- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *) roomJID didReceiveInvitationDecline:(XMPPMessage *)message
{
    
}

#pragma mark---
#pragma  mark - Search User

-(void)searchUserByName:(NSString *)emailID
{
    NSString *userBare1  = [[[self xmppStream] myJID] bare];
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:search"];
    
    [query addChild:[NSXMLElement elementWithName:@"nick" stringValue:emailID]];
    
    
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"search4"];
    [iq addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"search.%@",CHAT_SERVER_ADDRESS ]];
    [iq addAttributeWithName:@"from" stringValue:userBare1];
    [iq addChild:query];
    [[self xmppStream] sendElement:iq];
    
    
    NSLog(@"request for searchh==%@",[iq description]);
    
    
    
}

#pragma mark -vcard methods



-(void)updateVcardAfterRegistration:(NSDictionary *)VCardDict
{
    //code for update vcard----
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"vCard"];
    [query addAttributeWithName:@"xmlns" stringValue:@"vcard-temp"];
    [query addChild:[NSXMLElement elementWithName:@"DISPLAY_NAME" stringValue:[VCardDict valueForKey:@"DISPLAY_NAME"]]];
    [query addChild:[NSXMLElement elementWithName:@"BDAY" stringValue:[VCardDict valueForKey:@"BDAY"]]];
    [query addChild:[NSXMLElement elementWithName:@"GENDER" stringValue:[VCardDict valueForKey:@"GENDER"]]];
    [query addChild:[NSXMLElement elementWithName:@"INTEREST" stringValue:[VCardDict valueForKey:@"INTEREST"]]];
    [query addChild:[NSXMLElement elementWithName:@"EMAIL" stringValue:[VCardDict valueForKey:@"EMAIL"]]];
    [query addChild:[NSXMLElement elementWithName:@"STATUS" stringValue:[VCardDict valueForKey:@"STATUS"]]];
    [query addChild:[NSXMLElement elementWithName:@"PHOTO" stringValue:[VCardDict valueForKey:@"PHOTO"]]];
    
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"id" stringValue:@"v2"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addChild:query];
    [xmppStream sendElement:iq];
    
}


//by sanket for get vcard for a user

-(void)getVcardForFriendName:(NSString *)friendName
{
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"vCard"];
    [query addAttributeWithName:@"xmlns" stringValue:@"vcard-temp"];
    
    NSString *userBare1  = [[[self xmppStream] myJID] bare];
    NSString *friendId = [NSString stringWithFormat:@"%@@%@",friendName,CHAT_SERVER_ADDRESS];
    
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"from" stringValue:userBare1];
    [iq addAttributeWithName:@"id" stringValue:@"v1"];
    [iq addAttributeWithName:@"to" stringValue:friendId];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    
    
    [iq addChild:query];
    [[self xmppStream] sendElement:iq];
   
}

-(UIImage *)getImageForFriendName:(NSString *)friendName IsSelfUser:(BOOL)isMyImage
{
    
    NSMutableDictionary *getFrndObj;
    BOOL isExist = NO;
    
    if(friendName != nil)
    {
        if(!isMyImage)
        {
            for(int i=0; i<[self.friendsArray count]; i++)
            {
                getFrndObj = [self.friendsArray objectAtIndex:i];
                
                if([[getFrndObj valueForKey:@"friendName"] isEqualToString:friendName])
                {
                    isExist = YES;
                    break;
                }
            }
            
            if(isExist)
            {
                
                NSString *base64Str1 =[getFrndObj valueForKey:@"friendImage"];
                if(base64Str1 && ![base64Str1 isEqualToString:@""])
                {
                    NSData *imgData = [NSData dataFromBase64String:base64Str1];
                    
                    if (imgData)
                    {
                        return [UIImage imageWithData:imgData];
                        
                    }
                }
            }
            
        }
        //fetch MyOwnImage
        else
        {
            if ([[NSUserDefaults standardUserDefaults]valueForKey:@"userInfo"])
            {
                
                getFrndObj =[[NSUserDefaults standardUserDefaults]valueForKey:@"userInfo"];
                
                NSString *base64Str1 =[getFrndObj valueForKey:@"myImage"];
                if(base64Str1 && ![base64Str1 isEqualToString:@""])
                {
                    
                    NSData *imgData = [NSData dataFromBase64String:base64Str1];
                    
                    if (imgData)
                    {
                        return [UIImage imageWithData:imgData];
                        
                    }
                }
                
            }
            
        }
    }
    return nil;
}




#pragma update user image
//- (void)updateAvatar:(UIImage *)avatar
//{
//    NSData *imageData = UIImagePNGRepresentation(avatar);
//    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
//    dispatch_async(queue, ^{
//        XMPPvCardTempModule *vCardTempModule = [[XMPPHandler sharedInstance] xmppvCardTempModule];
//        XMPPvCardTemp *myVcardTemp = [vCardTempModule myvCardTemp];
//        //  [myVcardTemp setName:[NSString stringWithFormat:@"%@",name.text]];
//        [myVcardTemp setPhoto:imageData];
//        [vCardTempModule updateMyvCardTemp:myVcardTemp];
//    });
//}

-(void)leaveRoom:(NSString *)roomName
{
    /* NSString* roomID =  [NSString stringWithFormat:@"%@@conference.%@",roomName,CHAT_SERVER_ADDRESS];//[NSString stringWithFormat:@"%@@%@/%@",GroupName,CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];;
     XMPPJID * roomJID = [XMPPJID jidWithString:roomID];
     
     [xmppRoom leaveRoom];*/
    
}

-(void)getAllEventsCreated
{
    NSString* serverAdd =  [NSString stringWithFormat:@"events.%@",CHAT_SERVER_ADDRESS];
    
    XMPPJID *servrJID = [XMPPJID jidWithString:CHAT_SERVER_ADDRESS_Event];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:servrJID];
    [iq addAttributeWithName:@"from" stringValue:[xmppStream myJID].full];
    [iq addAttributeWithName:@"id" stringValue:@"AllEvents"];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/disco#items"];
    [iq addChild:query];
    [xmppStream sendElement:iq];
}

-(void)getAllCrowdsCreated
{
    NSString* serverAdd =  [NSString stringWithFormat:@"conference.%@",CHAT_SERVER_ADDRESS];
    
    XMPPJID *servrJID = [XMPPJID jidWithString:serverAdd];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:servrJID];
    [iq addAttributeWithName:@"from" stringValue:[xmppStream myJID].full];
    [iq addAttributeWithName:@"id" stringValue:@"AllCrowds"];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/disco#items"];
    [iq addChild:query];
    [xmppStream sendElement:iq];
}

-(void)getCrowdInfo:(NSString *)roomName
{
    
    NSString* serverAdd =  [NSString stringWithFormat:@"%@@conference.%@",roomName,CHAT_SERVER_ADDRESS];
    
    XMPPJID *servrJID = [XMPPJID jidWithString:serverAdd];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:servrJID];
    [iq addAttributeWithName:@"from" stringValue:[xmppStream myJID].full];
    [iq addAttributeWithName:@"id" stringValue:@"CrowdInfo"];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/disco#info"];
    [iq addChild:query];
    [xmppStream sendElement:iq];
}

-(void)getEventInfo:(NSString *)roomName
{
    
    NSString* serverAdd =  [NSString stringWithFormat:@"%@@%@",roomName,CHAT_SERVER_ADDRESS_Event];
    
    XMPPJID *servrJID = [XMPPJID jidWithString:serverAdd];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:servrJID];
    [iq addAttributeWithName:@"from" stringValue:[xmppStream myJID].full];
    [iq addAttributeWithName:@"id" stringValue:@"EventInfo"];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/disco#info"];
    [iq addChild:query];
    [xmppStream sendElement:iq];
}

- (BOOL)sendImageToServer:(UIImage *)image CrowdName:(NSString *)crowdName
{
    
    NSData *imageData = UIImagePNGRepresentation(image);
    NSUInteger len = [imageData length];
    Byte *byteData = (Byte*)[imageData bytes];//malloc(len);
    memcpy(byteData, [imageData bytes], len);
    
    //  NSString *postLength = [NSString stringWithFormat:@"%d", [imageData length]];
    
    NSString *imgName = [crowdName stringByAppendingString:@".png"];
    NSString *MainURL = @"http://aroundmenow.com.br/ws/uploadwithname.php";
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:MainURL]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"0x0hHai1CanHazB0undar135";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding: NSUTF8StringEncoding]];
    
    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"filename\"; filename=\"%@\"\r\n",imgName]dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [body appendData:[[NSString stringWithFormat:@"Content-Type: image/png\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:imageData];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    //NSLog(@"returned dataaaa==%@", [returnData description]);
    
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@",returnString);
    
    if([returnString rangeOfString:@"Image uploaded successfully"].location != NSNotFound)
    {
        return YES;
    }
    
    return NO;
    
}

-(NSData *)getImageDataForCrowdName:(NSString *)crowdName
{
    NSString *strUrl = [[@"http://aroundmenow.com.br/uploads/" stringByAppendingString:crowdName] stringByAppendingString:@".png"];
    
    NSData *thedata  = [NSData dataWithContentsOfURL:[NSURL URLWithString:strUrl]];
    return thedata;
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

-(void)sendDeviceTockenToserver
{
    /*
     WebCommunicationClass *web=[[WebCommunicationClass alloc]init];
     web.aCaller=self;
     
     NSLog(@"device token==%@",self.deviceToken);
     
     //_deviceTocken = @"80bb6bad684a4e9cb12899e099613b80429665a0e402b7f02cbd8728498c6314";
     
     NSString *myJID = [NSString stringWithFormat:@"%@@%@/%@",MY_USER_NAME,CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
     
     [web sendDeviceTockenToServerWithJID:myJID Tocken:self.deviceToken];
     */
    
}

-(void)deleteUserFromXmpp
{
    NSString *myJID = [NSString stringWithFormat:@"%@@%@/%@",@"user3",CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
    
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set" ];
    [iq addAttributeWithName:@"id" stringValue:@"unreg1"];
    [iq addAttributeWithName:@"to" stringValue:myJID];
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:register"];
    
    [query addChild:[NSXMLElement elementWithName:@"remove" stringValue:@""]];
    
    [iq addChild:query];
    [xmppStream sendElement:iq];
    
}

-(void)changePassword:(NSString *)newPassword
{
    
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set" ];
    [iq addAttributeWithName:@"id" stringValue:@"unreg1"];
    [iq addAttributeWithName:@"to" stringValue:CHAT_SERVER_ADDRESS];
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:register"];
    
    [query addChild:[NSXMLElement elementWithName:@"username" stringValue:@"user3"]];
    [query addChild:[NSXMLElement elementWithName:@"password" stringValue:@"user3"]];
    
    [iq addChild:query];
    [xmppStream sendElement:iq];
    
}

-(void)sendUserLocation
{
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set" ];
    [iq addAttributeWithName:@"from" stringValue:[xmppStream myJID].full];
    [iq addAttributeWithName:@"id" stringValue:@"publish1"];
    
    
    NSXMLElement *pubsub = [NSXMLElement elementWithName:@"pubsub"];
    [pubsub addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/pubsub"];
    //[iq addChild:pubsub];
    
    NSXMLElement *publish = [NSXMLElement elementWithName:@"publish"];
    [publish addAttributeWithName:@"node" stringValue:@"http://jabber.org/protocol/geoloc"];
    //[iq addChild:publish];
    
    
    NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
    NSXMLElement *geoloc = [NSXMLElement elementWithName:@"geoloc"];
    [geoloc addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/geoloc"];
    [geoloc addAttributeWithName:@"xml:lang" stringValue:@"en"];
    
    
    
    [geoloc addChild:[NSXMLElement elementWithName:@"accuracy" stringValue:@"20"]];
    [geoloc addChild:[NSXMLElement elementWithName:@"country" stringValue:@"INdia"]];
    [geoloc addChild:[NSXMLElement elementWithName:@"lat" stringValue:@"45.44"]];
    [geoloc addChild:[NSXMLElement elementWithName:@"locality" stringValue:@"Jaipur"]];
    [geoloc addChild:[NSXMLElement elementWithName:@"lon" stringValue:@"12.33"]];
    
    
    [item addChild:geoloc];
    
    [publish addChild:item];
    [pubsub addChild:publish];
    
    [iq addChild:pubsub];
    [xmppStream sendElement:iq];
    
}

-(void)getPrivacyListFromServer
{
    NSString *myJID = [NSString stringWithFormat:@"%@@%@/%@",MY_USER_NAME,CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
    
    [xmppvCardTempModule fetchvCardTempForJID:[XMPPJID jidWithString:myJID]];
    [xmppvCardTempModule  activate:[self xmppStream]];
    
}


-(void)sendImageFile:(NSString *)recieverJID Sender:(NSString *)senderJID Message:(NSString *)mgsString ImageStr:(NSString *)imgStr MessageID:(NSString *)msgID MessageType:(NSString *)msgType
{
    
    /*NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:mgsString];
   
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"id" stringValue:msgID];
    [message addAttributeWithName:@"type" stringValue:msgType];
    [message addAttributeWithName:@"from" stringValue:senderJID];
    [message addAttributeWithName:@"to" stringValue:recieverJID];
    [message addChild:body];
    
    NSXMLElement *ImgAttachement = [NSXMLElement elementWithName:@"attachement"];
    [ImgAttachement setStringValue:imgStr];
    [message addChild:ImgAttachement];
    
    [self.xmppStream sendElement:message];
    */
    
    //updated for configure with android
    
   
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:mgsString];
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"id" stringValue:msgID];
    [message addAttributeWithName:@"type" stringValue:msgType];
    [message addAttributeWithName:@"from" stringValue:senderJID];
    [message addAttributeWithName:@"to" stringValue:recieverJID];
    [message addChild:body];
    
   /* NSXMLElement *ImgAttachement = [NSXMLElement elementWithName:@"attachement"];
    [ImgAttachement setStringValue:imgStr];
    [message addChild:ImgAttachement];*/
    
    [self.xmppStream sendElement:message];
    
    
    
}

-(void)setTurnSocketConnectionWithFriend:(NSString *)friendJid
{
    turnSockets=[[NSMutableArray alloc]init];
    
    XMPPJID *jid = [XMPPJID jidWithString:friendJid];
    
    NSLog(@"Attempting TURN connection to %@", jid);
    
    TURNSocket *turnSocket = [[TURNSocket alloc] initWithStream:[self xmppStream] toJID:jid];
    
    [TURNSocket setProxyCandidates:[NSArray arrayWithObjects:friendJid, nil]];
    
    [turnSockets addObject:turnSocket];
    
    [turnSocket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
}

- (void)turnSocket:(TURNSocket *)sender didSucceed:(GCDAsyncSocket *)socket {
    
    NSLog(@"TURN Connection succeeded!");
    NSLog(@"You now have a socket that you can use to send/receive data to/from the other person.");
    
    [turnSockets removeObject:sender];
}

- (void)turnSocketDidFail:(TURNSocket *)sender {
    
    NSLog(@"TURN Connection failed!");
    [turnSockets removeObject:sender];
    
}


@end
