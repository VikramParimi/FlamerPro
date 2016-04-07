//
//  MomentsCell.h
//  Tinder
//
//  Created by Sanskar on 26/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface MomentsCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet EGOImageView *imgPhoto;
@property (nonatomic,retain)  IBOutlet UILabel  *lblMomentExpiration;
@property (nonatomic,retain)  IBOutlet UILabel  *lblLikeReceived;
@property (nonatomic,retain)  IBOutlet UIButton *btnMoment;
@end
