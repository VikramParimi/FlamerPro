//
//  FriendsListCell.m
//  ArroundMeNow
//
//  Created by Macmini New on 11/5/13.
//  Copyright (c) 2013 B24 E Solutions pvt ltd. All rights reserved.
//

#import "FriendsListCell.h"
#import "User.h"
#import "Photo.h"
//#import "XmppSingleChatHandler.h"

@implementation FriendsListCell
@synthesize lblNameCell,imageCellUser,imgOnLineOffLine;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setData:(int)index dictForChat:(User *)xmppFriend
{
    if (xmppFriend.name.length)
        self.lblNameCell.text = xmppFriend.name;
    else
        self.lblNameCell.text = xmppFriend.name;
    
    //NSLog( @"MsgCount %d",[xmppFriend.messageCount intValue]);
    
    if ([xmppFriend messageCount])
    {
        self.lblMsgCounter.text = [NSString stringWithFormat:@"%d",[xmppFriend messageCount]];
    }
    else
        self.lblMsgCounter.text = @"";
    
    
    if (![[xmppFriend lastMessage] isEqualToString:@"You 're a match! Now say Hi :)"])
    {
        self.lblLastMsgTime.text = [self converttoDate:xmppFriend.lastMessageTime ];
    }
    else
        self.lblLastMsgTime.text = xmppFriend.lastMessageTime;
    
    
    // double lastmsgInt = [xmppFriend.lastMessageTime doubleValue];
    
    // if ([xmppFriend.lastMessageTime isKindOfClass:[NSString class]])
    {
        // NSLog(@"last message is string type");
    }
    
    Photo* photo0 = [xmppFriend photoIndex:0];
    if (photo0 != nil)
        [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[Helper removeWhiteSpaceFromURL:photo0.url]]]];
    
   /* if ([[[XmppCommunicationHandler sharedInstance] xmppStream]isConnected])
    {
        if ([xmppFriend.presenceStatus isEqualToString:@"Online"])
        {
            self.imgOnLineOffLine.image = [UIImage imageNamed:@"on_line.png"];
        }
        else
        {
            self.imgOnLineOffLine.image = [UIImage imageNamed:@"off_line.png"];
        }
    }
    else
    {
        self.imgOnLineOffLine.image = [UIImage imageNamed:@"off_line.png"];
    }
    
    if (xmppFriend.profileImage.length) {
        self.imageCellUser.image =[UIImage imageWithData:xmppFriend.profileImage];
    }
    else
        self.imageCellUser.image =[UIImage imageNamed:@"friend.png"];*/
    
    
    /*[self displayImageInRoundShape];
    
    _lblnameTopConstraint.constant = 8;
    self.imgOnLineOffLine.hidden = NO;
    self.lblLastMsg.hidden = NO;    
    
    if([xmppFriend.lastMessageStatus isEqualToString:@"W"] || [xmppFriend.lastMessageStatus isEqualToString:@"S"])
    {
        [self.imgTick1 setImage:[UIImage imageNamed:@"tick_gray.png"]];
        self.imgTick1.hidden = NO;
        self.imgTick2.hidden = YES;
    }
    else if([xmppFriend.lastMessageStatus isEqualToString:@"D"])
    {
        [self.imgTick1 setImage:[UIImage imageNamed:@"tick_gray.png"]];
        self.imgTick1.hidden = NO;
        self.imgTick2.hidden = NO;
    }
    else if(xmppFriend.lastMessage.length)
    {
        [self.imgTick1 setImage:[UIImage imageNamed:@"ReceiveMsg.png"]];
        self.imgTick1.hidden = NO;
        self.imgTick2.hidden = YES;
    }
    else
    {
        self.imgTick1.hidden = YES;
        self.imgTick2.hidden = YES;
        self.lblLastMsgTime.text = @"";
    }*/
    
    self.lblLastMsg.text = [xmppFriend lastMessage];
    
    
    CGFloat ScreenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    CGSize  maximumLabelSize = CGSizeMake(ScreenWidth - 135,9999);
    
    
    
    CGSize expectedMsgSize = [xmppFriend.lastMessage sizeWithFont:[UIFont systemFontOfSize:[[self.lblLastMsg font] pointSize]]
                                                constrainedToSize:maximumLabelSize
                                                    lineBreakMode:NSLineBreakByTruncatingTail];
    
    if(expectedMsgSize.height < [[self.lblLastMsg font] pointSize]+ 3)
    {
        self.lblLastMsgHeightConstraint.constant = 2 * expectedMsgSize.height -2;
        self.lblLastMsgTopConstraint.constant = -2;
    }
    else
    {
        self.lblLastMsgHeightConstraint.constant = 2 * [[self.lblLastMsg font] pointSize] + 6;
        self.lblLastMsgTopConstraint.constant = 4;
    }
    
    //Updated By Sanskar
    self.imgTick1.hidden = YES;
    self.imgTick2.hidden = YES;
    [self.lblLastMsgTime setHidden:YES];
    [self setUIForBlockedUser:xmppFriend];
    
}

-(void)setUIForBlockedUser:(User *)xmppFriend
{
    if ([xmppFriend.isBlocked isEqualToString:@"YES"])
    {
        [self.lblNameCell setTextColor:[UIColor lightGrayColor]];
        CGRect frameLbl = self.lblNameCell.frame;
        frameLbl.origin.y = 24;
        self.lblNameCell.frame = frameLbl;
        
        self.lblLastMsg.text = @"";
        self.lblMsgCounter.text = @"";
        
        [self.imgOnLineOffLine setHidden:YES];
        
        _lblnameTopConstraint.constant = 24;
        self.lblLastMsg.hidden = YES;
        self.imgTick1.hidden = YES;
        self.imgTick2.hidden = YES;
        self.lblLastMsgTime.hidden = YES;
        self.imageCellUser.image = [UIImage imageNamed:@"defaultPerson.png"];
    }
}

-(NSString *)converttoDate :(NSString *)strTimeSatmp
{
    NSString * timeStampString =[NSString stringWithFormat:@"%@",strTimeSatmp];
    NSTimeInterval _interval=[timeStampString doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSString *resultDate = [Helper relativeDateStringForDate:date];
        return resultDate;
}


- (void) displayImageInRoundShape
{
    [self.imageCellUser.layer setCornerRadius:22.5f];
    self.imageCellUser.clipsToBounds=YES;
  //  self.imageCellUser.layer.borderColor=[UIColor colorWithRed:1/255.0 green:160/255.0 blue:224/255.0 alpha:1.0f].CGColor;
  //  self.imageCellUser.layer.borderWidth=1.5f;
}

@end
