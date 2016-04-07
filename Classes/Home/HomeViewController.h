//
//  HomeViewController.h
//  Tinder
//
//  Created by Sanskar on 26/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "BaseVC.h"


#import <FacebookSDK/FBSessionTokenCachingStrategy.h>
#import <FacebookSDK/FacebookSDK.h>
#import "TinderFBFQL.h"
#import "EGOImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "RoundedImageView.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageDownloader.h"
#import "ChatViewController.h"
#import "UIImageView+Download.h"
#import "QuestionVC.h"
#import "ProfileVC.h"
//#import "MomentsVC.h"
//#import "MenuViewController.h"

@class MenuViewController,ChatViewController; //MomentsVC
@interface HomeViewController : BaseVC< TinderFBFQLDelegate,UIScrollViewDelegate>
{
    IBOutlet UIButton *btnInvite;
    IBOutlet UIView *viewItsMatched;
    IBOutlet UILabel *lblItsMatchedSubText;
    IBOutlet UILabel *lblNoFriendAround;

    IBOutlet UIView *homeScreenView;
    IBOutlet UIScrollView *scrollVwContainer;
   
   
    ChatViewController *chatVC;
  //  MomentsVC *momentsVC;
    MenuViewController *menuVC;
    
}
@property (weak, nonatomic) IBOutlet UIImageView *profileGroupIcon;
@property (weak, nonatomic) IBOutlet UIImageView *profileBookIcon;

@property(nonatomic,strong)IBOutlet UIView *viewPercentMatch;
@property(nonatomic,strong)IBOutlet UILabel *lblPercentMatch;

-(IBAction)openMail :(id)sender;
-(IBAction)btnActionForItsMatchedView :(id)sender;

- (IBAction)btnChattingTapped:(id)sender;
@end
