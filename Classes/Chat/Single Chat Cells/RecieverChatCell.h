//
//  RecieverChatCell.h
//  snapchatclone
//
//  Created by soumya ranjan sahu on 10/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface RecieverChatCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet AsyncImageView *userImageView;


@end
