//
//  ChatView.m
//  snapchatclone
//
//  Created by soumya ranjan sahu on 03/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "ChatView.h"
#import "Helper.h"
#import "SenderChatCell.h"
#import "RecieverChatCell.h"
#import "WebServiceHandler.h"
#import "SingleChatTable.h"
#import "GroupChatTable.h"
#import "GroupChatRecieverCell.h"
#import "GroupChatSenderCell.h"
#import "SingleMapSenderCell.h"
#import "SingleMapRecieverCell.h"
#import "GroupMapRecieverCell.h"
#import "GroupMapSenderCell.h"
#import "SingleAudioReceiverCell.h"
#import "SingleAudioSenderCell.h"
#import "GroupAudioReceiverCell.h"
#import "GroupAudioSenderCell.h"
#import "DBHandler.h"

@implementation ChatView

- (void)awakeFromNib
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tapGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];    
    
    self.messageArray = [[NSMutableArray alloc] init];
    [AppData sharedInstance].chatViewObj = self;
    
    viewFullImage = [[UIView alloc]initWithFrame:self.bounds];
    [viewFullImage setBackgroundColor:[UIColor blackColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatLoggedInSuccessfully) name:@"ChatLoggedIn" object:nil];
    
}

- (void)chatLoggedInSuccessfully
{
    [self checkConnection];
    if ([self.snapObject.group_id intValue] != 0) {
        
        [[AppData sharedInstance] createCrowdWithCrowdName:self.snapObject.group_id];
    }
}

- (void)manageLayout
{
    self.isChatViewOpen = YES;
    
    NSString *connection = [AppData checkNetworkConnectivity];
    if ([connection isEqualToString:@"NoAccess"]) {
        
        [AJNotificationView showNoticeInView:self type:AJNotificationTypeRed title:@"No Internet Connection" hideAfter:2.5];
        
        self.connectionTimer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(checkConnection) userInfo:nil repeats:YES];
        
        [self.chatBackView setUserInteractionEnabled:NO];
        [self.headerBackView setUserInteractionEnabled:NO];
    }
    else {
        [AJNotificationView hideCurrentNotificationView];
        [self.headerBackView setUserInteractionEnabled:YES];
        [self.chatBackView setUserInteractionEnabled:YES];
        
        if (![AppData sharedInstance].isLoggedinToXmppServer) {
            
            ProgressIndicator *progressView = [ProgressIndicator sharedInstance];
            [progressView showPIOnView:self withMessage:@"Please wait. Logged In to chat."];
        }
    }
    
    
    int currentUserId = [[USER_DEFAULT valueForKey:kRUserIdKey] intValue];
    
    if ([self.snapObject.senderId intValue] == currentUserId) {
        
        [self.deleteButton setHidden:NO];
    }
    else {
        
        [self.deleteButton setHidden:YES];
    }

    [self.friendNameLabel setText:self.snapObject.user];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *image1Path = [NSString stringWithFormat:@"%@/%@",docDir,self.snapObject.imagePath];
    
    NSArray *mediaNameArray = [self.snapObject.imagePath componentsSeparatedByString:@"."];
    
    if (mediaNameArray.count > 1 && [[mediaNameArray objectAtIndex:1] isEqualToString:@"jpeg"]) {
        
        [self.chatImageView setHidden:NO];
        
        UIImage *image = [UIImage imageWithContentsOfFile:image1Path];
        if (image != nil)
            [self.chatImageView setImage:image];
    }
    else {
        [self.chatImageView setHidden:YES];
        NSString *str = [NSString stringWithFormat:@"%@/%@",docDir, self.snapObject.imagePath];
        NSURL *strVideoUrl = [NSURL fileURLWithPath:str];
        
        self.myPlayerViewController=[[VideoPlayerViewController alloc] init];
        self.myPlayerViewController.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        [self insertSubview:self.myPlayerViewController.view aboveSubview:self.chatImageView];
        self.myPlayerViewController.URL = strVideoUrl;
        [self.myPlayerViewController.player play];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPreviewFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.myPlayerViewController.player];
    }
    
    
    [self.messageArray removeAllObjects];
    
    if ([self.snapObject.group_id intValue] == 0) {
     
        [self.messageArray addObjectsFromArray:[[AppData sharedInstance] loadAllMesssagesForUser:self.snapObject.senderId User:self.snapObject.recieverId AndMediaId:self.snapObject.mediaId]];
    }
    else {
        
        [[AppData sharedInstance] createCrowdWithCrowdName:self.snapObject.group_id];
        [self.messageArray addObjectsFromArray:[[AppData sharedInstance] loadAllCroudChatMesssagesForGroup:self.snapObject.group_id MediaId:self.snapObject.mediaId]];
    }
    
//    NSLog(@"message Array: %@", self.messageArray);
//    [self.tableView reloadData];
//    
//    int lastRowNumber = (int)[self.tableView numberOfRowsInSection:0] - 1;
//    if (lastRowNumber > 0) {
//        NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
//        [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//    }
}

- (void)videoPreviewFinished:(NSNotification *)notif
{
    AVPlayerItem *playerItem = (AVPlayerItem *)[notif object];
    [playerItem seekToTime:kCMTimeZero];
    [self.myPlayerViewController.player play];
}

- (void)checkConnection
{
    NSString *connection = [AppData checkNetworkConnectivity];
    if ([connection isEqualToString:@"NoAccess"]) {
        
        [AJNotificationView showNoticeInView:self type:AJNotificationTypeRed title:@"No Internet Connection" hideAfter:2.5];
        
        [self.chatBackView setUserInteractionEnabled:NO];
        [self.headerBackView setUserInteractionEnabled:NO];
    }
    else {
        
        if ([self.connectionTimer isValid]) {
            [self.connectionTimer invalidate];
        }
        
        [AJNotificationView hideCurrentNotificationView];
        [self.headerBackView setUserInteractionEnabled:YES];
        [self.chatBackView setUserInteractionEnabled:YES];
        
        if (![AppData sharedInstance].isLoggedinToXmppServer) {
            
            [AppData sharedInstance].isRegister =YES;
            
            [[AppData sharedInstance] setXMPPDelegate:[AppData sharedInstance]];
            
            [[AppData sharedInstance] connect];
            
            ProgressIndicator *progressView = [ProgressIndicator sharedInstance];
            [progressView showPIOnView:self withMessage:@"Please wait. Logged In to chat."];
        }
    }
}

- (void)tapHandle:(UITapGestureRecognizer *)recognizer
{
    if (self.isChatOpen) {
        self.isChatOpen = NO;
        [self.chatTextField resignFirstResponder];
        
        [UIView animateWithDuration:0.35 animations:^{
            
            [self.chatBackView setAlpha:0.0];;
            [self.tableView setAlpha:0.0];
            [self.headerBackView setAlpha:0.0];
            
        } completion:^(BOOL finished) {
            
            [self.tableView setHidden:YES];
            [self.chatBackView setHidden:YES];
            [self.headerBackView setHidden:YES];
        }];
    }
    else {
        self.isChatOpen = YES;
        
        [self.tableView setHidden:NO];
        [self.chatBackView setHidden:NO];
        [self.headerBackView setHidden:NO];
        
        [UIView animateWithDuration:0.35 animations:^{
            
            [self.chatBackView setAlpha:1.0];;
            [self.tableView setAlpha:1.0];
            [self.headerBackView setAlpha:1.0];
        }];
    }
}

#pragma mark - Send Message -

- (void)saveMessageLocallyWithType:(NSString *)mediaType MediaUrl:(NSString *)mediaUrl ContactDetail:(NSString *)contact LocationDetail:(NSString *)location
{
    if ([self.snapObject.group_id intValue] != 0) {
        
        NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
        GroupChatTable *groupChat = [NSEntityDescription insertNewObjectForEntityForName:@"GroupChatTable" inManagedObjectContext:context];
        groupChat.groupName = self.snapObject.user;
        groupChat.message = self.chatTextField.text;
        groupChat.messageID = @"";
        groupChat.messageStatus = @"Sending";
        groupChat.sender = [USER_DEFAULT valueForKey:kRUserIdKey];
        groupChat.userName = [USER_DEFAULT valueForKey:kRUserNameKey];
        groupChat.groupId = self.snapObject.group_id;
        groupChat.mediaId = self.snapObject.mediaId;
        groupChat.time = [NSDate date];
        groupChat.mediaUrl = mediaUrl;
        groupChat.messageType = mediaType;
        groupChat.mediaStatus = [NSNumber numberWithBool:0];
        groupChat.isRead = [NSNumber numberWithBool:1];
        
        if ([mediaType intValue] == 5) {
            
            NSData *jsonData = [location dataUsingEncoding:NSUTF8StringEncoding];
            
            NSDictionary *messageObjects = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
            
            groupChat.latitude = [messageObjects valueForKeyPath:@"locationDetail.latitude"];
            groupChat.longitude = [messageObjects valueForKeyPath:@"locationDetail.longitude"];
        }
        else if ([mediaType intValue] == 4) {
            
            NSData *jsonData = [contact dataUsingEncoding:NSUTF8StringEncoding];
            
            NSDictionary *messageObjects = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
            
            groupChat.firstName = [messageObjects valueForKeyPath:@"contactDetail.firstName"];
            groupChat.lastName = [messageObjects valueForKeyPath:@"contactDetail.lastName"];
            groupChat.phoneNumber = [messageObjects valueForKeyPath:@"contactDetail.phoneNumbers"];
            groupChat.emailAddress = [messageObjects valueForKeyPath:@"contactDetail.emails"];
        }
        
        NSError *error;
        [context save:&error];
        [self.messageArray addObject:groupChat];

    }
    else
    {
        
        NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
        SingleChatTable *newContact = [NSEntityDescription insertNewObjectForEntityForName:@"SingleChatTable" inManagedObjectContext:context];
        
        newContact.sender = [USER_DEFAULT valueForKey:kRUserIdKey];
        newContact.reciever = [[USER_DEFAULT valueForKey:kRUserIdKey] isEqualToString:self.snapObject.senderId]?self.snapObject.recieverId:self.snapObject.senderId;
        newContact.message = self.chatTextField.text;
        newContact.messageID = @"";
        newContact.time = [NSDate date];
        newContact.mediaId = self.snapObject.mediaId;
        newContact.messageStatus = @"Sending";
        newContact.userName = [USER_DEFAULT valueForKey:kRUserNameKey];
        newContact.mediaUrl = mediaUrl;
        newContact.messageType = mediaType;
        newContact.mediaStatus = [NSNumber numberWithBool:0];
        newContact.isRead = [NSNumber numberWithBool:1];
        
        if ([mediaType intValue] == 5)
        {
            NSData *jsonData = [location dataUsingEncoding:NSUTF8StringEncoding];
            
            NSDictionary *messageObjects = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
            
            newContact.latitude = [messageObjects valueForKey:@"latitude"];
            newContact.longitude = [messageObjects valueForKey:@"longitude"];
        }
        else if ([mediaType intValue] == 4) {
            
            NSData *jsonData = [contact dataUsingEncoding:NSUTF8StringEncoding];
            
            NSDictionary *messageObjects = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
            
            newContact.firstName = [messageObjects valueForKey:@"firstName"];
            newContact.lastName = [messageObjects valueForKey:@"lastName"];
            newContact.phoneNumber = [messageObjects valueForKey:@"phoneNumbers"];
            newContact.emailAddress = [messageObjects valueForKey:@"emails"];
        }
        
        NSError *error;
        [context save:&error];
        [self.messageArray addObject:newContact];
    }
    
    [self.tableView reloadData];
    
    int lastRowNumber = (int)[self.tableView numberOfRowsInSection:0] - 1;
    if (lastRowNumber > 0)
    {
        NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
        [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)updateMessageWithMediaName:(NSString *)mediaName
{
    [[AppData sharedInstance] connect];
    
    NSString *recieverJid = [NSString stringWithFormat:@"%@@%@/%@",[[USER_DEFAULT valueForKey:kRUserIdKey] isEqualToString:self.snapObject.senderId]?self.snapObject.recieverId:self.snapObject.senderId,CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
    NSString *senderJid = [NSString stringWithFormat:@"%@@%@/%@",MY_USER_NAME,CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
    
    NSString *messageID=[[[AppData sharedInstance] xmppStream] generateUUID];
    
    NSString *messageType = @"chat";
    
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *messageString = @"";
    
    if ([self.snapObject.group_id intValue] != 0) {
        
        NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
        
        NSArray *groupChatArray = [DBHandler dataFromTable:@"GroupChatTable" condition:[NSString stringWithFormat:@"(mediaUrl == '%@')",mediaName] orderBy:nil ascending:YES];
        
        if (groupChatArray.count != 0) {
            
            recieverJid =  [NSString stringWithFormat:@"%@@conference.%@",self.snapObject.group_id,CHAT_SERVER_ADDRESS];
            messageType = @"groupchat";
            
            GroupChatTable *messageObj = [groupChatArray objectAtIndex:0];
            messageObj.messageID = messageID;
            messageObj.messageStatus = @"Sent";
            messageObj.mediaStatus = [NSNumber numberWithBool:1];
            
            NSError *error;
            [context save:&error];
            
            messageString = [NSString stringWithFormat:@"{\"messageId\":\"%@\", \"message\":\"%@\", \"groupName\":\"%@\", \"sender\":\"%@\", \"senderUserName\":\"%@\", \"groupId\":\"%@\", \"mediaId\":\"%@\", \"time\":\"%@\", \"messageType\":\"%@\", \"mediaUrl\":\"%@\", \"isGroup\":\"%@\", \"contactDetail\":%@, \"locationDetail\":%@}", messageID, messageObj.message, messageObj.groupName, messageObj.sender, messageObj.userName, messageObj.groupId, messageObj.mediaId, [dateformatter stringFromDate:messageObj.time], messageObj.messageType, messageObj.mediaUrl, @"1", @"{}", @"{}"];
        
            [self.messageArray removeAllObjects];
            [self.messageArray addObjectsFromArray:[[AppData sharedInstance] loadAllCroudChatMesssagesForGroup:self.snapObject.group_id MediaId:self.snapObject.mediaId]];
        }
    }
    else {
        
        NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
        
        NSArray *singleChatArray = [DBHandler dataFromTable:@"SingleChatTable" condition:[NSString stringWithFormat:@"(mediaUrl == '%@')",mediaName] orderBy:nil ascending:YES];
        
        if (singleChatArray.count != 0) {
            
            SingleChatTable *messageObj = [singleChatArray objectAtIndex:0];
            messageObj.messageID = messageID;
            messageObj.messageStatus = @"Sent";
            messageObj.mediaStatus = [NSNumber numberWithBool:1];
            
            NSError *error;
            [context save:&error];
            
            messageString = [NSString stringWithFormat:@"{\"messageId\":\"%@\", \"message\":\"%@\", \"groupName\":\"%@\", \"sender\":\"%@\", \"senderUserName\":\"%@\", \"groupId\":\"%@\", \"mediaId\":\"%@\", \"time\":\"%@\", \"messageType\":\"%@\", \"mediaUrl\":\"%@\", \"isGroup\":\"%@\", \"contactDetail\":%@, \"locationDetail\":%@}", messageID, messageObj.message, messageObj.userName, messageObj.sender, messageObj.userName, @"0", messageObj.mediaId, [dateformatter stringFromDate:messageObj.time], messageObj.messageType, messageObj.mediaUrl, @"0", @"{}", @"{}"];
            
            [self.messageArray removeAllObjects];
            
            [self.messageArray addObjectsFromArray:[[AppData sharedInstance] loadAllMesssagesForUser:self.snapObject.senderId User:self.snapObject.recieverId AndMediaId:self.snapObject.mediaId]];
        }
    }
    
    [[AppData sharedInstance] sendMessage:recieverJid Sender:senderJid Message:messageString MessageID:messageID MessageType:messageType];
    
    [self.tableView reloadData];
    
    int lastRowNumber = (int)[self.tableView numberOfRowsInSection:0] - 1;
    if (lastRowNumber > 0) {
        NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
        [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)sendChatWithMediaType:(NSString *)mediaType MediaUrl:(NSString *)mediaUrl ContactDetail:(NSString *)contact LocationDetail:(NSString *)location
{
    [[AppData sharedInstance] connect];
    
    NSString *recieverJid = [NSString stringWithFormat:@"%@@%@/%@",[[USER_DEFAULT valueForKey:kRUserIdKey] isEqualToString:self.snapObject.senderId]?self.snapObject.recieverId:self.snapObject.senderId,CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
    NSString *senderJid = [NSString stringWithFormat:@"%@@%@/%@",MY_USER_NAME,CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
    
    NSString *messageID=[[[AppData sharedInstance] xmppStream] generateUUID];
    
    NSString *messageType = @"chat";
    
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *messageString = @"";
    
    if ([self.snapObject.group_id intValue] != 0) {
        
        recieverJid =  [NSString stringWithFormat:@"%@@conference.%@",self.snapObject.group_id,CHAT_SERVER_ADDRESS];
        messageType = @"groupchat";
        
        NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
        GroupChatTable *groupChat = [NSEntityDescription insertNewObjectForEntityForName:@"GroupChatTable" inManagedObjectContext:context];
        groupChat.groupName = self.snapObject.user;
        groupChat.message = self.chatTextField.text;
        groupChat.messageID = messageID;
        groupChat.messageStatus = @"Sent";
        groupChat.sender = [USER_DEFAULT valueForKey:kRUserIdKey];
        groupChat.userName = [USER_DEFAULT valueForKey:kRUserNameKey];
        groupChat.groupId = self.snapObject.group_id;
        groupChat.mediaId = self.snapObject.mediaId;
        groupChat.time = [NSDate date];
        groupChat.mediaUrl = mediaUrl;
        groupChat.messageType = mediaType;
        groupChat.mediaStatus = [NSNumber numberWithBool:1];
        groupChat.isRead = [NSNumber numberWithBool:1];
        
        if ([mediaType intValue] == 5)
        {
            NSData *jsonData = [location dataUsingEncoding:NSUTF8StringEncoding];
            
            NSDictionary *messageObjects = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
            
            groupChat.latitude = [messageObjects valueForKey:@"latitude"];
            groupChat.longitude = [messageObjects valueForKey:@"longitude"];
        }
        else if ([mediaType intValue] == 4) {
            
            NSData *jsonData = [contact dataUsingEncoding:NSUTF8StringEncoding];
            
            NSDictionary *messageObjects = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
            
            groupChat.firstName = [messageObjects valueForKey:@"firstName"];
            groupChat.lastName = [messageObjects valueForKey:@"lastName"];
            groupChat.phoneNumber = [messageObjects valueForKey:@"phoneNumbers"];
            groupChat.emailAddress = [messageObjects valueForKey:@"emails"];
        }
        
        NSError *error;
        [context save:&error];
        [self.messageArray addObject:groupChat];
        
        messageString = [NSString stringWithFormat:@"{\"messageId\":\"%@\", \"message\":\"%@\", \"groupName\":\"%@\", \"sender\":\"%@\", \"senderUserName\":\"%@\", \"groupId\":\"%@\", \"mediaId\":\"%@\", \"time\":\"%@\", \"messageType\":\"%@\", \"mediaUrl\":\"%@\", \"isGroup\":\"%@\", \"contactDetail\":%@, \"locationDetail\":%@}", messageID, self.chatTextField.text, self.snapObject.user, [USER_DEFAULT valueForKey:kRUserIdKey], [USER_DEFAULT valueForKey:kRUserNameKey], self.snapObject.group_id, self.snapObject.mediaId, [dateformatter stringFromDate:[NSDate date]], mediaType, mediaUrl, @"1", contact, location];
        
        //        msgWithTime = [msgWithTime stringByAppendingString:[NSString stringWithFormat:@"&&%@&&%@&&%@",self.snapObject.group_id, self.snapObject.user, [USER_DEFAULT valueForKey:kRUserNameKey]]];
    }
    else
    {
        
        NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
        SingleChatTable *newContact = [NSEntityDescription insertNewObjectForEntityForName:@"SingleChatTable" inManagedObjectContext:context];
        
        newContact.sender = [USER_DEFAULT valueForKey:kRUserIdKey];
        newContact.reciever = [[USER_DEFAULT valueForKey:kRUserIdKey] isEqualToString:self.snapObject.senderId]?self.snapObject.recieverId:self.snapObject.senderId;
        newContact.message = self.chatTextField.text;
        newContact.messageID = messageID;
        newContact.time = [NSDate date];
        newContact.mediaId = self.snapObject.mediaId;
        newContact.messageStatus = @"Pending";
        newContact.userName = [USER_DEFAULT valueForKey:kRUserNameKey];
        newContact.mediaUrl = mediaUrl;
        newContact.messageType = mediaType;
        newContact.mediaStatus = [NSNumber numberWithBool:1];
        newContact.isRead = [NSNumber numberWithBool:1];
        
        if ([mediaType intValue] == 5) {
            
            NSData *jsonData = [location dataUsingEncoding:NSUTF8StringEncoding];
            
            NSDictionary *messageObjects = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
            
            newContact.latitude = [messageObjects valueForKey:@"latitude"];
            newContact.longitude = [messageObjects valueForKey:@"longitude"];
        }
        else if ([mediaType intValue] == 4) {
            
            NSData *jsonData = [contact dataUsingEncoding:NSUTF8StringEncoding];
            
            NSDictionary *messageObjects = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
            
            newContact.firstName = [messageObjects valueForKey:@"firstName"];
            newContact.lastName = [messageObjects valueForKey:@"lastName"];
            newContact.phoneNumber = [messageObjects valueForKey:@"phoneNumbers"];
            newContact.emailAddress = [messageObjects valueForKey:@"emails"];
        }
        
        NSError *error;
        [context save:&error];
        [self.messageArray addObject:newContact];
        
        messageString = [NSString stringWithFormat:@"{\"messageId\":\"%@\", \"message\":\"%@\", \"groupName\":\"%@\", \"sender\":\"%@\", \"senderUserName\":\"%@\", \"groupId\":\"%@\", \"mediaId\":\"%@\", \"time\":\"%@\", \"messageType\":\"%@\", \"mediaUrl\":\"%@\", \"isGroup\":\"%@\", \"contactDetail\":%@, \"locationDetail\":%@}", messageID, self.chatTextField.text, self.snapObject.user, [USER_DEFAULT valueForKey:kRUserIdKey], [USER_DEFAULT valueForKey:kRUserNameKey], self.snapObject.group_id, self.snapObject.mediaId, [dateformatter stringFromDate:[NSDate date]], mediaType, mediaUrl, @"0", contact, location];
        
    }
    
    [[AppData sharedInstance] sendMessage:recieverJid Sender:senderJid Message:messageString MessageID:messageID MessageType:messageType];
    
    
    [self.tableView reloadData];
    
    int lastRowNumber = (int)[self.tableView numberOfRowsInSection:0] - 1;
    if (lastRowNumber > 0) {
        NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
        [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    self.chatTextField.text = @"";

}

#pragma mark - Button Tapped Events -

- (IBAction)buttonSendTapped:(id)sender
{
    if (self.chatTextField.text.length == 0) {
        
        [AppData showAlertWithTitle:@"" Message:@"Please Enter Chat Message" CancelButtonTitle:@"OK"];
    }
    else {
        [self sendChatWithMediaType:@"0" MediaUrl:@"" ContactDetail:@"{}" LocationDetail:@"{}"];
    }
}

- (IBAction)optionButtonTapped:(UIButton *)sender
{
    int tag = (int)sender.tag;
    switch (tag) {
        case 1:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                
                imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                UIViewController *viewController = (UIViewController *)[[[self superview] superview] nextResponder];
                [viewController presentViewController:imagePicker animated:YES completion:nil];
            }
            else {
                [AppData showAlertWithTitle:@"" Message:@"Your device has no camera" CancelButtonTitle:@"OK"];
            }
            
            break;
        }
        case 2:
        {
            NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
            
            [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
            [recordSetting setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];
            [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
            [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
            [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
            [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
            
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            NSError *err = nil;
            [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
            
            if(err){
//                NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
                return;
            }
            
            [audioSession setActive:YES error:&err];
            
            err = nil;
            if(err){
//                NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
                return;
            }
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
            mediaNameString = [self getMediaName];
            mediaNameString = [NSString stringWithFormat:@"%@.m4a",mediaNameString];
            NSString *recorderFilePath = [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0], mediaNameString];
            
            NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
            err = nil;
            
            recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
            if(!recorder){
                
                [AppData showAlertWithTitle:@"Warning" Message:[err localizedDescription] CancelButtonTitle:@"OK"];
                
                return;
            }
            
            [recorder setDelegate:self];
            [recorder prepareToRecord];
            recorder.meteringEnabled = YES;
            
            BOOL audioHWAvailable = audioSession.inputIsAvailable;
            if (! audioHWAvailable) {
                
                [AppData showAlertWithTitle:@"Warning" Message:@"Audio input hardware not available" CancelButtonTitle:@"OK"];
                
                return;
            }
            
            // start recording
            [self.semiTransView setHidden:NO];
            [self.semiTransView setAlpha:0.0];
            
            [UIView animateWithDuration:0.25 animations:^{
                
                CGRect frame = self.recorderView.frame;
                frame.origin.y = (self.frame.size.height - self.recorderView.frame.size.height);
                [self.recorderView setFrame:frame];
                [self.semiTransView setAlpha:1.0];
                
            } completion:^(BOOL finished) {
                
               [recorder recordForDuration:(NSTimeInterval) 500];
                recordTimeSecond = 0;
                [self.recordingTimeLabel setText:@"00:00"];
                recordTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(recordingTimerMethod) userInfo:nil repeats:YES];
            }];
            
            break;
        }
        case 3:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                
                imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                UIViewController *viewController = (UIViewController *)[[[self superview] superview] nextResponder];
                
                NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
                NSArray *videoMediaTypesOnly = [mediaTypes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(SELF contains %@)", @"movie"]];
                
                imagePicker.mediaTypes = videoMediaTypesOnly;
                imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
                imagePicker.videoMaximumDuration = 180;
                
                [viewController presentViewController:imagePicker animated:YES completion:nil];
            }
            else {
                [AppData showAlertWithTitle:@"" Message:@"Your device has no camera" CancelButtonTitle:@"OK"];
            }
            break;
        }
        case 4:
        {
            if (APP_DELEGATE.curLat == 0.00f && APP_DELEGATE.curLng == 0.00f) {
                
                [AppData showAlertWithTitle:@"" Message:@"Please enable your location service from settings." CancelButtonTitle:@"OK"];
            }
            else {
                NSString *locationString = [NSString stringWithFormat:@"{\"latitude\":\"%f\", \"longitude\":\"%f\"}", APP_DELEGATE.curLat, APP_DELEGATE.curLng];
                
                [self sendChatWithMediaType:@"5" MediaUrl:@"" ContactDetail:@"{}" LocationDetail:locationString];
            }
            break;
        }
        case 5:
        {
            self.addressBookController = [[ABPeoplePickerNavigationController alloc] init];
            [self.addressBookController setPeoplePickerDelegate:self];
            UIViewController *viewController = (UIViewController *)[[[self superview] superview] nextResponder];
            [viewController presentViewController:self.addressBookController animated:YES completion:nil];
            break;
        }
        case 6:
        {
            imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage, nil];
            
            UIViewController *viewController = (UIViewController *)[[[self superview] superview] nextResponder];
            [viewController presentViewController:imagePicker animated:YES completion:nil];
            
            break;
        }
        default:
            break;
    }
    [self buttonCloseOptionTapped:nil];
}

- (IBAction)buttonPlusTapped:(UIButton *)sender
{
    [self.chatTextField resignFirstResponder];
    if (self.optionView.alpha == 1.0f) {
        
        [UIView animateWithDuration:0.25 animations:^{
            
            [self.optionView setAlpha:0.0];
        } completion:^(BOOL finished) {
            
            [self.optionView setHidden:YES];
        }];
    }
    else {
        [self.optionView setHidden:NO];
        
        [UIView animateWithDuration:0.25 animations:^{
            
            [self.optionView setAlpha:1.0];
        }];
    }
}

- (IBAction)buttonCloseOptionTapped:(id)sender
{
    [UIView animateWithDuration:0.25 animations:^{
        
        [self.optionView setAlpha:0.0];
    } completion:^(BOOL finished) {
        
        [self.optionView setHidden:YES];
    }];
}

- (IBAction)buttonStopTapped:(id)sender
{
    [UIView animateWithDuration:0.25 animations:^{
        
        [self.semiTransView setAlpha:0.0];
        CGRect frame = self.recorderView.frame;
        frame.origin.y = self.frame.size.height;
        [self.recorderView setFrame:frame];
    } completion:^(BOOL finished) {
        
        [self.semiTransView setHidden:YES];
    }];
    sendAudio = YES;
    [recordTimer invalidate];
    [recorder stop];
}

- (IBAction)buttonCancelRecordTapped:(id)sender
{
    [UIView animateWithDuration:0.25 animations:^{
        
        [self.semiTransView setAlpha:0.0];
        CGRect frame = self.recorderView.frame;
        frame.origin.y = self.frame.size.height;
        [self.recorderView setFrame:frame];
    } completion:^(BOOL finished) {
        
        [self.semiTransView setHidden:YES];
    }];
    sendAudio = NO;
    [recordTimer invalidate];
    [recorder stop];
}

- (IBAction)buttonDeleteTapped:(id)sender
{
    ProgressIndicator *pi = [ProgressIndicator sharedInstance];
    [pi showPIOnView:self withMessage:@"loading.."];
    
    WebServiceHandler *handler = [[WebServiceHandler alloc] init];
    handler.requestType = eSingUp;
    
    NSString *sessionToken=[[NSUserDefaults standardUserDefaults]valueForKey:@"SessionToken"];
    NSString *userId=[[NSUserDefaults standardUserDefaults]valueForKey:kRUserIdKey];
   
    NSString *currentTime=[Helper getCurrentTimeWithColon];
    NSString *parameters = [NSString stringWithFormat:@"%@%@?user_session_token=%@&owner_id=%@&media_id=%@&current_time=%@&reciever_id=%@&group_flag=%i&delete_chat_message=delete",HOST,mStopChatMessage,sessionToken,userId, self.snapObject.mediaId, currentTime, [self.snapObject.group_id intValue]==0?self.snapObject.chat_id:self.snapObject.group_id, [self.snapObject.group_id intValue]==0?0:1];

    NSURL *url = [NSURL URLWithString:[Helper removeWhiteSpaceFromURL:parameters]];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    
    [handler placeWebserviceRequestWithString:theRequest Target:self Selector:@selector(responseDeleteChat:)];
}

- (void)buttonVideoPlayTapped:(UIButton *)sender
{
    int tag = (int)sender.tag;
    selectedIndex = tag;
    NSString *mediaName;
    
    if ([self.snapObject.group_id intValue] == 0) {
        
        SingleChatTable *messageObj = [self.messageArray objectAtIndex:tag-1000];
        mediaName = messageObj.mediaUrl;
    }
    else {
        
        GroupChatTable *messageObj = [self.messageArray objectAtIndex:tag-1000];
        mediaName = messageObj.mediaUrl;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:mediaName];
    
    NSURL *url = [NSURL fileURLWithPath:filePath];
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDonePressed:) name:MPMoviePlayerDidExitFullscreenNotification object:moviePlayer];
    
    moviePlayer.controlStyle=MPMovieControlStyleDefault;
    //moviePlayer.shouldAutoplay=NO;
    [moviePlayer play];
    [self addSubview:moviePlayer.view];
    [moviePlayer setFullscreen:YES animated:YES];
}

- (void)buttonUploadDownloadTapped:(UIButton *)sender
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag-1000 inSection:0];
    SingleMapRecieverCell *cell = (SingleMapRecieverCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    [sender removeTarget:self action:@selector(buttonUploadDownloadTapped:) forControlEvents:UIControlEventTouchUpInside];
    [sender addTarget:self action:@selector(cancelDownload:) forControlEvents:UIControlEventTouchUpInside];
    
    id object = [self.messageArray objectAtIndex:sender.tag-1000];
    
    [cell.imageButton setImage:nil forState:UIControlStateNormal];
    [cell.spinnerView startAnimating];
    [cell.spinnerBackView setHidden:NO];
    [cell.spinnerView setLineWidth:2.5];
    
    if (![[AppData sharedInstance].chatMediaArray containsObject:[object valueForKey:@"mediaUrl"]])
    {
        [[AppData sharedInstance].chatMediaArray addObject:[object valueForKey:@"mediaUrl"]];
        [[AppData sharedInstance] chatMediaUploadDownload];
    }
    
    if ([self.snapObject.group_id intValue] == 0) {
        
        SingleChatTable *messageObject = (SingleChatTable *)object;
        
        NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
        
        messageObject.mediaStatus = [NSNumber numberWithInt:0];
        
        NSError *error;
        [context save:&error];
        
        [self.messageArray removeAllObjects];
        [self.messageArray addObjectsFromArray:[[AppData sharedInstance] loadAllMesssagesForUser:self.snapObject.senderId User:self.snapObject.recieverId AndMediaId:self.snapObject.mediaId]];
    }
    else {
        
        GroupChatTable *messageObject = (GroupChatTable *)object;
        
        NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
        
        messageObject.mediaStatus = [NSNumber numberWithInt:0];
        
        NSError *error;
        [context save:&error];
        
        [self.messageArray removeAllObjects];
        [self.messageArray addObjectsFromArray:[[AppData sharedInstance] loadAllCroudChatMesssagesForGroup:self.snapObject.group_id MediaId:self.snapObject.mediaId]];
    }
    
    [self.tableView reloadData];
    
    int lastRowNumber = (int)[self.tableView numberOfRowsInSection:0] - 1;
    if (lastRowNumber > 0) {
        NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
        [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)cancelDownload:(UIButton *)sender
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag-1000 inSection:0];
    SingleMapRecieverCell *cell = (SingleMapRecieverCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    [sender removeTarget:self action:@selector(cancelDownload:) forControlEvents:UIControlEventTouchUpInside];
    [sender addTarget:self action:@selector(buttonUploadDownloadTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    id messageObj = [self.messageArray objectAtIndex:sender.tag - 1000];
    int index = (int)[[AppData sharedInstance].chatMediaArray indexOfObject:[messageObj valueForKey:@"mediaUrl"]];
    
    if (index == 0) {
        
        [[AppData sharedInstance].downloadCon cancel];
        [[AppData sharedInstance].chatMediaArray removeObject:[messageObj valueForKey:@"mediaUrl"]];
        [AppData sharedInstance].isInQueue = NO;
        [[AppData sharedInstance] chatMediaUploadDownload];
    }
    else {
        [[AppData sharedInstance].chatMediaArray removeObject:[messageObj valueForKey:@"mediaUrl"]];
    }
    
    if ([self.snapObject.group_id intValue] == 0) {
        
        SingleChatTable *messageObject = (SingleChatTable *)messageObj;
        
        NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
        
        messageObject.mediaStatus = [NSNumber numberWithInt:2];
        
        NSError *error;
        [context save:&error];
        
        [self.messageArray removeAllObjects];
        [self.messageArray addObjectsFromArray:[[AppData sharedInstance] loadAllMesssagesForUser:self.snapObject.senderId User:self.snapObject.recieverId AndMediaId:self.snapObject.mediaId]];
    }
    else {
        
        GroupChatTable *messageObject = (GroupChatTable *)messageObj;
        
        NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
        
        messageObject.mediaStatus = [NSNumber numberWithInt:2];
        
        NSError *error;
        [context save:&error];
        
        [self.messageArray removeAllObjects];
        [self.messageArray addObjectsFromArray:[[AppData sharedInstance] loadAllCroudChatMesssagesForGroup:self.snapObject.group_id MediaId:self.snapObject.mediaId]];
    }
    
    [self.tableView reloadData];
    
    int lastRowNumber = (int)[self.tableView numberOfRowsInSection:0] - 1;
    if (lastRowNumber > 0) {
        NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
        [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)openContactSaveView:(UIButton *)sender
{
    int tag = (int)sender.tag;
    selectedIndex = tag;
    NSString *firstName, *LastName, *phoneNumber, *emailAddress;
    NSArray *phoneArray, *emailArray;
    
    if ([self.snapObject.group_id intValue] == 0) {
        
        SingleChatTable *messageObj = [self.messageArray objectAtIndex:tag-1000];
        firstName = messageObj.firstName;
        LastName = messageObj.lastName;
        phoneNumber = messageObj.phoneNumber;
        emailAddress = messageObj.emailAddress;
    }
    else {
        
        GroupChatTable *messageObj = [self.messageArray objectAtIndex:tag-1000];
        firstName = messageObj.firstName;
        LastName = messageObj.lastName;
        phoneNumber = messageObj.phoneNumber;
        emailAddress = messageObj.emailAddress;
    }
    
    
    CFErrorRef error = NULL;
//    NSLog(@"%@", [self description]);
    ABAddressBookRef iPhoneAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    ABRecordRef newPerson = ABPersonCreate();
    
    ABRecordSetValue(newPerson, kABPersonFirstNameProperty, (__bridge CFTypeRef)(firstName), &error);
    ABRecordSetValue(newPerson, kABPersonLastNameProperty, (__bridge CFTypeRef)(LastName), &error);
    
    ABMutableMultiValueRef multiPhone =     ABMultiValueCreateMutable(kABMultiStringPropertyType);
    phoneArray = [phoneNumber componentsSeparatedByString:@","];
    
    for (NSString *phone in phoneArray) {
        
        ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(phone), kABPersonPhoneMainLabel, NULL);
        ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone,nil);
    }
    
    CFRelease(multiPhone);
    // ...
    
    if (emailAddress.length != 0 && ![emailAddress isEqualToString:@"(null)"]) {
        
        ABMutableMultiValueRef multiEmail =     ABMultiValueCreateMutable(kABMultiStringPropertyType);
        
        emailArray = [emailAddress componentsSeparatedByString:@","];
        
        for (NSString *email in emailArray) {
            
            ABMultiValueAddValueAndLabel(multiEmail, (__bridge CFTypeRef)(email), kABPersonEmailProperty, NULL);
            ABRecordSetValue(newPerson, kABPersonEmailProperty, multiEmail,nil);
        }
        
        CFRelease(multiEmail);
    }
    
    // ...
    
    ABUnknownPersonViewController *view = [[ABUnknownPersonViewController alloc] init];
    
    view.unknownPersonViewDelegate = self;
    view.displayedPerson = newPerson; // Assume person is already defined.
    view.allowsAddingToAddressBook = YES;
    
    UIViewController *viewController = (UIViewController *)[[[self superview] superview] nextResponder];
    [viewController.navigationController pushViewController:view animated:YES];
    
//    ABAddressBookAddRecord(iPhoneAddressBook, newPerson, &error);
    
//    ABAddressBookSave(iPhoneAddressBook, &error);
    CFRelease(newPerson);
    CFRelease(iPhoneAddressBook);
//    if (error != NULL)
//    {
//        CFStringRef errorDesc = CFErrorCopyDescription(error);
//        NSLog(@"Contact not saved: %@", errorDesc);
//        CFRelease(errorDesc);        
//    }
//    else {
//        [AppData showAlertWithTitle:@"" Message:@"Contact Saved" CancelButtonTitle:@"OK"];
//    }
}

- (void)btnImageClicked:(UIButton *)sender
{
    //    dispatch_sync(dispatch_get_main_queue(), ^{
    /* Do UI work here */
    
    CGPoint center= sender.center;
    CGPoint rootViewPoint = [sender.superview convertPoint:center toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:rootViewPoint];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    CGRect rectInSuperview = [cell convertRect:sender.frame toView:[self.tableView superview]];
    
    id object = [self.messageArray objectAtIndex:sender.tag-1000];
  
    
    
    [[viewFullImage subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIButton *btnImage;
    
    if ([[object valueForKey:@"messageType"] intValue] == 5) {
        
        mapView = [[MKMapView alloc] initWithFrame:viewFullImage.bounds];
        mapView.delegate = self;
        [viewFullImage addSubview:mapView];
        
        MKCoordinateRegion region;
        region.center.latitude = [[object valueForKey:@"latitude"] doubleValue];
        region.center.longitude = [[object valueForKey:@"longitude"] doubleValue];
        
        MKCoordinateSpan span;
        span.latitudeDelta = 0.5;
        span.longitudeDelta = 0.5;
        region.span = span;
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [[object valueForKey:@"latitude"] doubleValue];
        coordinate.longitude = [[object valueForKey:@"longitude"] doubleValue];
        DDAnnotation *annotation = [[DDAnnotation alloc] initWithCoordinate:coordinate title:[object valueForKey:@"userName"]];
        
        [mapView addAnnotation:annotation];
        [mapView setRegion:region];
        
        btnImage = [UIButton buttonWithType:UIButtonTypeCustom];
        btnImage.frame = CGRectMake(self.bounds.size.width - 100, 20, 80, 30);
        [btnImage setBackgroundColor:[UIColor blackColor]];
        [btnImage setTitle:@"Done" forState:UIControlStateNormal];
        [btnImage.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [btnImage.layer setCornerRadius:5];
        [btnImage.layer setBorderColor:[[UIColor whiteColor] CGColor]];
        [btnImage.layer setBorderWidth:1];
        [btnImage setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnImage setTag:indexPath.section];
        [btnImage addTarget:self action:@selector(btnFullImageClicked:) forControlEvents:UIControlEventTouchUpInside];
        [viewFullImage addSubview:btnImage];
        
    }
    else {
        
        imageView = [[UIImageView alloc] initWithFrame:viewFullImage.bounds];
        imageView.contentMode = UIViewContentModeCenter;
        [viewFullImage addSubview:imageView];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
        NSString *filePath = [documentsPath stringByAppendingPathComponent:[object valueForKey:@"mediaUrl"]];
        NSData *pngData = [NSData dataWithContentsOfFile:filePath];
        UIImage *image = [UIImage imageWithData:pngData];
        
        [imageView setImage:image];
        
        btnImage = [UIButton buttonWithType:UIButtonTypeCustom];
        btnImage.frame = viewFullImage.bounds;
        [btnImage setBackgroundColor:[UIColor clearColor]];
        [btnImage setTag:indexPath.section];
        [btnImage addTarget:self action:@selector(btnFullImageClicked:) forControlEvents:UIControlEventTouchUpInside];
        [viewFullImage addSubview:btnImage];
    }
    
    viewFullImage.alpha = 0.0f;
    viewFullImage.frame = rectInSuperview;
    viewFullImage.clipsToBounds = YES;
    
    cellFrame = rectInSuperview;
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    [window addSubview:viewFullImage];
    [UIView animateWithDuration:0.25 animations:^{
        
        viewFullImage.frame = [[[[UIApplication sharedApplication] windows] objectAtIndex:0] bounds];
        imageView.frame = viewFullImage.bounds;
        mapView.frame = viewFullImage.bounds;
        if ([[object valueForKey:@"messageType"] intValue] == 1)
            btnImage.frame = viewFullImage.bounds;
        viewFullImage.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)btnFullImageClicked:(UIButton *)sender
{
    //    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [UIView animateWithDuration:0.25 animations:^{
        viewFullImage.frame = cellFrame;
        imageView.frame = viewFullImage.bounds;
        mapView.frame = viewFullImage.bounds;
        viewFullImage.alpha = 0.0;
    } completion:^(BOOL finished) {
        //        self.navigationController.navigationBarHidden = NO;
        [viewFullImage removeFromSuperview];
    }];
}

- (void)recordingTimerMethod
{
    recordTimeSecond ++;
    if (recordTimeSecond < 10) {
        [self.recordingTimeLabel setText:[NSString stringWithFormat:@"00:0%i",recordTimeSecond]];
    }
    else if (recordTimeSecond > 59) {
        
        int min = recordTimeSecond / 60;
        int sec = recordTimeSecond % 60;
        
        if (sec < 10 && min < 10) {
            [self.recordingTimeLabel setText:[NSString stringWithFormat:@"0%i:0%i",min, sec]];
        }
        else if (sec > 10 && min < 10) {
            [self.recordingTimeLabel setText:[NSString stringWithFormat:@"0%i:%i",min, sec]];
        }
        else if (sec < 10 && min > 10) {
            [self.recordingTimeLabel setText:[NSString stringWithFormat:@"%i:0%i",min, sec]];
        }
        else {
            [self.recordingTimeLabel setText:[NSString stringWithFormat:@"%i:%i",min, sec]];
        }
    }
    else {
        [self.recordingTimeLabel setText:[NSString stringWithFormat:@"00:%i",recordTimeSecond]];
    }
    
    self.recordingButton.selected = !self.recordingButton.selected;
}

#pragma mark - Video Player Methods -

- (void) moviePlayBackDonePressed:(NSNotification*)notification
{
    [moviePlayer stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:moviePlayer];
    
    
    if ([moviePlayer respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [moviePlayer.view removeFromSuperview];
    }
    moviePlayer=nil;
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    [moviePlayer stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
    
    if ([moviePlayer respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [moviePlayer.view removeFromSuperview];
    }
}

#pragma mark - Response Method -

- (void)responseDeleteChat:(NSDictionary *)responseDict
{
    ProgressIndicator *pi = [ProgressIndicator sharedInstance];
    [pi hideProgressIndicator];
    NSDictionary *dictResponse = [responseDict objectForKey:@"ItemsList"];
    if ([[dictResponse objectForKey:@"statusNumber"] intValue] == kRSuccessStatusCode.intValue || [[dictResponse objectForKey:@"statusNumber"] intValue] == 48) {
        
        NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
        
        [context deleteObject:self.snapObject];
        [context save:nil];
        [self.delegate chatViewDeleteSnap];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateInbox" object:nil];
    }
    else {
        [AppData showAlertWithTitle:@"" Message:[dictResponse valueForKey:@"statusMessage"] CancelButtonTitle:@"OK"];
    }
}

#pragma mark - Textfield Delegate -

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
//    CGFloat deltaHeight = kbSize.height - _currentKeyboardHeight;
    // Write code to adjust views accordingly using deltaHeight
    _currentKeyboardHeight = kbSize.height;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        CGRect chatFrame = self.chatBackView.frame;
        chatFrame.origin.y = self.frame.size.height-_currentKeyboardHeight-44;
        self.chatBackView.frame = chatFrame;
        
        CGRect tableFrame = self.tableView.frame;
        tableFrame.size.height = self.frame.size.height-_currentKeyboardHeight-88;
        self.tableView.frame = tableFrame;
    }];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
//    NSDictionary *info = [notification userInfo];
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    // Write code to adjust views accordingly using kbSize.height
    _currentKeyboardHeight = 0.0f;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        CGRect chatFrame = self.chatBackView.frame;
        chatFrame.origin.y = self.frame.size.height-44;
        self.chatBackView.frame = chatFrame;
        
        CGRect tableFrame = self.tableView.frame;
        tableFrame.size.height = self.frame.size.height-88;
        self.tableView.frame = tableFrame;
    }];
}

#pragma mark - TableView Delegate -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messageArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.snapObject.group_id intValue] == 0) {
        
        SingleChatTable *messageObj = [self.messageArray objectAtIndex:indexPath.row];

        if ([messageObj.messageType intValue] == 0) {
            
            CGSize constrainedSize = CGSizeMake(230  , 9999);
            
            NSDictionary *attributesDictionary = @{NSFontAttributeName:[UIFont systemFontOfSize:14]};
            
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:messageObj.message attributes:attributesDictionary];
            
            CGRect requiredHeight = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
            
            return MAX(54, requiredHeight.size.height+34);
        }
        else if ([messageObj.messageType intValue] == 5  || [messageObj.messageType intValue] == 1 || [messageObj.messageType intValue] == 2) {
            return 150;
        }
        else if ([messageObj.messageType intValue] == 3  || [messageObj.messageType intValue] == 4) {
            return 75;
        }
    }
    else {
        
        GroupChatTable *messageObj = [self.messageArray objectAtIndex:indexPath.row];

        if ([messageObj.messageType intValue] == 0) {
            
            CGSize constrainedSize = CGSizeMake(230  , 9999);
            
            NSDictionary *attributesDictionary = @{NSFontAttributeName:[UIFont systemFontOfSize:14]};
            
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:messageObj.message attributes:attributesDictionary];
            
            CGRect requiredHeight = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
            
            return MAX(69, requiredHeight.size.height + 49);
        }
        else if ([messageObj.messageType intValue] == 5 || [messageObj.messageType intValue] == 1 || [messageObj.messageType intValue] == 2) {
            return 150;
        }
        else if ([messageObj.messageType intValue] == 3  || [messageObj.messageType intValue] == 4) {
            return 90;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *currentUser = [USER_DEFAULT valueForKey:kRUserIdKey];
    
    if ([self.snapObject.group_id intValue] == 0) {
        
        SingleChatTable *messageObj = [self.messageArray objectAtIndex:indexPath.row];
        if ([currentUser isEqualToString:messageObj.sender])
        {
            if ([messageObj.messageType intValue] == 0) {
                
                NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"SenderChatCell" owner:self options:0];
                SenderChatCell *cell = [nibArray objectAtIndex:0];
                cell.messageLabel.text = messageObj.message;
                [cell.timeLabel setText:[AppData relativeDateStringForDate:messageObj.time]];
                
                NSString *imageUrlStr = [NSString stringWithFormat:@"%@snaps/profile_Image/profileimage_%@.jpeg",HOST,[USER_DEFAULT valueForKey:kRUserIdKey]];
                
                [cell.userImageView loadImageFromURL:[NSURL URLWithString:imageUrlStr] PlaceHolderImage:[UIImage imageNamed:@"no_image.png"]];
                return cell;
            }
            else if ([messageObj.messageType intValue] == 5 || [messageObj.messageType intValue] == 1 || [messageObj.messageType intValue] == 2) {
                
                NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"SingleMapSenderCell" owner:self options:0];
                SingleMapSenderCell *cell = [nibArray objectAtIndex:0];
                
                [cell.timeLabel setText:[AppData relativeDateStringForDate:messageObj.time]];
                
                NSString *imageUrlStr = [NSString stringWithFormat:@"%@snaps/profile_Image/profileimage_%@.jpeg",HOST,[USER_DEFAULT valueForKey:kRUserIdKey]];
                
                [cell.userImageView loadImageFromURL:[NSURL URLWithString:imageUrlStr] PlaceHolderImage:[UIImage imageNamed:@"no_image.png"]];
                
                if ([messageObj.messageType intValue] == 5) {
                    
                    [cell showmap_lat:[messageObj.latitude doubleValue] lng:[messageObj.longitude doubleValue] title:messageObj.userName];
                    [cell.mapView setUserInteractionEnabled:NO];
                    [cell.chatImageView setHidden:YES];
                    [cell.spinnerView setHidden:NO];
                    [cell.mapView setHidden:NO];
                    [cell.imageButton setImage:nil forState:UIControlStateNormal];
                    [cell.imageButton setTitle:@"" forState:UIControlStateNormal];
                    
                    [cell.imageButton setTag:indexPath.row+1000];
                    [cell.imageButton addTarget:self action:@selector(btnImageClicked:) forControlEvents:UIControlEventTouchUpInside];
                }
                else {
                    
                    [cell.chatImageView setHidden:NO];
                    [cell.mapView setHidden:YES];
                    [cell.imageButton setImage:nil forState:UIControlStateNormal];
                    
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
                    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
                    NSString *filePath = [documentsPath stringByAppendingPathComponent:messageObj.mediaUrl];
                    
                    if ([messageObj.messageType intValue] == 1) {
                     
                        NSData *pngData = [NSData dataWithContentsOfFile:filePath];
                        UIImage *image = [UIImage imageWithData:pngData];
                        
                        [cell.chatImageView setImage:image];
                        [cell.imageButton setTag:indexPath.row+1000];
                        [cell.imageButton addTarget:self action:@selector(btnImageClicked:) forControlEvents:UIControlEventTouchUpInside];
                    }
                    else {
                        
                        [cell.chatImageView setImage:[self getThumbNail:filePath]];
                        [cell.imageButton setImage:[UIImage imageNamed:@"btn_play.png"] forState:UIControlStateNormal];
                        [cell.imageButton setTag:indexPath.row + 1000];
                        [cell.imageButton addTarget:self action:@selector(buttonVideoPlayTapped:) forControlEvents:UIControlEventTouchUpInside];
                    }
                    
                    if ([messageObj.mediaStatus intValue] == 0) {
                        
                        [cell.imageButton setImage:nil forState:UIControlStateNormal];
                        [cell.spinnerView setLineWidth:2.5];
                        [cell.spinnerBackView setHidden:NO];
                        [cell.spinnerView startAnimating];
                        
                        if (![[AppData sharedInstance].chatMediaArray containsObject:messageObj.mediaUrl]) {
                            
                            [[AppData sharedInstance].chatMediaArray addObject:messageObj.mediaUrl];
                            [[AppData sharedInstance] chatMediaUploadDownload];
                        }
                    }
                    else if ([messageObj.mediaStatus intValue] == 2) {
                        
                        [cell.imageButton setImage:[UIImage imageNamed:@"ic_upload.png"] forState:UIControlStateNormal];
                        [cell.spinnerBackView setHidden:YES];
                        [cell.spinnerView stopAnimating];
                        [cell.imageButton setTag:indexPath.row + 1000];
                        [cell.imageButton addTarget:self action:@selector(buttonUploadDownloadTapped:) forControlEvents:UIControlEventTouchUpInside];
                    }
                    else if ([messageObj.mediaStatus intValue] == 1) {
                        
                        [cell.imageButton setImage:nil forState:UIControlStateNormal];
                        [cell.spinnerBackView setHidden:YES];
                        [cell.spinnerView stopAnimating];
                    }
                }
                
                
                return cell;
            }
            else if ([messageObj.messageType intValue] == 3 || [messageObj.messageType intValue] == 4) {
                
                NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"SingleAudioSenderCell" owner:self options:0];
                SingleAudioSenderCell *cell = [nibArray objectAtIndex:0];

                [cell.timeLabel setText:[AppData relativeDateStringForDate:messageObj.time]];
                
                NSString *imageUrlStr = [NSString stringWithFormat:@"%@snaps/profile_Image/profileimage_%@.jpeg",HOST,[USER_DEFAULT valueForKey:kRUserIdKey]];
                
                [cell.userImageView loadImageFromURL:[NSURL URLWithString:imageUrlStr] PlaceHolderImage:[UIImage imageNamed:@"no_image.png"]];
                
                if ([messageObj.messageType intValue] == 3) {
                    
                    [cell.playButton setHidden:NO];
                    [cell.progressBar setHidden:NO];
                    [cell.contactButton setHidden:YES];
                    [cell.contactImageView setHidden:YES];
                    [cell.contactNameLabel setHidden:YES];
                    [cell.playButton setTag:indexPath.row + 1000];
                    [cell.progressBar setTag:indexPath.row + 5000];
                    [cell.playButton addTarget:self action:@selector(btnPlay_Click:) forControlEvents:UIControlEventTouchUpInside];
                }
                else {
                    
                    [cell.playButton setHidden:YES];
                    [cell.progressBar setHidden:YES];
                    [cell.contactButton setHidden:NO];
                    [cell.contactImageView setHidden:NO];
                    [cell.contactNameLabel setHidden:NO];
                    
                    NSString *nameStr = @"";
                    
                    if (![messageObj.firstName isEqualToString:@"(null)"] && ![messageObj.firstName isEqual:[NSNull null]] && messageObj.firstName.length != 0) {
                        nameStr = messageObj.firstName;
                    }
                    if (![messageObj.lastName isEqualToString:@"(null)"] && ![messageObj.lastName isEqual:[NSNull null]] && messageObj.lastName.length != 0) {
                        nameStr = [NSString stringWithFormat:@"%@ %@",nameStr, messageObj.lastName];
                    }
                    
                    if ([nameStr hasPrefix:@" "] && nameStr.length > 1) {
                        nameStr = [nameStr substringFromIndex:1];
                    }
                    
                    [cell.contactNameLabel setText:nameStr];
                }
                return cell;
            }
        }
        else {
            if ([messageObj.messageType intValue] == 0) {
                
                NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"RecieverChatCell" owner:self options:0];
                RecieverChatCell *cell = [nibArray objectAtIndex:0];
                cell.messageLabel.text = messageObj.message;
                [cell.timeLabel setText:[AppData relativeDateStringForDate:messageObj.time]];
                
                NSString *imageUrlStr = [NSString stringWithFormat:@"%@snaps/profile_Image/profileimage_%@.jpeg",HOST,[[USER_DEFAULT valueForKey:kRUserIdKey] isEqualToString:self.snapObject.senderId]?self.snapObject.recieverId:self.snapObject.senderId];
                [cell.userImageView loadImageFromURL:[NSURL URLWithString:imageUrlStr] PlaceHolderImage:[UIImage imageNamed:@"no_image.png"]];
                
                return cell;
            }
            else if ([messageObj.messageType intValue] == 5 || [messageObj.messageType intValue] == 1 || [messageObj.messageType intValue] == 2) {
                
                NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"SingleMapRecieverCell" owner:self options:0];
                SingleMapRecieverCell *cell = [nibArray objectAtIndex:0];
                
                [cell.timeLabel setText:[AppData relativeDateStringForDate:messageObj.time]];
                
                NSString *imageUrlStr = [NSString stringWithFormat:@"%@snaps/profile_Image/profileimage_%@.jpeg",HOST,[[USER_DEFAULT valueForKey:kRUserIdKey] isEqualToString:self.snapObject.senderId]?self.snapObject.recieverId:self.snapObject.senderId];
                
                [cell.userImageView loadImageFromURL:[NSURL URLWithString:imageUrlStr] PlaceHolderImage:[UIImage imageNamed:@"no_image.png"]];
                
                if ([messageObj.messageType intValue] == 5) {
                    
                    [cell showmap_lat:[messageObj.latitude doubleValue] lng:[messageObj.longitude doubleValue] title:messageObj.userName];
                    [cell.mapView setUserInteractionEnabled:NO];
                    [cell.chatImageView setHidden:YES];
                    [cell.mapView setHidden:NO];
                    [cell.imageButton setImage:nil forState:UIControlStateNormal];
                    
                    [cell.imageButton setTag:indexPath.row+1000];
                    [cell.imageButton addTarget:self action:@selector(btnImageClicked:) forControlEvents:UIControlEventTouchUpInside];
                }
                else {
                    
                    [cell.chatImageView setHidden:NO];
                    [cell.mapView setHidden:YES];
                    
                    if ([messageObj.mediaStatus intValue] == 1) {
                        
                        [cell.imageButton setImage:nil forState:UIControlStateNormal];
                        [cell.spinnerBackView setHidden:YES];
                        [cell.spinnerView stopAnimating];
                        
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
                        NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
                        NSString *filePath = [documentsPath stringByAppendingPathComponent:messageObj.mediaUrl];
                        
                        if ([messageObj.messageType intValue] == 1) {
                            
                            NSData *pngData = [NSData dataWithContentsOfFile:filePath];
                            UIImage *image = [UIImage imageWithData:pngData];
                            
                            [cell.chatImageView setImage:image];
                            [cell.imageButton setTag:indexPath.row+1000];
                            [cell.imageButton addTarget:self action:@selector(btnImageClicked:) forControlEvents:UIControlEventTouchUpInside];
                        }
                        else {
                            [cell.chatImageView setImage:[self getThumbNail:filePath]];
                            [cell.imageButton setImage:[UIImage imageNamed:@"btn_play.png"] forState:UIControlStateNormal];
                            [cell.imageButton setTag:indexPath.row + 1000];
                            [cell.imageButton addTarget:self action:@selector(buttonVideoPlayTapped:) forControlEvents:UIControlEventTouchUpInside];
                        }
                        
                    }
                    else if ([messageObj.mediaStatus intValue] == 2) {
                        
                        [cell.imageButton setImage:[UIImage imageNamed:@"ic_download.png"] forState:UIControlStateNormal];
                        [cell.spinnerView stopAnimating];
                        [cell.spinnerBackView setHidden:YES];
                        [cell.imageButton setTag:indexPath.row + 1000];
                        [cell.imageButton addTarget:self action:@selector(buttonUploadDownloadTapped:) forControlEvents:UIControlEventTouchUpInside];
                    }
                    else if ([messageObj.mediaStatus intValue] == 0) {
                        
                        [cell.imageButton setImage:nil forState:UIControlStateNormal];
                        [cell.spinnerView setLineWidth:2.5];
                        [cell.spinnerBackView setHidden:NO];
                        [cell.spinnerView startAnimating];
                        
                        [cell.imageButton setTag:indexPath.row + 1000];
                        [cell.imageButton addTarget:self action:@selector(cancelDownload:) forControlEvents:UIControlEventTouchUpInside];
                        
                        if (![[AppData sharedInstance].chatMediaArray containsObject:messageObj.mediaUrl]) {
                            
                            [[AppData sharedInstance].chatMediaArray addObject:messageObj.mediaUrl];
                            [[AppData sharedInstance] chatMediaUploadDownload];
                        }
                    }
                }
                
                return cell;
            }
            else if ([messageObj.messageType intValue] == 3 || [messageObj.messageType intValue] == 4) {
                
                NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"SingleAudioReceiverCell" owner:self options:0];
                SingleAudioReceiverCell *cell = [nibArray objectAtIndex:0];
                
                [cell.timeLabel setText:[AppData relativeDateStringForDate:messageObj.time]];
                
                NSString *imageUrlStr = [NSString stringWithFormat:@"%@snaps/profile_Image/profileimage_%@.jpeg",HOST,[[USER_DEFAULT valueForKey:kRUserIdKey] isEqualToString:self.snapObject.senderId]?self.snapObject.recieverId:self.snapObject.senderId];
                
                [cell.userImageView loadImageFromURL:[NSURL URLWithString:imageUrlStr] PlaceHolderImage:[UIImage imageNamed:@"no_image.png"]];
                
                if ([messageObj.messageType intValue] == 3) {
                    
                    [cell.playButton setHidden:NO];
                    [cell.progressBar setHidden:NO];
                    [cell.contactButton setHidden:YES];
                    [cell.contactImageView setHidden:YES];
                    [cell.contactNameLabel setHidden:YES];
                    [cell.playButton setTag:indexPath.row + 1000];
                    [cell.progressBar setTag:indexPath.row + 5000];
                    [cell.playButton addTarget:self action:@selector(btnPlay_Click:) forControlEvents:UIControlEventTouchUpInside];
                }
                else {
                    
                    [cell.playButton setHidden:YES];
                    [cell.progressBar setHidden:YES];
                    [cell.contactButton setHidden:NO];
                    [cell.contactButton setTag:indexPath.row + 1000];
                    [cell.contactButton addTarget:self action:@selector(openContactSaveView:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.contactImageView setHidden:NO];
                    [cell.contactNameLabel setHidden:NO];
                    
                    NSString *nameStr = @"";
                    
                    if (![messageObj.firstName isEqualToString:@"(null)"] && ![messageObj.firstName isEqual:[NSNull null]] && messageObj.firstName.length != 0) {
                        nameStr = messageObj.firstName;
                    }
                    if (![messageObj.lastName isEqualToString:@"(null)"] && ![messageObj.lastName isEqual:[NSNull null]] && messageObj.lastName.length != 0) {
                        nameStr = [NSString stringWithFormat:@"%@ %@",nameStr, messageObj.lastName];
                    }
                    
                    if ([nameStr hasPrefix:@" "] && nameStr.length > 1) {
                        nameStr = [nameStr substringFromIndex:1];
                    }
                    
                    [cell.contactNameLabel setText:nameStr];
                }
                return cell;
            }
        }
    }
    else {
        
        GroupChatTable *messageObj = [self.messageArray objectAtIndex:indexPath.row];
        
        if ([currentUser isEqualToString:messageObj.sender]) {
            
            if ([messageObj.messageType intValue] == 0) {
                
                NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"GroupChatSenderCell" owner:self options:0];
                GroupChatSenderCell *cell = [nibArray objectAtIndex:0];
                cell.messageLabel.text = messageObj.message;
                [cell.timeLabel setText:[AppData relativeDateStringForDate:messageObj.time]];
                
                NSString *imageUrlStr = [NSString stringWithFormat:@"%@snaps/profile_Image/profileimage_%@.jpeg",HOST,[USER_DEFAULT valueForKey:kRUserIdKey]];
                
                [cell.userImageView loadImageFromURL:[NSURL URLWithString:imageUrlStr] PlaceHolderImage:[UIImage imageNamed:@"no_image.png"]];
                [cell.senderUserNameLabel setText:[USER_DEFAULT valueForKey:kRUserNameKey]];
                
                return cell;
            }
            else if ([messageObj.messageType intValue] == 5 || [messageObj.messageType intValue] == 1 || [messageObj.messageType intValue] == 2) {
                
                NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"GroupMapSenderCell" owner:self options:0];
                GroupMapSenderCell *cell = [nibArray objectAtIndex:0];

                [cell.timeLabel setText:[AppData relativeDateStringForDate:messageObj.time]];
                
                NSString *imageUrlStr = [NSString stringWithFormat:@"%@snaps/profile_Image/profileimage_%@.jpeg",HOST,[USER_DEFAULT valueForKey:kRUserIdKey]];
                
                [cell.userImageView loadImageFromURL:[NSURL URLWithString:imageUrlStr] PlaceHolderImage:[UIImage imageNamed:@"no_image.png"]];
                [cell.senderUserNameLabel setText:[USER_DEFAULT valueForKey:kRUserNameKey]];
                
                if ([messageObj.messageType intValue] == 5) {
                    
                    [cell showmap_lat:[messageObj.latitude doubleValue] lng:[messageObj.longitude doubleValue] title:messageObj.userName];
                    [cell.mapView setUserInteractionEnabled:NO];
                    [cell.chatImageView setHidden:YES];
                    [cell.mapView setHidden:NO];
                    [cell.imageButton setImage:nil forState:UIControlStateNormal];
                    
                    [cell.imageButton setTag:indexPath.row+1000];
                    [cell.imageButton addTarget:self action:@selector(btnImageClicked:) forControlEvents:UIControlEventTouchUpInside];
                }
                else {
                    
                    [cell.chatImageView setHidden:NO];
                    [cell.mapView setHidden:YES];
                    [cell.imageButton setImage:nil forState:UIControlStateNormal];
                    
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
                    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
                    NSString *filePath = [documentsPath stringByAppendingPathComponent:messageObj.mediaUrl];
                    
                    if ([messageObj.messageType intValue] == 1) {
                        
                        NSData *pngData = [NSData dataWithContentsOfFile:filePath];
                        UIImage *image = [UIImage imageWithData:pngData];
                        
                        [cell.chatImageView setImage:image];
                        [cell.imageButton setTag:indexPath.row+1000];
                        [cell.imageButton addTarget:self action:@selector(btnImageClicked:) forControlEvents:UIControlEventTouchUpInside];
                    }
                    else {
                        [cell.chatImageView setImage:[self getThumbNail:filePath]];
                        [cell.imageButton setImage:[UIImage imageNamed:@"btn_play.png"] forState:UIControlStateNormal];
                        [cell.imageButton setTag:indexPath.row + 1000];
                        [cell.imageButton addTarget:self action:@selector(buttonVideoPlayTapped:) forControlEvents:UIControlEventTouchUpInside];
                    }
                    
                    if ([messageObj.mediaStatus intValue] == 0) {
                        
                        [cell.imageButton setImage:nil forState:UIControlStateNormal];
                        [cell.spinnerView setLineWidth:2.5];
                        [cell.spinnerBackView setHidden:NO];
                        [cell.spinnerView startAnimating];
                        
                        if (![[AppData sharedInstance].chatMediaArray containsObject:messageObj.mediaUrl]) {
                            
                            [[AppData sharedInstance].chatMediaArray addObject:messageObj.mediaUrl];
                            [[AppData sharedInstance] chatMediaUploadDownload];
                        }
                    }
                    else if ([messageObj.mediaStatus intValue] == 2) {
                        
                        [cell.imageButton setImage:[UIImage imageNamed:@"ic_upload.png"] forState:UIControlStateNormal];
                        [cell.spinnerBackView setHidden:YES];
                        [cell.spinnerView stopAnimating];
                        [cell.imageButton setTag:indexPath.row + 1000];
                        [cell.imageButton removeTarget:self action:@selector(buttonVideoPlayTapped:) forControlEvents:UIControlEventTouchUpInside];
                        [cell.imageButton removeTarget:self action:@selector(btnImageClicked:) forControlEvents:UIControlEventTouchUpInside];
                        [cell.imageButton addTarget:self action:@selector(buttonUploadDownloadTapped:) forControlEvents:UIControlEventTouchUpInside];
                    }
                    else if ([messageObj.mediaStatus intValue] == 1) {
                        
//                        [cell.imageButton setImage:[UIImage imageNamed:@"btn_play.png"] forState:UIControlStateNormal];
                        [cell.spinnerBackView setHidden:YES];
                        [cell.spinnerView stopAnimating];
                    }
                }
                
                return cell;
            }
            else if ([messageObj.messageType intValue] == 3 || [messageObj.messageType intValue] == 4) {
                
                NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"GroupAudioSenderCell" owner:self options:0];
                GroupAudioSenderCell *cell = [nibArray objectAtIndex:0];
                
                [cell.timeLabel setText:[AppData relativeDateStringForDate:messageObj.time]];
                
                NSString *imageUrlStr = [NSString stringWithFormat:@"%@snaps/profile_Image/profileimage_%@.jpeg",HOST,[USER_DEFAULT valueForKey:kRUserIdKey]];
                
                [cell.userImageView loadImageFromURL:[NSURL URLWithString:imageUrlStr] PlaceHolderImage:[UIImage imageNamed:@"no_image.png"]];
                [cell.senderUserNameLabel setText:[USER_DEFAULT valueForKey:kRUserNameKey]];
                
                if ([messageObj.messageType intValue] == 3) {
                    
                    [cell.playButton setHidden:NO];
                    [cell.progressBar setHidden:NO];
                    [cell.contactButton setHidden:YES];
                    [cell.contactImageView setHidden:YES];
                    [cell.contactNameLabel setHidden:YES];
                    [cell.playButton setTag:indexPath.row + 1000];
                    [cell.progressBar setTag:indexPath.row + 5000];
                    [cell.playButton addTarget:self action:@selector(btnPlay_Click:) forControlEvents:UIControlEventTouchUpInside];
                }
                else {
                    
                    [cell.playButton setHidden:YES];
                    [cell.progressBar setHidden:YES];
                    [cell.contactButton setHidden:NO];
                    [cell.contactImageView setHidden:NO];
                    [cell.contactNameLabel setHidden:NO];
                    
                    NSString *nameStr = @"";
                    
                    if (![messageObj.firstName isEqualToString:@"(null)"] && ![messageObj.firstName isEqual:[NSNull null]] && messageObj.firstName.length != 0) {
                        nameStr = messageObj.firstName;
                    }
                    if (![messageObj.lastName isEqualToString:@"(null)"] && ![messageObj.lastName isEqual:[NSNull null]] && messageObj.lastName.length != 0) {
                        nameStr = [NSString stringWithFormat:@"%@ %@",nameStr, messageObj.lastName];
                    }
                    
                    if ([nameStr hasPrefix:@" "] && nameStr.length > 1) {
                        nameStr = [nameStr substringFromIndex:1];
                    }
                    
                    [cell.contactNameLabel setText:nameStr];
                }
                return cell;
            }
        }
        else {
            if ([messageObj.messageType intValue] == 0) {
                
                NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"GroupChatRecieverCell" owner:self options:0];
                GroupChatRecieverCell *cell = [nibArray objectAtIndex:0];
                cell.messageLabel.text = messageObj.message;
                [cell.timeLabel setText:[AppData relativeDateStringForDate:messageObj.time]];
                
                NSString *imageUrlStr = [NSString stringWithFormat:@"%@snaps/profile_Image/profileimage_%@.jpeg",HOST,messageObj.sender];
                [cell.userImageView loadImageFromURL:[NSURL URLWithString:imageUrlStr] PlaceHolderImage:[UIImage imageNamed:@"no_image.png"]];
                [cell.senderUserNameLabel setText:messageObj.userName];
                
                return cell;
            }
            else if ([messageObj.messageType intValue] == 5 || [messageObj.messageType intValue] == 1 || [messageObj.messageType intValue] == 2) {
                
                NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"GroupMapRecieverCell" owner:self options:0];
                GroupMapRecieverCell *cell = [nibArray objectAtIndex:0];
                
                [cell.timeLabel setText:[AppData relativeDateStringForDate:messageObj.time]];
                
                NSString *imageUrlStr = [NSString stringWithFormat:@"%@snaps/profile_Image/profileimage_%@.jpeg",HOST,messageObj.sender];
                
                [cell.userImageView loadImageFromURL:[NSURL URLWithString:imageUrlStr] PlaceHolderImage:[UIImage imageNamed:@"no_image.png"]];
                [cell.senderUserNameLabel setText:messageObj.userName];
                
                if ([messageObj.messageType intValue] == 5) {
                    
                    [cell showmap_lat:[messageObj.latitude doubleValue] lng:[messageObj.longitude doubleValue] title:messageObj.userName];
                    [cell.mapView setUserInteractionEnabled:NO];
                    [cell.chatImageView setHidden:YES];
                    [cell.mapView setHidden:NO];
                    [cell.imageButton setImage:nil forState:UIControlStateNormal];
                    
                    [cell.imageButton setTag:indexPath.row+1000];
                    [cell.imageButton addTarget:self action:@selector(btnImageClicked:) forControlEvents:UIControlEventTouchUpInside];
                }
                else {
                    
                    [cell.chatImageView setHidden:NO];
                    [cell.mapView setHidden:YES];
                    
                    if ([messageObj.mediaStatus intValue] == 1) {
                        
                        [cell.imageButton setImage:nil forState:UIControlStateNormal];
                        [cell.spinnerBackView setHidden:YES];
                        [cell.spinnerView stopAnimating];
                        
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
                        NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
                        NSString *filePath = [documentsPath stringByAppendingPathComponent:messageObj.mediaUrl];
                        
                        if ([messageObj.messageType intValue] == 1) {
                            
                            NSData *pngData = [NSData dataWithContentsOfFile:filePath];
                            UIImage *image = [UIImage imageWithData:pngData];
                            
                            [cell.chatImageView setImage:image];
                            [cell.imageButton setTag:indexPath.row+1000];
                            [cell.imageButton addTarget:self action:@selector(btnImageClicked:) forControlEvents:UIControlEventTouchUpInside];
                        }
                        else {
                            [cell.chatImageView setImage:[self getThumbNail:filePath]];
                            [cell.imageButton setImage:[UIImage imageNamed:@"btn_play.png"] forState:UIControlStateNormal];
                            [cell.imageButton setTag:indexPath.row + 1000];
                            [cell.imageButton addTarget:self action:@selector(buttonVideoPlayTapped:) forControlEvents:UIControlEventTouchUpInside];
                        }
                    }
                    else if ([messageObj.mediaStatus intValue] == 2) {
                        
                        [cell.imageButton setImage:[UIImage imageNamed:@"ic_download.png"] forState:UIControlStateNormal];
                        [cell.spinnerView stopAnimating];
                        [cell.spinnerBackView setHidden:YES];
                        [cell.imageButton setTag:indexPath.row + 1000];
                        [cell.imageButton addTarget:self action:@selector(buttonUploadDownloadTapped:) forControlEvents:UIControlEventTouchUpInside];
                    }
                    else if ([messageObj.mediaStatus intValue] == 0) {
                        
                        [cell.imageButton setImage:nil forState:UIControlStateNormal];
                        [cell.spinnerView setLineWidth:2.5];
                        [cell.spinnerBackView setHidden:NO];
                        [cell.spinnerView startAnimating];
                        
                        [cell.imageButton setTag:indexPath.row + 1000];
                        [cell.imageButton addTarget:self action:@selector(cancelDownload:) forControlEvents:UIControlEventTouchUpInside];
                        
                        if (![[AppData sharedInstance].chatMediaArray containsObject:messageObj.mediaUrl]) {
                            
                            [[AppData sharedInstance].chatMediaArray addObject:messageObj.mediaUrl];
                            [[AppData sharedInstance] chatMediaUploadDownload];
                        }
                    }
                }
                
                return cell;
            }
            else if ([messageObj.messageType intValue] == 3 || [messageObj.messageType intValue] == 4) {
                
                NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"GroupAudioReceiverCell" owner:self options:0];
                GroupAudioReceiverCell *cell = [nibArray objectAtIndex:0];
                
                [cell.timeLabel setText:[AppData relativeDateStringForDate:messageObj.time]];
                
                NSString *imageUrlStr = [NSString stringWithFormat:@"%@snaps/profile_Image/profileimage_%@.jpeg",HOST,messageObj.sender];
                
                [cell.userImageView loadImageFromURL:[NSURL URLWithString:imageUrlStr] PlaceHolderImage:[UIImage imageNamed:@"no_image.png"]];
                [cell.senderUserNameLabel setText:messageObj.userName];
                
                if ([messageObj.messageType intValue] == 3) {
                    
                    [cell.playButton setHidden:NO];
                    [cell.progressBar setHidden:NO];
                    [cell.contactButton setHidden:YES];
                    [cell.contactImageView setHidden:YES];
                    [cell.contactNameLabel setHidden:YES];
                    [cell.playButton setTag:indexPath.row + 1000];
                    [cell.progressBar setTag:indexPath.row + 5000];
                    [cell.playButton addTarget:self action:@selector(btnPlay_Click:) forControlEvents:UIControlEventTouchUpInside];
                }
                else {
                    
                    [cell.playButton setHidden:YES];
                    [cell.progressBar setHidden:YES];
                    [cell.contactButton setHidden:NO];
                    [cell.contactButton setTag:indexPath.row + 1000];
                    [cell.contactButton addTarget:self action:@selector(openContactSaveView:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.contactImageView setHidden:NO];
                    [cell.contactNameLabel setHidden:NO];
                    
                    NSString *nameStr = @"";
                    
                    if (![messageObj.firstName isEqualToString:@"(null)"] && ![messageObj.firstName isEqual:[NSNull null]] && messageObj.firstName.length != 0) {
                        nameStr = messageObj.firstName;
                    }
                    if (![messageObj.lastName isEqualToString:@"(null)"] && ![messageObj.lastName isEqual:[NSNull null]] && messageObj.lastName.length != 0) {
                        nameStr = [NSString stringWithFormat:@"%@ %@",nameStr, messageObj.lastName];
                    }
                    
                    if ([nameStr hasPrefix:@" "] && nameStr.length > 1) {
                        nameStr = [nameStr substringFromIndex:1];
                    }
                    
                    [cell.contactNameLabel setText:nameStr];
                }
                return cell;
            }
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.snapObject.group_id intValue] == 0) {
        
        SingleChatTable *messageObj = [self.messageArray objectAtIndex:indexPath.row];
        if (![messageObj.isRead boolValue]) {
            messageObj.isRead = [NSNumber numberWithBool:1];
            [APP_DELEGATE saveContext];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"messageReceived" object:nil];
        }
    }
    else {
        GroupChatTable *messageObj = [self.messageArray objectAtIndex:indexPath.row];
        if (![messageObj.isRead boolValue]) {
            messageObj.isRead = [NSNumber numberWithBool:1];
            [APP_DELEGATE saveContext];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"messageReceived" object:nil];
        }
    }
    
}

#pragma mark - Audio Recorder methods -

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
//    [self.recorderView setHidden:YES];
    if (flag == TRUE) {
        
        if (sendAudio) {
            
            [self saveMessageLocallyWithType:@"3" MediaUrl:mediaNameString ContactDetail:@"{}" LocationDetail:@"{}"];
            
            [[AppData sharedInstance].chatMediaArray addObject:mediaNameString];
            [[AppData sharedInstance] chatMediaUploadDownload];
        }
    }
    else {
        [AppData showAlertWithTitle:@"" Message:@"Sound doesn't recorded successfully." CancelButtonTitle:@"OK"];
    }
}

- (IBAction)btnPlay_Click:(UIButton *)sender
{
    if (sender.selected) {
        [newPlayer stop];
        [sender setSelected:NO];
        [audioTimer invalidate];
        
        UIProgressView *progressBar = (UIProgressView *)[self viewWithTag:((int)sender.tag + 4000)];
        [progressBar setProgress:0.0f];
        return;
    }
    [sender setSelected:YES];
    NSString *mediaName;
    int tag = (int)sender.tag;
    selectedIndex = tag;
    
    if ([self.snapObject.group_id intValue] == 0) {
        
        SingleChatTable *messageObj = [self.messageArray objectAtIndex:tag-1000];
        mediaName = messageObj.mediaUrl;
    }
    else {
        
        GroupChatTable *messageObj = [self.messageArray objectAtIndex:tag-1000];
        mediaName = messageObj.mediaUrl;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:mediaName];
    
    NSData *audioData = [NSData dataWithContentsOfFile:filePath];
    
    if (audioData == nil)
    {
        [AppData showAlertWithTitle:@"" Message:@"Audio file not found." CancelButtonTitle:@"OK"];
    }
    else
    {
        [[AVAudioSession sharedInstance] setDelegate: self];
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: nil];
        
        
        NSError *activationError = nil;
        [[AVAudioSession sharedInstance] setActive: YES error: &activationError];
        
        NSError *error;
        newPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:&error];
        
        [[AVAudioSession sharedInstance] setDelegate: self];
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: nil];
        
        
        //  AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: newURL error: nil];
        [newPlayer prepareToPlay];
        [newPlayer setVolume: 40.0];
        [newPlayer setDelegate: self];
        [newPlayer play];
        audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(setAudioProgress) userInfo:nil repeats:YES];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag) {
        
        UIButton *button = (UIButton *)[self viewWithTag:selectedIndex];
        [button setSelected:NO];
        
        UIProgressView *progressBar = (UIProgressView *)[self viewWithTag:selectedIndex+4000];
        [progressBar setProgress:0.0f];
        
        [audioTimer invalidate];
    }
}

- (void)setAudioProgress
{
    UIProgressView *progressBar = (UIProgressView *)[self viewWithTag:selectedIndex+4000];
    [progressBar setProgress:newPlayer.currentTime/newPlayer.duration];
}

#pragma mark - UIImagePickerControllerDelegate -

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    NSString *type = @"";
//    NSLog(@"Video recorded: %@", info);
    if ([[info valueForKey:@"UIImagePickerControllerMediaType"] isEqualToString:@"public.image"]) {
        
        type = @"image";
        UIImage *image = [info valueForKey:@"UIImagePickerControllerOriginalImage"];
        mediaData = [UIImageJPEGRepresentation(image, 1.0) mutableCopy];
        
        mediaNameString = [self getMediaName];
        mediaNameString = [NSString stringWithFormat:@"%@.png",mediaNameString];
        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            image = [AppData scaleImage:image toSize:CGSizeMake(640, 1136)];
        }
        else {
            
            if (mediaData.length > 2000000) {
                
                image = [AppData scaleImage:image toSize:CGSizeMake(640, 1136)];
            }
        }
        
        NSData *imageData = UIImagePNGRepresentation(image);
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
        NSString *filePath = [documentsPath stringByAppendingPathComponent:mediaNameString];
        
        [imageData writeToFile:filePath atomically:YES];
        
        [self saveMessageLocallyWithType:@"1" MediaUrl:mediaNameString ContactDetail:@"{}" LocationDetail:@"{}"];
        
//        [self uploadImageForChat:@"" MediaType:@"1"];
        [[AppData sharedInstance].chatMediaArray addObject:mediaNameString];
        [[AppData sharedInstance] chatMediaUploadDownload];
    }
    else {
        
        type = @"video";
        mediaData = [[NSData dataWithContentsOfFile:[info valueForKey:@"UIImagePickerControllerMediaURL"]] mutableCopy];
        
        mediaNameString = [self getMediaName];
        mediaNameString = [NSString stringWithFormat:@"%@.mov",mediaNameString];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
        NSString *filePath = [documentsPath stringByAppendingPathComponent:mediaNameString];
        
        [mediaData writeToFile:filePath atomically:YES];
        
        [self saveMessageLocallyWithType:@"2" MediaUrl:mediaNameString ContactDetail:@"{}" LocationDetail:@"{}"];
        
//        [self uploadImageForChat:@"" MediaType:@"2"];
        [[AppData sharedInstance].chatMediaArray addObject:mediaNameString];
        [[AppData sharedInstance] chatMediaUploadDownload];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ABAddressBook Delegate -

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person
{
    ABMultiValueRef firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    ABMultiValueRef lastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
    ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
    ABMultiValueRef phoneNumber = ABRecordCopyValue(person, kABPersonPhoneProperty);
//    ABMultiValueRef address = ABRecordCopyValue(person, kABPersonAddressProperty);
    
    NSString *firstNameString = (__bridge NSString *)firstName;
    NSString *lastNameString = (__bridge NSString*)lastName;
    
    NSString *phoneNumberString;
    NSString *emailString;
//    NSString *addressString;
    BOOL isFirst = YES;
    
    for(CFIndex j = 0; j < ABMultiValueGetCount(phoneNumber); j++)
    {
        CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phoneNumber, j);
//        CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(phoneNumber, j);

//        NSString *phoneLabel = (__bridge NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
        NSString *phoneNumber = (__bridge NSString *)phoneNumberRef;

        if (isFirst) {
            isFirst = NO;
            phoneNumberString = [NSString stringWithFormat:@"%@", phoneNumber];
        }
        else {
            phoneNumberString = [NSString stringWithFormat:@"%@,%@", phoneNumberString, phoneNumber];
        }
    }
    
    isFirst = YES;
    
    for(CFIndex j = 0; j < ABMultiValueGetCount(email); j++)
    {
        CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(email, j);
//        CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(email, j);
        
//        NSString *phoneLabel = (__bridge NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
        NSString *phoneNumber = (__bridge NSString *)phoneNumberRef;
        
        if (isFirst) {
            isFirst = NO;
            emailString = [NSString stringWithFormat:@"%@", phoneNumber];
        }
        else {
            emailString = [NSString stringWithFormat:@"%@,%@", emailString, phoneNumber];
        }
    }
    
    isFirst = YES;
    
//    for(CFIndex j = 0; j < ABMultiValueGetCount(address); j++)
//    {
//        CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(address, j);
////        CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(address, j);
//        
////        NSString *phoneLabel = (__bridge NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
//        NSDictionary *phoneNumber = (__bridge NSDictionary *)phoneNumberRef;
//        
//        if (isFirst) {
//            isFirst = NO;
//            addressString = [NSString stringWithFormat:@"%@", phoneNumber];
//        }
//        else {
//            addressString = [NSString stringWithFormat:@"%@,%@", addressString, phoneNumber];
//        }
//    }
    
    NSString *contactString = [NSString stringWithFormat:@"{\"firstName\":\"%@\", \"lastName\":\"%@\", \"phoneNumbers\":\"%@\", \"emails\":\"%@\", \"address\":\"%@\"}", firstNameString, lastNameString, phoneNumberString, emailString, @""];
    
    [self sendChatWithMediaType:@"4" MediaUrl:@"" ContactDetail:contactString LocationDetail:@"{}"];
}

#pragma mark - Connection Delegate -

- (void)uploadImageForChat:(NSString *)imageName MediaType:(NSString *)mediaType
{
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",HOST,mUploadChatMedia];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setHTTPShouldHandleCookies:NO];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:300];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = [NSString stringWithFormat:@"---------------------------14737809831466499882746641449"];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    NSString *sessionToken = [[NSUserDefaults standardUserDefaults]valueForKey:@"SessionToken"];
    NSString *userId = [[NSUserDefaults standardUserDefaults]valueForKey:kRUserIdKey];
    
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc] init];
    [sendData setObject:userId forKey:@"owner_id"];
    [sendData setObject:sessionToken forKey:@"user_session_token"];
//    [sendData setObject:imageName forKey:@"media_name"];
    [sendData setObject:mediaType forKey:@"media_type"];
//    [sendData setObject:@"Upload" forKey:@"upload_media_submit"];
    
//    if (mediaData != nil) {
//        
//        NSString *imageString = [mediaData base64Encoding];
//        [sendData setObject:imageString forKey:@"uploaded_file"];
//    }
    mediaTypeString = mediaType;
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: attachment; name=\"uploaded_file\"; filename=\"%@\"\r\n",mediaNameString] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:mediaData];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];

    for (id key in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:[sendData valueForKey:key]] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", (int)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setURL:[NSURL URLWithString:urlStr]];
    updateCon = [NSURLConnection connectionWithRequest:request delegate:self];
    if (updateCon) {
        updateData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [updateData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [updateData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    ProgressIndicator *pi = [ProgressIndicator sharedInstance];
    [pi hideProgressIndicator];
    
    [AJNotificationView showNoticeInView:APP_DELEGATE.window type:AJNotificationTypeRed title:@"No Network" hideAfter:3];
    
//    [AppData showAlertWithTitle:@"" Message:@"Network error" CancelButtonTitle:@"OK"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:updateData options:0 error:nil];
    
    if ([[dict valueForKey:@"statusNumber"] intValue] == 188) {
        
//        [self sendChatWithMediaType:mediaTypeString MediaUrl:@"" ContactDetail:@"{}" LocationDetail:@"{}"];
        [self updateMessageWithMediaName:mediaNameString];
    }
    else {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"error" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - Get Media Name Method

- (NSString *)getMediaName
{
    NSDate *currentDateTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE_MM_dd_yyyy_HH_mm_ss"];
    NSString *dateInStringFormated = [dateFormatter stringFromDate:currentDateTime];
    return dateInStringFormated;
}

#pragma mark - Video Image -

-(UIImage *)getThumbNail:(NSString *)stringPath
{
    NSURL *videoURL = [NSURL fileURLWithPath:stringPath];
    
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
    
    UIImage *thumbnail = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
    
    //Player autoplays audio on init
    [player stop];
    return thumbnail;
}

#pragma mark - Map Methods -

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString * const kPinAnnotationIdentifier = @"AnnotationIdentifier";
    
    MKAnnotationView *mapAnnotation = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier];
    mapAnnotation.canShowCallout = YES;
    
    if ([annotation.title isEqualToString:@"Current Location"])
    {
        return nil;
    }
    else{
        [mapAnnotation setImage:[UIImage imageNamed:@"Pin.png"]];
        
        mapAnnotation.canShowCallout = YES;
        return mapAnnotation;
    }
}

@end
