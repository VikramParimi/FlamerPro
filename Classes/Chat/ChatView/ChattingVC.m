//
//  ChattingVC.m
//  PyaarIO
//
//  Created by iGlobe-9 on 20/12/14.
//  Copyright (c) 2014 Doubbletap. All rights reserved.
//
#import "ChattingVC.h"
#import "NSData+Base64Encoding.h"
#import "XmppSingleChatHandler.h"
#import "AllConstants.h"
#import "AMNSupprot.h"
#import "ChatMessageBubble.h"


#import "PreferencesViewController.h"
#import "InfoViewController.h"
#import "LogEvents.h"
#import "AppSettingsVC.h"

@interface ChattingVC ()<UIActionSheetDelegate>
{
    BOOL Animation;
}

@end

@implementation ChattingVC
{
    NSData *userImageData;
    NSData *friendImageData;
    BOOL isFriendIsBlocked;
    
     NSMutableArray *arrMoreOptions;
}

@synthesize tblViewForChatting,viewForChatSetting,imgBackGround,viewBackGround,currentChatObj,currentChatMessageArray,allChatMessageArray,userChatMessagesArray,friendChatMessageArray;
@synthesize isFromNewMatch;
@synthesize currentMachedObj;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [viewForChatSetting setFrame:CGRectMake(-viewForChatSetting.frame.size.width, 20, viewForChatSetting.frame.size.width, 558)];
    
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ScreemTapped)];
    [self.tblViewForChatting addGestureRecognizer:gesture];
    [gesture setDelegate:self];
    [gesture setNumberOfTouchesRequired:1];
    // Use Swipe Gesture For Chat Menu
    UISwipeGestureRecognizer *swipeGesture=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(ScreenSwipped)];
    [swipeGesture setDelegate:self];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeGesture setDelaysTouchesBegan:YES];
    [swipeGesture setDelaysTouchesEnded:YES];
    [self.view addGestureRecognizer:swipeGesture];
    //For Retina 3.5
    if ([UIScreen mainScreen].bounds.size.height==480)
    {
        viewBackGround.frame=CGRectMake(2, 0, viewBackGround.frame.size.width, 478);
        
    }
    
    [[NSNotificationCenter defaultCenter ]addObserver:self selector:@selector(getMessage:) name:@"recieveMessage" object:nil];
    
    [[NSNotificationCenter defaultCenter ]addObserver:self selector:@selector(messageStatusUpdate:) name:@"messageStatusChanged" object:nil];
    
    [[NSNotificationCenter defaultCenter ]addObserver:self selector:@selector(typingStatusUpdate:) name:@"receiveTypingStatus" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(presenceUpdated:) name:@"friendPresenceUpdated" object:nil] ;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(xmppStreamGetConnected) name:@"XMPP_STREAM_CONNECTED" object:nil] ;
    
    
    if([[currentChatObj isBlocked] isEqualToString:@"YES"])
    {
       
        isFriendIsBlocked = YES;
            
        _lblBlock.text = @"Unblock User";
     
    }
    
    
    [self getUsersChatMessages];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow1:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide1:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self initialSetupForFriend];
    
  
}

-(void)viewWillAppear:(BOOL)animated
{
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"PushAlert"])
    {
        NSString *isAlert = [[NSUserDefaults standardUserDefaults] valueForKey:@"PushAlert"];
        if ([isAlert isEqualToString:@"NO"])
        {
            [viewPushnotification setHidden:NO];
            viewPushHeightConstraint.constant = 50;
        }
        else
        {
            [viewPushnotification setHidden:YES];
            viewPushHeightConstraint.constant = 0;
        }
    }
    else
    {
        [viewPushnotification setHidden:YES];
        viewPushHeightConstraint.constant = 0;
    }
    
     [self setProfilePhoto];
}


-(void)setProfilePhoto
{
    imgBgProfileHeightConstraint.constant = ScreenHeight / 2;
    
    NSString *profilePic = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbUserProfilePic"];
    NSData *profileImageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbUserProfilePicData"];
    
    [imgBgProfile setContentMode:UIViewContentModeTop];
    [imgBgProfile setClipsToBounds:YES];
    
    if (profileImageData)
    {
        [imgBgProfile setImage:[[XmppFriendHandler sharedInstance] blurWithCoreImage:[UIImage imageWithData:profileImageData]]];
    }
    else
    {
        [imgBgProfile setIsForSmallCollectionPic:YES];
        imgBgProfile.contentMode = UIViewContentModeTop;// UIViewContentModeTop;
        
        NSURL *url = [NSURL URLWithString:profilePic];
        [imgBgProfile setImageURL:url];
        
    }
    
    [imgBgProfile setClipsToBounds:YES];
    
}




-(void)initialSetupForFriend
{
    if([currentChatObj friend_DisplayName].length)
        _lblName.text = [currentChatObj friend_DisplayName];
    else
        _lblName.text = [currentChatObj friend_Name];
    
    if (currentChatObj.profileImage.length)
    {
        imgFriend.image =[UIImage imageWithData:currentChatObj.profileImage];
    }
    else
        imgFriend.image =[UIImage imageNamed:@"friend.png"];
    
    
    imgFriend.layer.cornerRadius = imgFriend.frame.size.height / 2;
    imgFriend.clipsToBounds = YES;
    
    userImageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbUserProfilePicData"];
    
   [tblViewForChatting setBackgroundColor:[UIColor whiteColor]];
    
    [_txtForChat setPlaceholder:@"Type a message..."];
    
    
    if ([[XmppCommunicationHandler sharedInstance] xmppStream].isConnected)
    {
        lblTypingStatus.text = currentChatObj.presenceStatus;
    }
    else
        lblTypingStatus.text = @"Offline";
    
    
    
    /* if ([currentChatObj.isBlocked isEqualToString:@"YES"])
     arrMoreOptions = [[NSMutableArray alloc] initWithObjects:@"Clear Conversation",@"UnBlock", nil];
     else
     arrMoreOptions = [[NSMutableArray alloc] initWithObjects:@"Clear Conversation",@"Block", nil];*/
    
    
    // [[XmppCommunicationHandler sharedInstance] getLastSeenStatusForFriendName:[currentChatObj friend_Name]];

}


-(void)presenceUpdated:(NSNotification *)_notificationObj
{
    XmppFriend *friendObj= (XmppFriend *)[[_notificationObj userInfo] valueForKey:@"friendObj"];
    NSString *presentStatus = [[_notificationObj userInfo] valueForKey:@"status"];
    if ([friendObj.friend_Name isEqualToString:currentChatObj.friend_Name])
    {
        lblTypingStatus.text = presentStatus;
    }
   
}

//by sanket for update the status of message

-(void)messageStatusUpdate: (NSNotification *)_notificationObj
{
    NSMutableDictionary *dictMsg= [NSMutableDictionary dictionaryWithDictionary:[[_notificationObj userInfo] valueForKey:@"msdDict"]];
    
    NSString *msgStatus = [[_notificationObj userInfo] valueForKey:@"status"];
    
    int indx = [currentChatMessageArray indexOfObject:dictMsg];
    
    if (indx <= currentChatMessageArray.count)
    {
        [dictMsg setObject:msgStatus forKey:@"msgStatus"];
        [currentChatMessageArray replaceObjectAtIndex:indx withObject:dictMsg];
        [tblViewForChatting reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

-(void)typingStatusUpdate: (NSNotification *)_notificationObj
{
    NSMutableDictionary *dictMsg= [NSMutableDictionary dictionaryWithDictionary:[_notificationObj userInfo] ];
    
    NSString *status =[dictMsg valueForKey:@"typingStatus"];
    
    if(!status.length)
    {
         lblTypingStatus.text = currentChatObj.presenceStatus;
    }
    else
    {
        lblTypingStatus.text = [dictMsg valueForKey:@"typingStatus"];
    }
}

//by sanket for update the chatlist when new message is receivedce

-(void)getMessage: (NSNotification *)_notificationObj
{
    NSDictionary *dictMsg= [_notificationObj userInfo] ;
    if(dictMsg)
    {
        if([[dictMsg objectForKey:@"senderName"] isEqualToString:[[XmppCommunicationHandler sharedInstance] currentFriendName]])
        {
            [self addMessageToChatList:[dictMsg objectForKey:@"recieverName"] Sender:[dictMsg objectForKey:@"senderName"] Message:[dictMsg objectForKey:@"msg"] MessageID:[dictMsg objectForKey:@"msgID"]];
            
            [self scrollToBottomAnimated];
            
        }
        else
        {
            //[[APP_DELEGATE allChatMessagesArray]addObject:dictMsg];
            
            [tblViewForChatting reloadData];
        }
    }
    else
    {
        [tblViewForChatting reloadData];
    }
    
}


-(void)xmppStreamGetConnected
{
   // if (!lblTypingStatus.text.length)
    {
         lblTypingStatus.text = currentChatObj.presenceStatus;
    }
}



//by sanket for getting users chat messages

-(void)getUsersChatMessages
{
    
    currentChatMessageArray = [[NSMutableArray alloc] init];
    currentChatMessageArray = [[XmppSingleChatHandler sharedInstance] loadAllMesssagesForFriendName:[[XmppCommunicationHandler sharedInstance] currentFriendName]];
    
    if([currentChatMessageArray count] > 0)
    {
        int lastRowNumber = [tblViewForChatting numberOfRowsInSection:0] - 1;
        NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
        [tblViewForChatting scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    /*
     if([APPDELEGATE allChatMessagesArray] >0)
     {
     for (int i=0; i<[[APPDELEGATE allChatMessagesArray] count]; i++)
     {
     NSMutableDictionary *getDict = [[APPDELEGATE allChatMessagesArray] objectAtIndex:i];
     if(([[getDict objectForKey:@"senderName"] isEqualToString:MY_USER_NAME] && [[getDict objectForKey:@"recieverName"] isEqualToString:[APPDELEGATE currentFriendName]]) || ([[getDict objectForKey:@"recieverName"] isEqualToString:MY_USER_NAME] && [[getDict objectForKey:@"senderName"] isEqualToString:[APPDELEGATE currentFriendName]]))
     {
     [currentChatMessageArray addObject:getDict];
     }
     
     }
     [tblViewForChatting reloadData];
     
     
     
     if([currentChatMessageArray count] > 0)
     {
     int lastRowNumber = [tblViewForChatting numberOfRowsInSection:0] - 1;
     NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
     [tblViewForChatting scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
     }
     */
    
}





-(void)ScreemTapped  // Screen Tapped
{
    //[viewForChatSetting setHidden:YES];
   /* [UIView animateWithDuration:0.33 animations:^{
        if ([UIScreen mainScreen].bounds.size.height>480)
        {
            [viewForChatSetting setFrame:CGRectMake(-viewForChatSetting.frame.size.width, 20, viewForChatSetting.frame.size.width, 558)];
            [viewBackGround setFrame:CGRectMake(2, 0, viewBackGround.frame.size.width, viewBackGround.frame.size.height)];
        }
        else
        {
            [viewForChatSetting setFrame:CGRectMake(-viewForChatSetting.frame.size.width, 20, viewForChatSetting.frame.size.width, 558)];
            [viewBackGround setFrame:CGRectMake(2, 0, viewBackGround.frame.size.width, viewBackGround.frame.size.height)];
        }
        
    } completion:^(BOOL finished) {
        
    }];
    Animation=NO;*/
}
-(void)ScreenSwipped // Screen Swipped
{
    
    [UIView animateWithDuration:0.33 animations:^{
        
        [viewForChatSetting setFrame:CGRectMake(-viewForChatSetting.frame.size.width, 20, viewForChatSetting.frame.size.width, 558)];
        [viewBackGround setFrame:CGRectMake(2, 0, viewBackGround.frame.size.width, viewBackGround.frame.size.height)];
        
    } completion:^(BOOL finished) {
        
    }];
    Animation=NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Table view delegates

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;
    CellIdentifier=@"ChatMessageBubble";
    ChatMessageBubble *cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ChatMessageBubble" owner:self options:nil] objectAtIndex:0];
    }
    
    cell.contentView.tag=indexPath.row;
    cell.parent=self;
    
    NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:[currentChatMessageArray objectAtIndex:indexPath.row]] ;
    
    [cell setData:indexPath.row dictForChat:dict];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    NSString *senderName = [dict objectForKey:@"senderName"];
    if([senderName isEqualToString:MY_USER_NAME])
    {
        cell.imgFriend.hidden = YES;
    }
    else
    {
        cell.imgUser.hidden = YES;
        UIImage *imgFriendDP = [UIImage imageWithData:[currentChatObj profileImage]];
        if(imgFriendDP)
        {
            cell.imgFriend.image = imgFriendDP;
        }
    }
   
    
    return cell;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dict = (NSDictionary *)[currentChatMessageArray objectAtIndex:indexPath.row];
    NSString *currentMsg = [dict objectForKey:@"msg"];
    NSString *currentMsgTime;
    
    if ([currentMsg rangeOfString:@"#$"].location != NSNotFound)
    {
        NSArray* tempArr = [currentMsg componentsSeparatedByString: @"#$"];
        
        currentMsgTime = [tempArr objectAtIndex:[tempArr count]-1 ];
        
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
        
        currentMsg = tempStr2;
    }
    
     NSString *senderName = [dict objectForKey:@"senderName"];
    if([senderName isEqualToString:MY_USER_NAME])
    {
        CGSize  maximumLabelSize = CGSizeMake(ScreenWidth - 126,9999);
        CGSize expectedMsgSize = [currentMsg sizeWithFont:[UIFont systemFontOfSize:16]
                                        constrainedToSize:maximumLabelSize
                                            lineBreakMode:NSLineBreakByTruncatingTail];
        
        return expectedMsgSize.height+50;
    }
    else
    {
        CGSize  maximumLabelSize = CGSizeMake(ScreenWidth - 150,9999);
        CGSize expectedMsgSize = [currentMsg sizeWithFont:[UIFont systemFontOfSize:16]
                                        constrainedToSize:maximumLabelSize
                                            lineBreakMode:NSLineBreakByTruncatingTail];
        
        return expectedMsgSize.height+50;
    }

    return 50;
}



- (float) getHeightForCell : (NSString *) message{
    float height = 0.0f;
    height += [self getHeightOfString:message forSize:CGSizeMake(ScreenWidth - 210, 9999.0f)];
    return height;
}

- (CGFloat) getHeightOfString: (NSString *) string forSize: (CGSize) size{
    
    CGSize stringSize = [string sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:size lineBreakMode:NSLineBreakByTruncatingTail];
  
    return stringSize.height;
}


// Table View Method..
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [currentChatMessageArray count];
}


#pragma mark TextField Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self sendTypingStatus:MESSAGE_TYPING_CONS];
    
    if([UIScreen mainScreen].bounds.size.height>480)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationDelay:0.0];
        
        [UIView setAnimationBeginsFromCurrentState:YES];
        viewBackGround.frame=CGRectMake(2, 0, viewBackGround.frame.size.width, viewBackGround.frame.size.height);
        [self.viewSend setFrame:CGRectMake(self.viewSend.frame.origin.x, 312-50, self.viewSend.frame.size.width, self.viewSend.frame.size.height)];
        [self.tblViewForChatting setFrame:CGRectMake(self.tblViewForChatting.frame.origin.x, -164-50, self.tblViewForChatting.frame.size.width, self.tblViewForChatting.frame.size.height)];
        [UIView commitAnimations];
        //  Code For hide Menu List..
        [viewForChatSetting setHidden:YES];
        Animation=NO;
        
    }
    else
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationDelay:0.0];
        
        [UIView setAnimationBeginsFromCurrentState:YES];
        viewBackGround.frame=CGRectMake(2, 0, viewBackGround.frame.size.width, viewBackGround.frame.size.height);
        [self.viewSend setFrame:CGRectMake(self.viewSend.frame.origin.x, 223-50, self.viewSend.frame.size.width, self.viewSend.frame.size.height)];
        [self.tblViewForChatting setFrame:CGRectMake(self.tblViewForChatting.frame.origin.x, -150-50, self.tblViewForChatting.frame.size.width, self.tblViewForChatting.frame.size.height)];
        [UIView commitAnimations];
        [viewForChatSetting setHidden:YES];
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([UIScreen mainScreen].bounds.size.height>480)
    {
        [self.txtForChat resignFirstResponder];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationDelay:0.0];
        
        [UIView setAnimationBeginsFromCurrentState:YES];
        [self.viewSend setFrame:CGRectMake(self.viewSend.frame.origin.x, 525, self.viewSend.frame.size.width, self.viewSend.frame.size.height)];
        [self.tblViewForChatting setFrame:CGRectMake(self.tblViewForChatting.frame.origin.x, 64, self.tblViewForChatting.frame.size.width, self.tblViewForChatting.frame.size.height)];
        [UIView commitAnimations];
    }
    else
    {
        [self.txtForChat resignFirstResponder];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationDelay:0.0];
        
        [UIView setAnimationBeginsFromCurrentState:YES];
        [self.viewSend setFrame:CGRectMake(self.viewSend.frame.origin.x, 437, self.viewSend.frame.size.width, self.viewSend.frame.size.height)];
        [self.tblViewForChatting setFrame:CGRectMake(self.tblViewForChatting.frame.origin.x, 64, self.tblViewForChatting.frame.size.width, self.tblViewForChatting.frame.size.height)];
        [UIView commitAnimations];
    }
    return YES;
}

#pragma mark Button Action
- (IBAction)btnBackTpped:(id)sender
{
    //set app delegate current friendname equals to ""
    [[XmppCommunicationHandler sharedInstance] setCurrentFriendName:@""];
    
    if (isFromNewMatch)
    {
        [self.navigationController popViewControllerAnimated:NO];
        
        if ([self.delegate respondsToSelector:@selector(popFromChttingView)])
        {
            [self.delegate popFromChttingView];
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(popFromChttingView)])
        {
            [self.delegate popFromChttingView];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
   
    
  /*  if (currentChatMessageArray.count)
    {
        NSDictionary *dict = [currentChatMessageArray lastObject];
        NSString *senderName = [dict objectForKey:@"senderName"];
        NSString *recieverName = [dict objectForKey:@"recieverName"];
        NSString *currentMsg= [dict objectForKey:@"msg"];
        NSString *currentMsgTime ;
        NSString *msgStatus = @"";
        
        if ([currentMsg rangeOfString:@"#$"].location != NSNotFound)
        {
            NSArray* tempArr = [currentMsg componentsSeparatedByString: @"#$"];
            currentMsgTime = [tempArr objectAtIndex:[tempArr count]-1 ];
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
            currentMsg = tempStr2;
        }
        
        
        currentMsgTime = [self converttoDate:currentMsgTime];
        
        CGSize maximumLabelSize;
        
        if([senderName isEqualToString:MY_USER_NAME])
            maximumLabelSize = CGSizeMake(ScreenWidth - 140,9999);
        else
            maximumLabelSize = CGSizeMake(ScreenWidth - 150,9999);
        
        
        if([senderName isEqualToString:MY_USER_NAME])
        {
            msgStatus = [dict valueForKey:@"msgStatus"];
        }
        
        [[XmppFriendHandler sharedInstance] updatePendingMessageOfFriend:[currentChatObj friend_Name] message:currentMsg messageTime:currentMsgTime messageStatus:msgStatus];
        
    }*/
    
  
}





- (IBAction)btnSendTapped:(id)sender
{
    
    if ([_txtForChat.text length] && [currentChatObj.isBlocked isEqualToString:@"NO"])
    {
        [self sendMesasage];
        
        [self.txtForChat setText:@""];
        [self.txtForChat resignFirstResponder];
        
        vwSendHeightConst.constant = 50 ;
        
        [self performSelector:@selector(scrollToBottomAnimated) withObject:nil afterDelay:.02];
        //[self scrollToBottomAnimated];
    }
}

#pragma mark -- send msg

-(void)sendMesasage
{
    
    [[LogEvents sharedInstance] logEventWithType:@"User Matching" Name:@"Matches - Write Message" Trigger:@"User Taps" SectionApp:@"Section of App"];
    
    // if ([AMNSupprot isNetworkAvailable])
    {
        //[APP_DELEGATE setXMPPDelegate:self];
        [[XmppCommunicationHandler sharedInstance] connect];
    }
    
    NSString *msgStr = [self.txtForChat.text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSString *recieverName = [currentChatObj friend_Name];
    NSString *recieverJid = [NSString stringWithFormat:@"%@@%@/%@",recieverName,CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
    NSString *senderJid = [NSString stringWithFormat:@"%@@%@/%@",MY_USER_NAME,CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
    
    NSDate *newDate = [NSDate date];
    NSInteger timestampMin = [newDate timeIntervalSince1970];
    NSString *temp =[msgStr stringByAppendingString:@"#$"];
    
    NSString *msgWithTime = [temp stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)timestampMin]];
    
    
    NSLog(@"msg with time=====%@",msgWithTime);
    
    NSString *messageID=[[[XmppCommunicationHandler sharedInstance] xmppStream] generateUUID];
    
    [self addMessageToChatList:recieverName Sender:MY_USER_NAME Message:msgWithTime MessageID:messageID];
    
    
    
    [[XmppCommunicationHandler sharedInstance] saveSingleChatMessage:recieverName Sender:MY_USER_NAME Message:msgWithTime MessageID:messageID];
    
    NSString *timeStamp = [AMNSupprot getTimeStampWithDate:[NSDate date]];
   // [[XmppFriendHandler sharedInstance] updatePendingMessageOfFriend:recieverName message:msgWithTime messageTime:timeStamp];
    
    
    if ([currentChatObj.presenceStatus isEqualToString:@"Offline"])
    {
        [self sendMessageAsPushNotification:currentChatObj.friend_Name Message:msgStr MessageID:messageID MessageType:@"chat"];
         //[[XmppCommunicationHandler sharedInstance] sendMessage:recieverJid Sender:senderJid Message:msgWithTime MessageID:messageID MessageType:@"chat"];
        if ([[[XmppCommunicationHandler sharedInstance] xmppStream] isConnected])
        {
            [[XmppCommunicationHandler sharedInstance] sendMessage:recieverJid Sender:senderJid Message:msgWithTime MessageID:messageID MessageType:@"chat"];
            [[XmppFriendHandler sharedInstance] updatePendingMessageOfFriend:recieverName message:msgWithTime messageTime:timeStamp messageStatus:@"S" messageID:messageID];
        }
        else
            [[XmppFriendHandler sharedInstance] updatePendingMessageOfFriend:recieverName message:msgWithTime messageTime:timeStamp messageStatus:@"W" messageID:messageID];

    }
    else
    {
        [[XmppCommunicationHandler sharedInstance] sendMessage:recieverJid Sender:senderJid Message:msgWithTime MessageID:messageID MessageType:@"chat"];
        [[XmppFriendHandler sharedInstance] updatePendingMessageOfFriend:recieverName message:msgWithTime messageTime:timeStamp messageStatus:@"W" messageID:messageID];
    }
    
}

-(void)sendMessageAsPushNotification:(NSString *)receiverJID Message:(NSString *)msgWithTime MessageID:(NSString *)messageID MessageType:(NSString *)msgType
{
    [APPDELEGATE showPrgressHudWithText:@"sending..."];
    
    NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *sessionToken = [stdDefaults objectForKey:@"userSessionToken"];
    NSString *deviceID = [stdDefaults objectForKey:@"fbID"];
    
    NSString *msg = msgWithTime;
    NSArray *tempArr = [receiverJID componentsSeparatedByString:@"_"];
     NSString *friendFbID = @"";
    
    if (tempArr.count > 1) {
        friendFbID = [tempArr objectAtIndex:1];
    }
    
    NSString *postMsg = [NSString stringWithFormat:@"ent_sess_token=%@&ent_fbid=%@&ent_user_fbid=%@&ent_message=%@",sessionToken,deviceID,friendFbID,msg];
    NSString *postURL = @"http://128.199.66.75/pyaar/process.php/sendChatPush";
    NSDictionary *matchesDictionary = [WEB_SERVICE_HELPER postMethodWithMsg:postMsg URL:postURL ];//[self postMethod:postMsg :postURL];
    
    [APPDELEGATE removeProgressHud];
    
    if([[matchesDictionary valueForKey:@"errMsg"] isEqualToString:@"Message sent!"])
    {
        
    }
    
    
}


-(NSString *)converttoDate :(NSString *)strTimeSatmp
{
    NSString * timeStampString =[NSString stringWithFormat:@"%@",strTimeSatmp];
    NSTimeInterval _interval=[timeStampString doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSString *resultDate = [[XmppSingleChatHandler sharedInstance] relativeDateStringForDate:date];
    
    return resultDate;
}

//by sanket for update the chatlist when new message is received or sent

-(void)addMessageToChatList:(NSString *)recieverName Sender:(NSString *)senderName Message:(NSString *)mgsString MessageID:(NSString *)msgID
{
    
    NSMutableDictionary *dictMsgObj = [[NSMutableDictionary alloc]initWithObjects:[NSMutableArray arrayWithObjects:senderName,recieverName,mgsString ,msgID,@"W", nil] forKeys:[NSMutableArray arrayWithObjects:@"senderName",@"recieverName",@"msg",@"msgID",@"msgStatus", nil] ];
    
    [currentChatMessageArray addObject:dictMsgObj];
    
    //[[[XmppCommunicationHandler sharedInstance] allChatMessagesArray]addObject:dictMsgObj];
    
    // [tblViewForChatting reloadData];
    [tblViewForChatting beginUpdates];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentChatMessageArray.count-1 inSection:0];
    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
    [tblViewForChatting insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [tblViewForChatting endUpdates];
    
}


- (IBAction)btnClearConversationTapped:(id)sender
{
    
    if ([currentChatMessageArray count] > 0)
    {
        NSString *recieverName = [currentChatObj friend_Name];
        
        NSManagedObjectContext *context = [APPDELEGATE managedObjectContext];
        //NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"SingleChatMessages" inManagedObjectContext:context];
        
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
            //### Error handling.
        }
        else
        {
            //### Error handling.
        }
        
        
        [self getUsersChatMessages];
    }
    
    
    [UIView animateWithDuration:0.33 animations:^{
        if ([UIScreen mainScreen].bounds.size.height>480)
        {
            [viewForChatSetting setFrame:CGRectMake(-viewForChatSetting.frame.size.width, 20, viewForChatSetting.frame.size.width, viewForChatSetting.frame.size.height)];
            [viewBackGround setFrame:CGRectMake(2, viewBackGround.frame.origin.y, viewBackGround.frame.size.width, viewBackGround.frame.size.height)];
        }
        else
        {
            [ viewForChatSetting setFrame: CGRectMake(-viewForChatSetting.frame.size.width, 20,viewForChatSetting.frame.size.width,458) ];
            [viewBackGround setFrame:CGRectMake(2, 0, viewBackGround.frame.size.width, 478)];
        }
    }
     
                     completion:^(BOOL finished) {
                         
                     }];
    Animation=NO;
    
    
}


- (void )keyboardWillShow1:(NSNotification *)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    keyBoardHeight = keyboardFrameBegin.CGRectValue.size.height;
    vwSendBottomSpaceContraint.constant = keyBoardHeight;
    tblChatBottomSpaceContstraint.constant = 0;
    [self performSelector:@selector(scrollToBottomAnimated) withObject:nil afterDelay:0.1];
    [self sendTypingStatus:MESSAGE_TYPING_CONS];
}

- (void)keyboardWillHide1:(NSNotification*)notification
{
    vwSendBottomSpaceContraint.constant = 0;
    tblChatBottomSpaceContstraint.constant = 0;
    
    [self performSelector:@selector(scrollToBottomAnimated) withObject:nil afterDelay:0.1];
    [self sendTypingStatus:MESSAGE_TYPING_CANCEL_CONS];
}

- (void)scrollToBottomAnimated
{
    NSInteger rows = [self.tblViewForChatting numberOfRowsInSection:0];
    
    if(rows > 0) {
        [self.tblViewForChatting scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                                       atScrollPosition:UITableViewScrollPositionBottom
                                               animated:YES];
    }
}

#pragma mark TextView Delegate
-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0)
    {
        [textView resignFirstResponder];
        // [self sendTypingStatus:@""];
    }
    
    
    BOOL isHeightChnaged;
    int oldHeight = vwSendHeightConst.constant;
    
    if (vwSendHeightConst.constant <=100)
    {
        int height =  (int)[self getHeightOfString:textView.text forSize:CGSizeMake(_txtForChat.frame.size.width-10, 1000.0f)];
        
         //vwSendHeightConst.constant = height + 25;
        
        if (height + 25 > 50)
        {
            vwSendHeightConst.constant = height + 25;
        }
        else
        {
            vwSendHeightConst.constant = 50;
        }
    }
    else
    {
        CGFloat height =  [self getHeightOfString:textView.text forSize:CGSizeMake(_txtForChat.frame.size.width-10, 1000.0f)];
        
        if (height + 25 < 100)
        {
            vwSendHeightConst.constant = height + 25;
        }
    }
    
   // newHeight = vwSendHeightConst.constant ;
    if (oldHeight != vwSendHeightConst.constant) {
        isHeightChnaged = YES;
    }
    
    if (isHeightChnaged)
    {
        [self performSelector:@selector(scrollToBottomAnimated) withObject:nil afterDelay:0.1];
    }
    
    
}


#pragma mark -- sending Typing Status
-(void)sendTypingStatus:(NSString *)typingStatus
{
    //if ([AMNSupprot isNetworkAvailable])
    {
        
        //[APP_DELEGATE setXMPPDelegate:self];
        [[XmppCommunicationHandler sharedInstance] connect];
    }
    
    NSString *recieverJid = [NSString stringWithFormat:@"%@@%@/%@",[currentChatObj friend_Name],CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
    NSString *senderJid = [NSString stringWithFormat:@"%@@%@/%@",MY_USER_NAME,CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
    
    NSString *messageID=[[[XmppCommunicationHandler sharedInstance] xmppStream] generateUUID];
    
    if (is_OPEN_FIRE)
    {
          [[XmppCommunicationHandler sharedInstance] sendMessage:recieverJid Sender:senderJid Message:typingStatus MessageID:messageID MessageType:@"chat"];
    }
    else
    {
        [[XmppCommunicationHandler sharedInstance] sendMessage:recieverJid Sender:senderJid Message:typingStatus MessageID:messageID MessageType:MESSAGE_TYPING_CONS];
    }
        
    
}


#pragma mark -- more options

- (IBAction)btnMoreTapped:(id)sender
{
    if ([currentChatObj.isBlocked isEqualToString:@"YES"])
    {
        UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"Select option:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                      @"Clear Conversation",@"UnBlock",nil];
        actionsheet.tag = 1;
        [actionsheet showInView:[UIApplication sharedApplication].keyWindow];
    }
    else
    {
        UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"Select option:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                      @"Clear Conversation",@"Block",nil];
        actionsheet.tag = 1;
        [actionsheet showInView:[UIApplication sharedApplication].keyWindow];
    }
}
#pragma mark -- action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionsheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (actionsheet.tag == 1)
    {
        switch (buttonIndex) {
            case 0:
                [self clearConversation];
                break;
                
            case 1:
                if ([[actionsheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Block"])
                {
                    [[XmppFriendHandler sharedInstance] blockFriend:currentChatObj.friend_Name];
                }
                else
                {
                    [[XmppFriendHandler sharedInstance] unBlockFriend:currentChatObj.friend_Name];
                }
                break;
                
                
            default:
                break;
                
        }
    }
    
}


-(void)clearConversation
{
    if ([currentChatMessageArray count] > 0)
    {
        [[XmppSingleChatHandler sharedInstance] clearConversationForFriendName:currentChatObj.friend_Name];
        [currentChatMessageArray removeAllObjects];
        [tblViewForChatting reloadData];
        //[self getUsersChatMessages];
    }
    
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *_currentView in actionSheet.subviews)
    {
        if ([_currentView isKindOfClass:[UILabel class]])
        {
            [((UILabel *)_currentView) setFont:[UIFont boldSystemFontOfSize:15.f]];
             [((UILabel *)_currentView) setTextColor:[UIColor lightGrayColor]];
        }
    }
}



- (IBAction)btnPushNotificationTapped:(id)sender
{
    AppSettingsVC *prefVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AppSettingsVC"];
    [self.navigationController pushViewController:prefVC animated:YES];
    
   // [self.navigationController popViewControllerAnimated:NO];
   // [self.tabBarController setSelectedIndex:2];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"GoToPreferencesForPushSetting" object:nil];
    
}

- (IBAction)btnInfoTapped:(id)sender
{
    NSMutableDictionary *dictMachedFriend = [[NSMutableDictionary alloc] init];
    NSArray *tempArr = [currentChatObj.friend_Name componentsSeparatedByString:@"_"];
    
    if (tempArr.count >= 2) {
        
        [[LogEvents sharedInstance] logEventWithType:@"User Matching" Name:@"Matches - View users profile" Trigger:@"User Taps" SectionApp:@"Section of App"];
        [dictMachedFriend setObject:[tempArr objectAtIndex:1] forKey:@"FBId"];
        
        InfoViewController *infoVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"InfoVC"];
        [infoVC setCurrentFriendObj:dictMachedFriend];
        [infoVC setIsFromMatchesVC:YES];
        
        //infoVC.delegate = self;
        [self.navigationController pushViewController:infoVC animated:YES];
 
    }
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // return YES (the default) to allow the gesture recognizer to examine the touch object, NO to prevent the gesture recognizer from seeing this touch object.
    if([touch.view isKindOfClass: [UIButton class]] == YES)
    {
        return YES;
    }
    else if([touch.view isKindOfClass: [UITextView class]] == YES)
    {
        
    }
    else
    {
        [self.view endEditing:YES];
    }
    
    return YES;
}


@end
