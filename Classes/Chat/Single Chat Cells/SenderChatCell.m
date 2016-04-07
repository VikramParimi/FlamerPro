//
//  senderChatCell.m
//  snapchatclone
//
//  Created by soumya ranjan sahu on 10/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "SenderChatCell.h"

@implementation SenderChatCell

- (void)awakeFromNib
{
    [self.userImageView.layer setCornerRadius:22];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
