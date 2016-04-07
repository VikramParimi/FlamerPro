//
//  SingleAudioReceiverCell.m
//  snapchatclone
//
//  Created by soumya ranjan sahu on 20/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "SingleAudioReceiverCell.h"

@implementation SingleAudioReceiverCell

- (void)awakeFromNib
{
    [self.contactImageView.layer setCornerRadius:22.5f];
    [self.userImageView.layer setCornerRadius:22];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
