//
//  XmppCommunicationHandler.h
//  Karmic
//
//  Created by Sanskar on 09/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "XMPPMessageArchivingCoreDataStorage.h"
#import "XMPPMessageArchiving.h"
#import "XMPPRoomMemoryStorage.h"
#import "XMPPRoomMessage.h"
#import "XMPPRoom.h"
#import "XMPPRoomCoreDataStorage.h"
#import "XMPPMUC.h"
#import "XMPPRosterMemoryStorage.h"


@protocol XMPPHandlerDelegate <NSObject>

@optional
//Declare Protocol method. it is called when data downloading is finished
-(void) XMPPDidLogin:(XMPPStream *)Stream;
-(void) XMPPDidRegistered:(XMPPStream *)Stream;
-(void) XMPPDidAuthenticate:(XMPPStream *)Stream;
-(void) XMPPDidNotAuthenticate:(XMPPStream *)Stream;
-(void) XMPPDidConnect:(XMPPStream *)Stream;
-(void) XMPPDidReceiveMessage:(XMPPStream *)Stream Message:(XMPPMessage *)Message;
-(void) XMPPDidDisconnect:(XMPPStream *)Stream;

@end

@interface XmppCommunicationHandler : NSObject<XMPPRosterDelegate,UIAlertViewDelegate,XMPPMUCDelegate>
{
    //XMPP
    XMPPStream *xmppStream;
    XMPPRoom *xmppRoom;
    
    
    
    XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
    XMPPvCardTempModule *xmppvCardTempModule;
    XMPPvCardAvatarModule *xmppvCardAvatarModule;
    XMPPCapabilities *xmppCapabilities;
    XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    XMPPRosterMemoryStorage *xmppRosterMemStorage;
    
    NSString *password;
    BOOL isRegister;
    BOOL isUserNameNotAlreadyExist;
    BOOL isregisteringWithExternalApp;
    BOOL isLogging;
    
    NSMutableArray *turnSockets;

}

@property (nonatomic,assign)BOOL isRegister;
@property (nonatomic,assign)BOOL isLogging;
@property (nonatomic,assign)BOOL isUserNameNotAlreadyExist;
@property (nonatomic,assign)BOOL isregisteringWithExternalApp;
//property of Delegate
@property (retain, nonatomic) id <XMPPHandlerDelegate> XMPPDelegate;

//XMPP
@property (nonatomic, strong, readonly) XMPPRosterMemoryStorage *xmppRosterMemStorage;
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

@property (nonatomic, strong, readonly) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
@property (nonatomic, strong, readonly) XMPPMessageArchiving *xmppMessageArchivingModule;

//sanket nagar
@property (nonatomic, retain) NSMutableArray *friendList;

@property (nonatomic, retain) NSMutableArray *friendsArray;
@property (nonatomic, retain) NSMutableArray *allChatMessagesArray;
@property (nonatomic, strong) NSString *currentFriendName;
@property (nonatomic, strong) NSString *currentFriendReuestJID;
@property (nonatomic, retain) NSMutableArray *recentChatFriendsArray;

@property (nonatomic, retain) NSMutableArray *allPendingMsgCountsArray;

@property (nonatomic, retain) NSMutableArray *arrAllCrowds;
@property (nonatomic, retain) NSMutableArray *arrAllCrowdsImages;
@property (nonatomic, retain) NSMutableArray *arrSelectedCroudFriendsToBeInvited;
@property (nonatomic, retain) NSMutableArray *arrAllCroudChatMessages;
@property (nonatomic, retain) NSMutableArray *arrAllEvents;
@property (nonatomic ,assign ) BOOL isAutoSendCrowdRequestForFirstTime;
@property (nonatomic, retain) NSMutableArray *elementsArray;
@property (nonatomic, retain) NSMutableArray *arrBlockedFriends;

@property (nonatomic,retain) NSString *currentVC;

@property (nonatomic, strong) id  _chatDelegate;
@property (nonatomic, strong) id  _messageDelegate;


+(id)sharedInstance;
-(void)initialSetup;

//Updated By Sanskar
- (void) registerOnXMPPWithUsername:(NSString *) username andPassword:(NSString *)userPassword;
- (void) loginOnXMPPWithUsername:(NSString *) username andPassword:(NSString *)userPassword;
- (BOOL) connect;
- (void) disconnect;



// methods by sanket nagar
- (void)getAllRegisteredUsers;
-(void)SendFriendRequestWithFriendName:(NSString *)friendName;
-(void)sendMessage:(NSString *)recieverJID Sender:(NSString *)senderJID Message:(NSString *)mgsString MessageID:(NSString *)msgID MessageType:(NSString *)msgType;
//-(void)saveSingleChatMessage:(NSString *)recieverName Sender:(NSString *)senderName Message:(NSString *)mgsString MessageID:(NSString *)msgID;
-(void)saveSingleChatMessage:(NSString *)recieverName Sender:(NSString *)senderName Message:(NSString *)mgsString MessageID:(NSString *)msgID MediaType:(NSString *)mediaType;

-(void)savePendingMessageCount:(NSString *)friendName UPDATE:(BOOL)isResetting;
-(void)updatePresenceStatusOfFriends:(NSString *)friendName PRESENCE:(NSString *)presenceStatus;
-(void)addFriendObjInRecentChatArray:(NSString *)friendName FriendObj:(NSObject *)friendObj;
-(void)loadAllMesssagesForUser;
-(void)loadAllRecentChatList;
-(void)loadAllPendingMessages;



-(void)updateMessageStatusOnDataBase:(NSString *)msgID;


-(void)getAllGroupList;
-(void)createCrowdWithCrowdName:(NSString *)CrowdName;

-(void)loadAllCroudsImages;
-(void)addNewCroudIntoAllCroudArr:(NSString *)croudName  CroudDict:(NSDictionary *)newCroudObj;
-(void)saveGroupChatMessage:(NSString *)groupName Sender:(NSString *)senderName Message:(NSString *)mgsString MessageID:(NSString *)msgID;


-(void)loadAllCroudChatMesssages;


-(void)searchUserByName:(NSString *)emailID
;


-(void)saveNewEventObjIntoAllInvitaions:(NSDictionary *)dictMsg;

-(void)loadAllEvents;
//-(void)sendRecievedMessageWithIID:(NSString *)recieverJID Sender:(NSString *)senderJID MessageID:(NSString *)msgID;

-(void)registerOnXMPPWithElements:(NSString *) username Password:(NSString *)userPassword Email:(NSString *)email FBid:(NSString *)fbId;

-(void)getVcardForFriendName:(NSString *)name;
-(void)updateVcardAfterRegistration:(NSDictionary *)VCardDict;

//blocking user
-(void)loadAllBlockedFriends;
-(void)addFriendInBlockedUserList:(NSString *)friendName;
-(BOOL)isFriendBlocked:(NSString *)friendName;
-(void)removeFriendFromBlockedUserList:(NSString *)friendName;



-(UIImage *)getImageForFriendName:(NSString *)friendName IsSelfUser:(BOOL)isMyImage;


- (BOOL)sendImageToServer:(UIImage *)image CrowdName:(NSString *)crowdName;

-(void)createEventWithEventName:(NSString *)eventName;


-(void)getAllEventsCreated;


-(void)leaveRoom:(NSString *)roomName;
-(void)getAllCrowdsCreated;
-(NSData *)getImageDataForCrowdName:(NSString *)crowdName;
-(UIImage *)getImageForCrowdName:(NSString *)crowdName;
-(void)saveCrowdImageForCrowdName:(NSString *)crowdName CrowdImage:(NSData *)imageData;

-(void)sendDeviceTockenToserver;
-(void)deleteUserFromXmpp;

-(void)changePassword:(NSString *)newPassword;

-(void)getPrivacyListFromServer;

-(void)acceptFriendRequestWithFriendName : (NSString *)friendName friendDisplayName:(NSString *)displayName friendImageUrl:(NSString *)imageUrl;
-(void)decineFriendRequestWithFriendName : (NSString *)friendName;

-(void)sendImageFile:(NSString *)recieverJID Sender:(NSString *)senderJID Message:(NSString *)mgsString ImageStr:(NSString *)imgStr MessageID:(NSString *)msgID MessageType:(NSString *)msgType;

-(void) setTurnSocketConnectionWithFriend:(NSString *)recieverJID;
@end
