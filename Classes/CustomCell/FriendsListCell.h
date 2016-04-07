//
//  FriendsListCell.h
//  ArroundMeNow
//
//  Created by Macmini New on 11/5/13.
//  Copyright (c) 2013 B24 E Solutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
@class User;

@interface FriendsListCell : UITableViewCell
@property (strong, nonatomic) IBOutlet EGOImageView *imageCellUser;
@property (strong, nonatomic) IBOutlet UIImageView *imgOnLineOffLine;
@property (strong, nonatomic) IBOutlet UILabel *lblNameCell;

@property (strong, nonatomic) IBOutlet UILabel *lblMsgCounter;
@property (strong, nonatomic) IBOutlet UILabel *lblLastMsg;
@property (strong, nonatomic) IBOutlet UILabel *lblLastMsgTime;
@property (strong, nonatomic) IBOutlet UIImageView *imgTick1;
@property (strong, nonatomic) IBOutlet UIImageView *imgTick2;
@property (strong, nonatomic) IBOutlet UITextView *txtLastMsg;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lblnameTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lblLastMsgHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lblLastMsgTopConstraint;



- (void) displayImageInRoundShape;

-(void)setData:(int)index dictForChat:(User *)xmppFriend;

-(void)setDataForMatchedUser:(int)index dictForChat:(NSDictionary *)dictObj;
@end
