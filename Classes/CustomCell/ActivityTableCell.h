//
//  ActivityTableCell.h
//  Tinder
//
//  Created by Sanskar on 05/01/15.
//  Copyright (c) 2015 AppDupe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
#import "Activity.h"

@interface ActivityTableCell : UITableViewCell

@property (strong, nonatomic) IBOutlet EGOImageView *imgUserPic;
@property (strong, nonatomic) IBOutlet EGOImageView *imgMoment;
@property (strong, nonatomic) IBOutlet UILabel *lblUserAndTime;
@property (strong, nonatomic) IBOutlet UILabel *lblActivityName;

@property (strong, nonatomic) IBOutlet UIButton *btnUsePicOutlet;
@property (strong, nonatomic) IBOutlet UIButton *btnMomentPicOutlet;

-(void)setDataInCellForActivity : (Activity *)activity;
-(void)setDataInCellForLike : (NSDictionary *)dictLike;
@end
