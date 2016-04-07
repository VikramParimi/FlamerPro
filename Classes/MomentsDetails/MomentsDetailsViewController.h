//
//  MomentsDetailsViewController.h
//  Tinder
//
//  Created by Sanskar on 01/01/15.
//  Copyright (c) 2015 AppDupe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Moment.h"
#import "EGOImageView.h"
#import <MessageUI/MessageUI.h>

typedef enum {
    TagDislike,
    TagLike
}likeDislikeTag;

@protocol MomentVCDelegate <NSObject>

-(void)chatButtonTappedWithMoment:(Moment *)moment;
-(void)hideMomentsDetailView:(NSMutableArray *)arrayMomentsUpdated;

@end

@interface MomentsDetailsViewController : UIViewController<UIActionSheetDelegate,UIAlertViewDelegate,MFMailComposeViewControllerDelegate>
{
    
    IBOutlet UIView *vwMoment1;
    IBOutlet EGOImageView *imgMoment1;
    IBOutlet EGOImageView *imgUserMoment1;
    IBOutlet UILabel *lblUsernameMoment1;
    IBOutlet UILabel *lblTimeMoment1;
   
    IBOutlet UIView *vwMoment2;
    IBOutlet EGOImageView *imgMoment2;
    IBOutlet EGOImageView *imgUserMoment2;
    IBOutlet UILabel *lblUsernameMoment2;
    IBOutlet UILabel *lblTimeMoment2;
    
    IBOutlet UIView *vwMoment3;
    IBOutlet UIView *vwMoment4;
}
@property (nonatomic,retain) id <MomentVCDelegate> delegate;
@property (nonatomic,retain) NSMutableArray *arrayMoments;
- (IBAction)swipeRight:(id)sender;
- (IBAction)swipeLeft:(id)sender;


@end
