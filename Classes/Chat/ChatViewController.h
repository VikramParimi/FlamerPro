//
//  ChatViewController.h
//  Tinder
//
//  Created by Sanskar on 26/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NSData+Base64Encoding.h"
//#import "XmppFriendHandler.h"
//#import "XmppCommunicationHandler.h"
#import "EGOImageView.h"
//#import "CaptureMomentVC.h"
#import "FriendsListCell.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageDownloader.h"
#import "ProgressIndicator.h"
#import "UIImageView+Download.h"
//#import "MomentsVC.h"
//#import "Moment.h"
//#import "MomentsDetailsViewController.h"


@interface ChatViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, XMPPHandlerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
{
  
    NSMutableArray *arrayXmppFriends;
   
    IBOutlet UIView *vwContainer;
  /*  IBOutlet UIView *vwMoments;
    
    IBOutlet UIView *vwMoment2;
    IBOutlet UIView *vwMoment1;
    
    IBOutlet EGOImageView *imgMoment;
    IBOutlet UILabel *lblMomentsCount;
    IBOutlet UILabel *lblMomentTime;*/
    
   // UIImagePickerController *ipicker;
   // IBOutlet UIView *vwCapture;
    
    NSMutableArray *filteredContentList;
    BOOL isSearching;
}
@property (strong , nonatomic) IBOutlet UITableView *tblView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchBarController;


@end

