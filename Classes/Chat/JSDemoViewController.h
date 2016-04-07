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

#import "JSMessagesViewController.h"
#import "XmppFriend.h"
#import "User.h"
#import "XmppSingleChatHandler.h"
#import <MessageUI/MessageUI.h>

@class User;
@interface JSDemoViewController : JSMessagesViewController <JSMessagesViewDataSource, JSMessagesViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MFMailComposeViewControllerDelegate>
{
    User *currentChatObj;
    BOOL isReloding;
    
     
}

@property (strong,nonatomic)User *currentChatObj;

@property (strong, nonatomic) NSString *currentMessage;
@property (strong , nonatomic) UIView *customSlidingView;

@end
