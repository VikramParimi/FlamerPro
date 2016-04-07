//
//  ChattingVC.h
//  PyaarIO
//
//  Created by iGlobe-9 on 20/12/14.
//  Copyright (c) 2014 Doubbletap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XmppFriendHandler.h"
#import "XmppCommunicationHandler.h"
#import "PlaceHolderTextView.h"
#import "EGOImageView.h"

@protocol chattingVCDelegate <NSObject>
-(void)popFromChttingView;
@end



@interface ChattingVC : UIViewController

<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UIGestureRecognizerDelegate>
{
    XmppFriend *currentChatObj;
    NSDictionary *currentMachedObj;
    
    NSMutableArray *allChatMessageArray;
    NSMutableArray *currentChatMessageArray;
    NSMutableArray *userChatMessagesArray;
    NSMutableArray *friendChatMessageArray;
    
    NSString *friendName;
    

    CGFloat keyBoardHeight;
    
    
    IBOutlet UILabel *lblTypingStatus;
    IBOutlet UIImageView *imgFriend;
    
     BOOL isFromNewMatch;
    
    
    //view push noti
    
    IBOutlet UIView *viewPushnotification;
    
    IBOutlet EGOImageView *imgBgProfile;
    
    
    //autoLayout constraints
    IBOutlet NSLayoutConstraint *tblChatBottomSpaceContstraint;
    IBOutlet NSLayoutConstraint *vwSendBottomSpaceContraint;
    IBOutlet NSLayoutConstraint *vwSendHeightConst;
    IBOutlet NSLayoutConstraint *viewPushHeightConstraint;
    IBOutlet NSLayoutConstraint *imgBgProfileHeightConstraint;
}
@property (assign)id <chattingVCDelegate>delegate;
@property (nonatomic,assign) BOOL isFromNewMatch;

@property (strong,nonatomic)XmppFriend *currentChatObj;
@property (strong,nonatomic)NSDictionary *currentMachedObj;

@property (strong,nonatomic)NSMutableArray *allChatMessageArray;
@property (strong,nonatomic)NSMutableArray *currentChatMessageArray;
@property (strong,nonatomic)NSMutableArray *userChatMessagesArray;
@property (strong,nonatomic)NSMutableArray *friendChatMessageArray;

@property (strong, nonatomic) IBOutlet UITableView *tblViewForChatting;
@property (strong, nonatomic) IBOutlet UIImageView *imgBackGround;
@property (strong, nonatomic) IBOutlet UIView *viewBackGround;
@property (strong, nonatomic) IBOutlet PlaceHolderTextView *txtForChat;
@property (strong, nonatomic) IBOutlet UIView *viewForChatSetting;
@property (strong, nonatomic) IBOutlet UIView *viewSend;

@property (weak, nonatomic) IBOutlet UILabel *lblName;

- (IBAction)btnBackTpped:(id)sender;
- (IBAction)btnMenuChatSetting:(id)sender;
- (IBAction)btnSendTapped:(id)sender;

- (IBAction)btnBlockUserTapped:(id)sender;
- (IBAction)btnClearConversationTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblBlock;

-(void)getUsersChatMessages;
- (IBAction)btnPushNotificationTapped:(id)sender;
- (IBAction)btnInfoTapped:(id)sender;

@end
