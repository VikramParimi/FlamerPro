//
//  Created by Jesse Squires
//  http://www.hexedbits.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSMessagesViewController
//
//
//  The MIT License
//  Copyright (c) 2013 Jesse Squires
//  http://opensource.org/licenses/MIT
//

#import "JSDemoViewController.h"
#import "Helper.h"
#import "AFNHelper.h"
#import "ProfileVC.h"
#import "SingleChatMessage.h"
#import "EBTinderClient.h"

//#import "NSData+Base64Encoding.h"
#import "XmppFriendHandler.h"

@implementation JSDemoViewController
{
    NSData *userImageData;
    NSMutableArray *currentChatMessageArray;
    UIView *vwInitialPopupForNewMatched;
}

@synthesize currentChatObj;
@synthesize currentMessage;
@synthesize customSlidingView;

#pragma mark -
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.delegate = self;
    self.dataSource = self;
    [self getUsersChatMessages];
    
    [super viewDidLoad];
    
    [self addBack:self.navigationItem];
    [self addrightButton:self.navigationItem];
    [self setCustomNavBarTitleView];
  
    self.messageInputView.textView.placeHolder = @"Message";
   
    [self setBackgroundColor:[UIColor whiteColor]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMessage:) name:@"recieveMessage" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageStatusUpdate:) name:NOTIFICATION_XMPP_MESSAGE_STATUS_CHANGED object:nil];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(typingStatusUpdate:) name:NOTIFICATION_XMPP_MESSAGE_RECEIVE_TYPING_STATUS object:nil];
    
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(xmppStreamGetConnected) name:NOTIFICATION_XMPP_STREAM_CONNECTED object:nil] ;
  
    userImageData = [USERDEFAULT objectForKey:PARAM_ENT_PROFILE_PIC_DATA];
   
}

-(void)setCustomNavBarTitleView
{
    UIView *iv = [[UIView alloc] initWithFrame:CGRectMake(0,0,100,44)];
    EGOImageView *imgUser =[[EGOImageView alloc]initWithFrame:CGRectMake(0,5, 34, 34)];
    UILabel *lblName =[[UILabel alloc]initWithFrame:CGRectMake(36, 7, 60, 30)];
    [lblName setTextAlignment:NSTextAlignmentLeft];
    [lblName setTextColor:[UIColor blackColor]];
    [lblName setFont:[UIFont systemFontOfSize:14.0]];
    [imgUser.layer setCornerRadius:17.0];
    [imgUser.layer setMasksToBounds:YES];
    
    imgUser.image = [UIImage imageWithData:currentChatObj.profileImage];
    lblName.text = currentChatObj.friend_DisplayName;
    [iv addSubview:lblName];
    [iv addSubview:imgUser];
    
    //Calculate the expected size based on the font and linebreak mode of your label
    CGSize maximumLabelSize = CGSizeMake(150,9999);
    
    CGSize expectedLabelSize = [currentChatObj.friend_DisplayName sizeWithFont:lblName.font
                                                             constrainedToSize:maximumLabelSize
                                                                 lineBreakMode:lblName.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = lblName.frame;
    newFrame.size.width = expectedLabelSize.width;
    lblName.frame = newFrame;

    CGRect newVwFrame = iv.frame;
    newVwFrame.size.width = imgUser.frame.size.width+lblName.frame.size.width+2;
    iv.frame = newVwFrame;
    
    self.navigationItem.titleView = iv;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)addInitialPopupForNewMatched
{
    vwInitialPopupForNewMatched = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 300)];
    UILabel *lblName =[[UILabel alloc]initWithFrame:CGRectMake(10, 10, 180, 30)];
    UILabel *timeAgo =[[UILabel alloc]initWithFrame:CGRectMake(10, 30, 180, 40)];
    EGOImageView *imgUser =[[EGOImageView alloc]initWithFrame:CGRectMake(45, 80, 100, 100)];
    UILabel *lblSuggest =[[UILabel alloc]initWithFrame:CGRectMake(10, 180, 180, 60)];
    
    [lblName setTextAlignment:NSTextAlignmentCenter];
    [timeAgo setTextAlignment:NSTextAlignmentCenter];
    [lblSuggest setTextAlignment:NSTextAlignmentCenter];
    
    [timeAgo setFont:[UIFont fontWithName:HELVETICALTSTD_ROMAN size:18.0]];
    [lblSuggest setFont:[UIFont fontWithName:HELVETICALTSTD_LIGHT size:16.0]];

    [lblName setTextColor:[UIColor blackColor]];
    [timeAgo setTextColor:[UIColor blackColor]];
    [lblSuggest setTextColor:[UIColor blackColor]];
    [lblSuggest setNumberOfLines:2];
    [imgUser.layer setCornerRadius:50.0];
    [imgUser.layer setMasksToBounds:YES];
    
    [vwInitialPopupForNewMatched addSubview:lblName];
    [vwInitialPopupForNewMatched addSubview:timeAgo];
    [vwInitialPopupForNewMatched addSubview:imgUser];
    [vwInitialPopupForNewMatched addSubview:lblSuggest];
    [vwInitialPopupForNewMatched setBackgroundColor:[UIColor whiteColor]];
    
    NSMutableAttributedString * stringName = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"You matched with %@",currentChatObj.friend_DisplayName]];
    [stringName addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0,16)];
    [stringName addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:NSMakeRange(16,currentChatObj.friend_DisplayName.length)];
    lblName.attributedText = stringName;
    
    if (currentChatObj.lastMessageTime.length)
    {
        NSDate *dateCreated = [[UtilityClass sharedObject]stringToDate:currentChatObj.lastMessageTime withFormate:@"yyyy-MM-dd HH:mm:ss"];
        NSString *difference = [[UtilityClass sharedObject]prettyTimestampSinceDate:dateCreated];
        timeAgo.text = difference;

    }
    else
    {
        timeAgo.text = @"Just Now";
    }
    imgUser.image = [UIImage imageWithData:currentChatObj.profileImage];
    lblSuggest.text = @"Are your hands tied or something?";
    
    [vwInitialPopupForNewMatched setCenter:self.view.center];
    [[super view] addSubview:vwInitialPopupForNewMatched];
    
}

//by sanket for getting users chat messages

-(void)getUsersChatMessages
{
    currentChatMessageArray = [[NSMutableArray alloc] init];
    currentChatMessageArray = [[XmppSingleChatHandler sharedInstance] loadAllMesssagesForFriendName:[[XmppCommunicationHandler sharedInstance] currentFriendName]];
    [self.tableView reloadData];
    
    [self scrollToBottomAnimated:YES];
}

#pragma mark - Xmpp Notification Handlers

//Notification Friend Presence Status
/*-(void)xmppStreamGetConnected
{
    // if (!lblTypingStatus.text.length)
    {
        // l.text = currentChatObj.presenceStatus;
    }
}*/

//Notification Get Message Status Update

-(void)messageStatusUpdate: (NSNotification *)_notificationObj
{
    NSMutableDictionary *dictMsg= [NSMutableDictionary dictionaryWithDictionary:[[_notificationObj userInfo] valueForKey:@"msdDict"]];
    NSString *msgStatus = [[_notificationObj userInfo] valueForKey:@"status"];
    SingleChatMessage *message = [[SingleChatMessage alloc]initWithDict:dictMsg];
    int indx = -1;//= (int)[currentChatMessageArray indexOfObject:message];
    BOOL isExist = NO;
    
    for (int i = 0 ; i < [currentChatMessageArray count] ; i++)//
    {
        SingleChatMessage *msgObj = (SingleChatMessage *)[currentChatMessageArray objectAtIndex:i];
        
        if ([msgObj.messageID isEqualToString:message.messageID])
        {
            indx = i;
            isExist = YES;
            break;
        }
    }
    
    if (indx <= currentChatMessageArray.count && isExist)
    {
        message.messageStatus = msgStatus;
        [currentChatMessageArray replaceObjectAtIndex:indx withObject:message];
        
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indx inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

//Notification Typing Status Update
-(void)typingStatusUpdate: (NSNotification *)_notificationObj
{
    NSMutableDictionary *dictMsg= [NSMutableDictionary dictionaryWithDictionary:[_notificationObj userInfo] ];
    
   // lblTypingStatus.text = [dictMsg valueForKey:@"typingStatus"];
}

//Notification Get New Message

-(void)getMessage: (NSNotification *)_notificationObj
{
    NSArray* msgs = (NSArray*)[_notificationObj userInfo];
    
    if (msgs){
        User* myreceiver = (User*)currentChatObj;
        for(SingleChatMessage* dictMsg in msgs){
            if ([dictMsg.sender isEqualToString:myreceiver.tinderID]){
                [self addMessageToChatList:[User currentUser].name Sender:myreceiver.name Message:dictMsg.message MessageID:dictMsg.messageID MediaType:dictMsg.mediaType];
                [self scrollToBottomAnimated:YES];

            }
        }
    }
    
    /*NSDictionary *dictMsg= [_notificationObj userInfo] ;
    if(dictMsg)
    {
        if([[dictMsg objectForKey:@"senderName"] isEqualToString:[[XmppCommunicationHandler sharedInstance] currentFriendName]])
        {
            [self addMessageToChatList:[dictMsg objectForKey:@"recieverName"] Sender:[dictMsg objectForKey:@"senderName"] Message:[dictMsg objectForKey:@"msg"] MessageID:[dictMsg objectForKey:@"msgID"] MediaType:[dictMsg objectForKey:@"mediaType"]];
            
            [self scrollToBottomAnimated:YES];
        }
        else
        {
            [self.tableView reloadData];
        }
    }
    else
    {
        [self.tableView reloadData];
    }*/
    
}

#pragma mark -
#pragma mark - NavigationButton Methods

-(void)addrightButton:(UINavigationItem*)naviItem
{
    UIImage *imgButton = [UIImage imageNamed:@"three-dot-icon.png"];
	UIButton *rightbarbutton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightbarbutton setFrame:CGRectMake(0,4,35, 35)];
    [rightbarbutton setImage:imgButton forState:UIControlStateNormal];
    [rightbarbutton addTarget:self action:@selector(btnMorePressed:) forControlEvents:UIControlEventTouchUpInside];
    naviItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightbarbutton];
}

-(void)addBack:(UINavigationItem*)naviItem
{
    UIImage *imgButton = [UIImage imageNamed:@"back-active-icon.png"];
	UIButton *rightbarbutton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightbarbutton setFrame:CGRectMake(0,4,35, 35)];
    [rightbarbutton setImage:imgButton forState:UIControlStateNormal];
    [rightbarbutton addTarget:self action:@selector(buttonBackPressed:) forControlEvents:UIControlEventTouchUpInside];
    naviItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightbarbutton];
}

- (void)buttonBackPressed:(UIBarButtonItem *)sender
{
    //reset current chat friendname
    [[XmppCommunicationHandler sharedInstance] setCurrentFriendName:@""];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_CHATSCREEN_REFRESH object:nil];
    [[APPDELEGATE navigationController] popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark - Messages view delegate: REQUIRED

-(void)deleteRowAtIndex:(int)indexOfRow
{
    if (currentChatMessageArray.count>indexOfRow)
    {
        SingleChatMessage *messageToDelete = [currentChatMessageArray objectAtIndex:indexOfRow];
        [[XmppSingleChatHandler sharedInstance] deleteMessageDictWithMessageId:[messageToDelete messageID]];
        [currentChatMessageArray removeObjectAtIndex:indexOfRow];
    }
  
    [self.tableView reloadData];
    
    if ([currentChatMessageArray count])
    {
        SingleChatMessage *lastMsg = [currentChatMessageArray lastObject];
        [[XmppFriendHandler sharedInstance] updatePendingMessageOfFriend:[currentChatObj friend_Name] message:[lastMsg message] messageTime:@"" messageStatus:[lastMsg messageStatus] messageID:[lastMsg messageID]];
        
    }
   
}

-(void)deleteRowsWithIndexes:(NSArray *)arrayIndexs
{
    NSMutableIndexSet * indices = [NSMutableIndexSet indexSet];
    for (NSNumber *numIndx in arrayIndexs)
    {
        if ([currentChatMessageArray objectAtIndex:numIndx.intValue])
        {
            int indexOfRow = numIndx.intValue;
            [indices addIndex:indexOfRow];
            SingleChatMessage *messageToDelete = [currentChatMessageArray objectAtIndex:indexOfRow];
            [[XmppSingleChatHandler sharedInstance] deleteMessageDictWithMessageId:[messageToDelete messageID]];
            
        }
    }
    
     [currentChatMessageArray removeObjectsAtIndexes:indices];

    
    if ([currentChatMessageArray count])
    {
        SingleChatMessage *lastMsg = [currentChatMessageArray lastObject];
        [[XmppFriendHandler sharedInstance] updatePendingMessageOfFriend:[currentChatObj friend_Name] message:[lastMsg message] messageTime:@"" messageStatus:[lastMsg messageStatus] messageID:[lastMsg messageID]];
        
    }
    
    [self.tableView reloadData];
  
}

-(void)otherAttachPressed
{
    [self disPlayMoreAttachmentOptions];
}

- (void)didSendText:(NSString *)text
{
    if (text.length==0)
    {
        return;
    }
    
    if([currentChatObj.isBlocked isEqualToString:@"NO"])
    {
        self.currentMessage = text;
        [self sendMesasage];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Do you want to unblock user?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alert.tag = 100;
        [alert show];
    }
}

-(void)sendMesasage
{
    [[EBTinderClient sharedClient] sendMessage:currentChatObj message:self.currentMessage onSendCompletion:(SendMessageBlock)^(SingleChatMessage* sndmsg, BOOL success){
        
        if (success && (sndmsg != nil))
        {
            
            NSDate *newDate = [NSDate date];
            NSInteger timestampMin = [newDate timeIntervalSince1970];
            NSString *temp =[self.currentMessage stringByAppendingString:@"#$"];
            NSString *msgWithTime = [temp stringByAppendingString:[NSString stringWithFormat:@"%d",timestampMin]];
            
            
            NSLog(@"msg with time=====%@",msgWithTime);
            [self addMessageToChatList:[User currentUser].name Sender:currentChatObj.name Message:msgWithTime MessageID:sndmsg.messageID MediaType:@""];
            
            //  [[XmppCommunicationHandler sharedInstance] sendMessage:sn Sender:senderJid Message:msgWithTime MessageID:messageID MessageType:@"chat"];
            
            [[XmppCommunicationHandler sharedInstance] saveSingleChatMessage:currentChatObj.name Sender:MY_USER_NAME Message:msgWithTime MessageID:sndmsg.messageID MediaType:@""];
            
            // NSString *timeStamp = [UtilityClass getTimeStampWithDate:[NSDate date]];
            
            // [[XmppFriendHandler sharedInstance] updatePendingMessageOfFriend:recieverName message:msgWithTime messageTime:timeStamp messageStatus:@"W" messageID:messageID];
            
            [self finishSend];
            [self scrollToBottomAnimated:YES];
        }
    }];
    
    //origin.
    
      /*  NSString *recieverName = [currentChatObj friend_Name];
        NSString *recieverJid = [NSString stringWithFormat:@"%@@%@/%@",recieverName,CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
        NSString *senderJid = [NSString stringWithFormat:@"%@@%@/%@",MY_USER_NAME,CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
        
        NSDate *newDate = [NSDate date];
        NSInteger timestampMin = [newDate timeIntervalSince1970];
        NSString *temp =[self.currentMessage stringByAppendingString:@"#$"];
        
        NSString *msgWithTime = [temp stringByAppendingString:[NSString stringWithFormat:@"%d",timestampMin]];
        
        
        NSLog(@"msg with time=====%@",msgWithTime);
        
        NSString *messageID=[[[XmppCommunicationHandler sharedInstance] xmppStream] generateUUID];
        
        [self addMessageToChatList:recieverName Sender:MY_USER_NAME Message:msgWithTime MessageID:messageID MediaType:@""];
    
                [[XmppCommunicationHandler sharedInstance] sendMessage:recieverJid Sender:senderJid Message:msgWithTime MessageID:messageID MessageType:@"chat"];
        
        [[XmppCommunicationHandler sharedInstance] saveSingleChatMessage:recieverName Sender:MY_USER_NAME Message:msgWithTime MessageID:messageID MediaType:@""];
        
        NSString *timeStamp = [UtilityClass getTimeStampWithDate:[NSDate date]];
        
        [[XmppFriendHandler sharedInstance] updatePendingMessageOfFriend:recieverName message:msgWithTime messageTime:timeStamp messageStatus:@"W" messageID:messageID];

        [self finishSend];
        [self scrollToBottomAnimated:YES];*/
}


#pragma mark -
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return currentChatMessageArray.count;
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SingleChatMessage *message = [currentChatMessageArray objectAtIndex:indexPath.row];
    NSString *senderName = message.sender;
    
    if ([message.mediaType isEqualToString:@"IMAGE"] )
    {
        if([senderName isEqualToString:MY_USER_NAME])
        {
            return  JSBubbleMessageTypeOutgoingImage;
        }
        else
        {
            return JSBubbleMessageTypeIncomingImage;
        }
    }
    else
    {
        if([senderName isEqualToString:MY_USER_NAME])
        {
            return  JSBubbleMessageTypeOutgoing;
        }
        else
        {
            return JSBubbleMessageTypeIncoming;
        }
    }
   
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SingleChatMessage *message = [currentChatMessageArray objectAtIndex:indexPath.row];
    NSString *senderName = message.sender;
    if(![senderName isEqualToString:MY_USER_NAME])
    {
        return  [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_iOS7lightGrayColor]];
    }
    else
    {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_iOS7blueColor]];
    }
}

#pragma mark - Message view Configuration Delegates

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
    return JSMessagesViewTimestampPolicyEveryThree;
}

- (JSMessagesViewAvatarPolicy)avatarPolicy
{
    return JSMessagesViewAvatarPolicyAll;
}

- (JSMessagesViewSubtitlePolicy)subtitlePolicy
{
    return JSMessagesViewSubtitlePolicyAll;
}

- (JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat;
}

#pragma mark - Messages view delegate: OPTIONAL

//
//  *** Implement to customize cell further
//
- (void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if([cell messageType] == JSBubbleMessageTypeOutgoing)
    {
        [cell.bubbleView setTextColor:[UIColor whiteColor]];
    }
    else
    {
        [cell.bubbleView setTextColor:[UIColor blackColor]];
    }
    if(cell.timestampLabel)
    {
        cell.timestampLabel.textColor = [UIColor lightGrayColor];
        cell.timestampLabel.shadowOffset = CGSizeZero;
    }
    if(cell.subtitleLabel)
    {
        cell.subtitleLabel.textColor = [UIColor lightGrayColor];
    }
}

- (BOOL)shouldPreventScrollToBottomWhileUserScrolling
{
    return YES;
}

#pragma mark - Messages view data source: REQUIRED

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SingleChatMessage *message = [currentChatMessageArray objectAtIndex:indexPath.row];
    NSString *currentMsg = message.message;
    
    NSString *currentMsgTime ;
    
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
    
    return currentMsg;
}


- (NSString *)imageUrlForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SingleChatMessage *message = [currentChatMessageArray objectAtIndex:indexPath.row];
    NSString *currentMsg = message.message;
    
    NSString *currentMsgTime ;
    
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
    
    return currentMsg;
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SingleChatMessage *message = [currentChatMessageArray objectAtIndex:indexPath.row];
    NSString *currentMsg = message.message;
    
    NSString *currentMsgTime ;
    
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

    NSString *dateWhenMsgWritten = currentMsgTime;
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[dateWhenMsgWritten longLongValue]];
    return date;

}

- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SingleChatMessage *message = [currentChatMessageArray objectAtIndex:indexPath.row];
    NSString *senderName = message.sender;
    
    UIImage *img = Nil;
    
    if([senderName isEqualToString:MY_USER_NAME])
    {
        img =  [JSAvatarImageFactory avatarImageWithData:userImageData style:JSAvatarImageStyleFlat shape:JSAvatarImageShapeCircle];
    }
    else
    {
        img =  [JSAvatarImageFactory avatarImageWithData:currentChatObj.profileImage style:JSAvatarImageStyleFlat shape:JSAvatarImageShapeCircle];
    }
    return [[UIImageView alloc] initWithImage:img];

}

- (NSString *)subtitleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SingleChatMessage *message = [currentChatMessageArray objectAtIndex:indexPath.row];
    NSString *senderName = message.sender;
    NSString *currentMessageStatus = message.messageStatus;
    
    if([senderName isEqualToString:MY_USER_NAME])
    {
        return currentMessageStatus;
    }
    else
    {
        return nil;
    }

}

-(void)addSubviewsToSuperViewInitially
{
    if(currentChatMessageArray.count == 0)
    {
        [self addInitialPopupForNewMatched];
    }
}

#pragma mark -
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
     NSString *fbId = [[currentChatObj.friend_Name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]]lastObject];
  
    if(buttonIndex == 1)
    {
        if (alertView.tag == 100)
        {
            // unblock user
            
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            
            [dictParam setObject:[NSString stringWithFormat:@"%d",EntFlagUnblock] forKey:PARAM_ENT_FLAG];
            [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
            [dictParam setObject:fbId forKey:PARAM_ENT_USER_BLOCK_FBID];
            
            AFNHelper *afn=[[AFNHelper alloc]init];
            [afn getDataFromPath:METHOD_BLOCKUSER withParamData:dictParam withBlock:^(id response, NSError *error)
            {
                if (response)
                {
                    if ([[response objectForKey:@"errFlag"] intValue]==0)
                    {
                        [[TinderAppDelegate sharedAppDelegate]showToastMessage:[response objectForKey:@"errMsg"]];
                        [currentChatObj setIsBlocked:@"NO"];
                       
                    }
                }
            }];
            
        }
        else if(alertView.tag == 200)
        {/*block user service call */
           
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            
            [dictParam setObject:[NSString stringWithFormat:@"%d",EntFlagBlock] forKey:PARAM_ENT_FLAG];
            [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
            [dictParam setObject:fbId forKey:PARAM_ENT_USER_BLOCK_FBID];
            
            
            AFNHelper *afn=[[AFNHelper alloc]init];
            [afn getDataFromPath:METHOD_BLOCKUSER withParamData:dictParam withBlock:^(id response, NSError *error)
            {
                if (response)
                {
                    if ([[response objectForKey:@"errFlag"] intValue]==0)
                    {
                        [[TinderAppDelegate sharedAppDelegate]showToastMessage:[response objectForKey:@"errMsg"]];
                        [currentChatObj setIsBlocked:@"YES"];
                        [self clearConversationWithFriend];
                        [self buttonBackPressed:nil];
                    }
                }
            }];
            
        }
        else if(alertView.tag == 300)
        {/*Unmatch user service call */
           
            
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            
            [dictParam setObject:@"submit" forKey:@"ent_submit"];
            [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
            [dictParam setObject:fbId forKey:@"ent_unmatch_user_fbid"];
            
            
            AFNHelper *afn=[[AFNHelper alloc]init];
            [afn getDataFromPath:METHOD_UNMATCH withParamData:dictParam withBlock:^(id response, NSError *error)
             {
                 if (response)
                 {
                     if ([[response objectForKey:@"errFlag"] intValue]==0)
                     {
                         [[TinderAppDelegate sharedAppDelegate]showToastMessage:[response objectForKey:@"errMsg"]];
                         [self clearConversationWithFriend];
                         [self buttonBackPressed:nil];
                     }
                 }
             }];
            
        }
    }
}

#pragma mark-
#pragma mark- MailDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent)
    {
        NSLog(@"It's away!");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

//Adding New Message In ChatList

-(void)addMessageToChatList:(NSString *)recieverName Sender:(NSString *)senderName Message:(NSString *)mgsString MessageID:(NSString *)msgID MediaType:(NSString *)mediaType
{
    
    NSMutableDictionary *dictMsgObj = [[NSMutableDictionary alloc]initWithObjects:[NSMutableArray arrayWithObjects:senderName,recieverName,mgsString ,msgID,@"W",mediaType, nil] forKeys:[NSMutableArray arrayWithObjects:@"senderName",@"recieverName",@"msg",@"msgID",@"msgStatus",@"mediaType", nil] ];
    
    SingleChatMessage *message = [[SingleChatMessage alloc]initWithDict:dictMsgObj];
    
    [currentChatMessageArray addObject:message];
    
    [[[XmppCommunicationHandler sharedInstance] allChatMessagesArray]addObject:dictMsgObj];
    
    if (currentChatMessageArray.count)
    {
        [vwInitialPopupForNewMatched removeFromSuperview];
    }
    
    [self.tableView beginUpdates];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentChatMessageArray.count-1 inSection:0];
    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

#pragma mark - Other Attachment Option Handling
-(void)disPlayMoreAttachmentOptions
{
    UIActionSheet *actionpass;
    
    actionpass = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"TAKE_PHOTO", nil),NSLocalizedString(@"CHOOSE_PHOTO", nil),nil];
    [actionpass showInView:self.view];
}

#pragma mark
#pragma mark - Message Attachment Action to Share

- (void)selectPhotos
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.view.tag=101;
    
    [self presentViewController:imagePickerController animated:YES completion:^{
        
    }];
    
}

-(void)takePhoto
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.view.tag=102;
    
    imagePickerController.sourceType =UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:imagePickerController animated:YES completion:^{
        
    }];
}

#pragma mark
#pragma mark - ImagePickerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info valueForKey:@"UIImagePickerControllerOriginalImage"];
     NSMutableData *mediaData = [UIImageJPEGRepresentation(image, 1.0) mutableCopy];
    
    if(picker.view.tag==101 || picker.view.tag==102)
    {
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            
            image = [[UtilityClass sharedObject] scaleImage:image toSize:CGSizeMake(640, 1136)];  //(640, 1136)
        }
        else {
            
            if (mediaData.length > 2000000) {
                image = [[UtilityClass sharedObject] scaleImage:image toSize:CGSizeMake(640, 1136)]; //(640, 1136)
            }
        }
    
        [self callForWebseviceToUploadMediaToServer:image andImageName:nil];
    }
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


-(void)callForWebseviceToUploadMediaToServer:(UIImage *)imgToShare andImageName : (NSString *)txtImageName
{
    [[ProgressIndicator sharedInstance] showPIOnView:self.view withMessage:nil];
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    
    [afn getDataFromPath:METHOD_UPLOAD_IMAGE withParamDataImage:dictParam andImage:imgToShare withBlock:^(id response, NSError *error) {
        if (response)
        {
            [[ProgressIndicator sharedInstance] hideProgressIndicator];
            if ([[response objectForKey:@"errFlag"] intValue]==0)
            {
                //[[TinderAppDelegate sharedAppDelegate]showToastMessage:[response objectForKey:@"errMsg"]];
                [self sendAttachMent:[response objectForKey:@"url"] Type:@"IMAGE"];
            }
        }
        
    }];
    
}

#pragma mark -- send image

-(void)sendAttachMent:(id)attachMent Type:(NSString *)attachMentType
{
    
    NSString *sendMsgStr = @"";
    
    if ([attachMentType isEqualToString:@"IMAGE"] && [attachMent isKindOfClass:[NSString class]])
    {
        sendMsgStr = attachMent;
    }
   
    NSString *recieverName = currentChatObj.friend_Name;//[currentChatObj valueForKey:@"friendName"];
    NSString *recieverJid = [NSString stringWithFormat:@"%@@%@/%@",recieverName,CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
    NSString *senderJid = [NSString stringWithFormat:@"%@@%@/%@",MY_USER_NAME,CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
    
    NSDate *newDate = [NSDate date];
    NSInteger timestampMin = [newDate timeIntervalSince1970];
    NSString *temp =[attachMentType stringByAppendingString:@"#$"];
    NSString *msgWithTime = [temp stringByAppendingString:[NSString stringWithFormat:@"%d",timestampMin]];
    
    NSString *messageID=[[[XmppCommunicationHandler sharedInstance] xmppStream] generateUUID];
    
    NSString *msgToSave = [sendMsgStr stringByAppendingString:[NSString stringWithFormat:@"#$%d",timestampMin]];
    
    
    //update for configure woth android
    
    NSString *msgWithImgUrlAndTime = [NSString stringWithFormat:@"TindercloneImage_%@#$%@",sendMsgStr, [NSString stringWithFormat:@"%d",timestampMin]];
    
    [[XmppCommunicationHandler sharedInstance] sendImageFile:recieverJid Sender:senderJid Message:msgWithImgUrlAndTime ImageStr:sendMsgStr MessageID:messageID MessageType:@"chat"];

    
   // [[XmppCommunicationHandler sharedInstance] sendImageFile:recieverJid Sender:senderJid Message:msgWithTime ImageStr:sendMsgStr MessageID:messageID MessageType:@"chat"];
    
    [self addMessageToChatList:recieverJid Sender:MY_USER_NAME Message:msgToSave MessageID:messageID MediaType:attachMentType];
    
    [[XmppCommunicationHandler sharedInstance] saveSingleChatMessage:recieverName Sender:MY_USER_NAME Message:msgToSave MessageID:messageID MediaType:attachMentType];
    
}

#pragma mark - More Options Clicked

- (void)btnMorePressed:(UIBarButtonItem *)sender
{
    
    [self.messageInputView.textView endEditing:YES];
    NSString *friendName  = self.currentChatObj.friend_DisplayName;
  
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                                    otherButtonTitles:[NSString stringWithFormat:@"Unmatch %@",friendName],[NSString stringWithFormat:@"Report %@",friendName],@"Delete Message",@"Take Photo",@"Send From Photos", nil];
    
    [actionSheet setTag:100];
    [actionSheet setDelegate:self];
    [actionSheet showInView:self.view];
    
}

#pragma mark - ActionSheet Delegate

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    SEL selector = NSSelectorFromString(@"_alertController");
    if ([actionSheet respondsToSelector:selector])
    {
        UIAlertController *alertController = [actionSheet valueForKey:@"_alertController"];
        if ([alertController isKindOfClass:[UIAlertController class]])
        {
            alertController.view.tintColor = ACTION_SHEET_COLOR;
        }
    }
    else
    {
        // use other methods for iOS 7 or older.
        for (UIView *subview in actionSheet.subviews) {
            if ([subview isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)subview;
                [button setTitleColor:ACTION_SHEET_COLOR forState:UIControlStateNormal];
            }
        }
        
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 100)
    {
        if (buttonIndex == 0)
        {
            [self unmatchUser];
        }
        else if (buttonIndex == 1)
        {
            [self reportUser];
        }
        else if (buttonIndex == 2)
        {
            [self deleteMessage];
        }
        else if (buttonIndex == 3)
        {
            [self takePhoto];
        }
        else if (buttonIndex == 4)
        {
            [self selectPhotos];
        }
    }
}

-(void)showProfile
{
    ProfileVC *vc=[[ProfileVC alloc]initWithNibName:@"ProfileVC" bundle:nil];
    User *user=[[User alloc]init];
    
    NSString *fbId = [[currentChatObj.friend_Name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]]lastObject];
    
    user.fbid=fbId;
    user.first_name=currentChatObj.friend_DisplayName;
    vc.user=user;
    UINavigationController *navVc = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:navVc animated:YES completion:nil];
}

- (void)reportUser
{
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"Flamer App!"];
    [controller setMessageBody:@"" isHTML:NO];
    NSMutableArray *emails = [[NSMutableArray alloc] initWithObjects:@"info@appdupe.com", nil];
    [controller setToRecipients:[NSArray arrayWithArray:(NSArray *)emails]];
    if (controller) [self presentViewController:controller animated:YES completion:nil];
}

- (void)blockUnblockUser
{
    if ([currentChatObj.isBlocked isEqualToString:@"YES"])
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Alert!" message:@"Are you sure you want to Unblock this user?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alertView.tag =100;
        [alertView show];
    }
    else if([currentChatObj.isBlocked isEqualToString:@"NO"])
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Alert!" message:@"Are you sure you want to block this user?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alertView.tag =200;
        [alertView show];
    }
}

- (void)unmatchUser
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Alert!" message:@"Are you sure you want to Unmatch this user?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alertView.tag =300;
    [alertView show];
    
}

-(void)clearConversationWithFriend
{
    if ([currentChatMessageArray count] > 0)
    {
        NSString *recieverName = [currentChatObj friend_Name];
        
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
        }
        
        [self getUsersChatMessages];
    }
}

-(void)deleteMessage
{
    [super deleteMessageTapped];
}

//Hide Status bar
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}


#pragma mark -
#pragma mark - Utility Methods

- (NSDate *) stringFromDate :(NSString *)strDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:strDate];
    return date;
}

- (NSString *) convertGmtToLocal:(NSString *)stringTime
{
    NSString *dateString = @"2013-12-04 11:10:27 GMT";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"EN"]];
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    [dateFormatter setLocale:[NSLocale systemLocale]];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *localDateString = [dateFormatter stringFromDate:date];
    NSDate *lacalDate = [dateFormatter dateFromString:localDateString];
    NSDateFormatter *dateParser = [[NSDateFormatter alloc] init];
    [dateParser setDateFormat:@"dd-MMM-yyy"];
    NSString *chatLocalDateString = [dateParser stringFromDate:lacalDate];
    NSLog(@"Chat date :%@",chatLocalDateString);
    return chatLocalDateString;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


@end