//
//  EditMyInfoViewCell.h
//  Karmic
//
//  Created by Sanskar on 21/11/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface EditMyInfoViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet EGOImageView *imgPhoto;
@property (strong, nonatomic) IBOutlet UIButton *btnAddRemove;
@end
