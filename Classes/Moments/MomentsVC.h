//
//  MomentsVC.h
//  Tinder
//
//  Created by Sanskar on 26/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
#import "Moment.h"
#import "MomentsCell.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "ActivityTableCell.h"
#import "UICircularSlider.h"
#import "CaptureMomentVC.h"

typedef enum {
    ActionSheetImagePicker,
    ActionSheetOtherOptionsMoment,
}ActionSheetTags;


@interface MomentsVC : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate,CaptureMomentVCDelegate>
{
    IBOutletCollection(UIButton) NSArray *btnActionsOrMoment;
    UIImagePickerController *ipicker;
   
    IBOutlet UIView *vwMomentSubview;
    IBOutlet EGOImageView *imgPhotoLarge;
    IBOutlet UILabel *lblMomentExpiration;
    IBOutlet UILabel *lblLikeReceived;
    
    IBOutlet UIView *vwSubvwOfLikeOrTime;
    IBOutlet UIImageView *imgHeartOrTimer;
    IBOutlet UILabel *lblLikeOrTimer;
    IBOutlet UISlider *sliderLikeOrTimeRemain;
    IBOutlet UITableView *tblLikeReceived;
    IBOutlet UIView *vwTimer;
    IBOutlet UILabel *lblExpireDayTime;
    IBOutlet UILabel *lblExpireTimeRemain;
    
    IBOutlet UIView *vwCapture;
}
@property (nonatomic, unsafe_unretained) IBOutlet UICircularSlider *likeReceivedSlider;
@property (nonatomic, unsafe_unretained) IBOutlet UICircularSlider *timeElapsedSlider;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UITableView *tblActivity;
@property (retain, nonatomic)  NSMutableArray *arrayActivities;
@property (retain, nonatomic)  NSMutableArray *arrayMyMoments;
@property (retain, nonatomic)  NSMutableArray *arrayLikes;
@property (strong, atomic) ALAssetsLibrary* library;
@end
