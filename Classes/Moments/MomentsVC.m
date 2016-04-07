//
//  MomentsVC.m
//  Tinder
//
//  Created by Sanskar on 26/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "MomentsVC.h"
#import "JSDemoViewController.h"
#import "XmppFriendHandler.h"

#define ScreenSize [UIScreen mainScreen].bounds.size
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface MomentsVC ()
{
    BOOL isMyMomentsSelected;
    Moment *selectedMoment;
    Activity *selectedActivity;
    CGRect selectedCellRect;
    CGRect selectedRectForTimer_Like;
    UIImageView *imgVwSaveImg;
    IBOutlet UIView *vwMode;
}

@end

@implementation MomentsVC
static NSString * const cellIdentifier = @"CellImage";


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [self initialSetupView];
    
    self.library = [[ALAssetsLibrary alloc] init];
    
    [self.collectionView registerClass:[MomentsCell class] forCellWithReuseIdentifier:cellIdentifier];
    
   
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(momentScreenRefresh) name:NOTIFICATION_MOMENTSCREEN_REFRESH object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleForMomentCreateDeletedNotification) name:NOTIFICATION_NEW_MOMENT_CREATED_DELETED object:nil];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self callForWebseviceToGetAllMyMoments];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self callForWebseviceToGetAllActivities];
    });
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
}

//Notification to Call Webservices For Data Updation
-(void)momentScreenRefresh
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self callForWebseviceToGetAllActivities];
    });
}

//Notification New Moment Created or Deleted
-(void)handleForMomentCreateDeletedNotification
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self callForWebseviceToGetAllMyMoments];
    });

}

#pragma mark - Tap gesture handling

- (IBAction)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self hideMomentDetailSubview];
}

-(void)initialSetupView
{
    //Setup Moments Subview
    [vwMode.layer setCornerRadius:10.0];
    [vwMode.layer setMasksToBounds:YES];
    [vwMode.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [vwMode.layer setBorderWidth:1.0];
    
    //Initially Actions Mode Selected
    for (UIButton *btn in btnActionsOrMoment)
    {
        if (btn.tag == 20)
        {
            [btn setSelected:YES];
        }
    }
    
    isMyMomentsSelected = YES;
    [self.collectionView setHidden:NO];
    [self.tblActivity setHidden:YES];
    
    
    //Setup Moments Subview
    [imgPhotoLarge.layer setCornerRadius:10.0];
    [imgPhotoLarge.layer setMasksToBounds:YES];
    
    [vwMomentSubview setBackgroundColor:[UIColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:0.3]];
    UIGestureRecognizer * gestureRecognizerTap = [[UITapGestureRecognizer alloc]
                                                  initWithTarget:self action:@selector(handleSingleTap:)];
    gestureRecognizerTap.cancelsTouchesInView = NO;
    gestureRecognizerTap.delegate = self;
    [imgPhotoLarge addGestureRecognizer:gestureRecognizerTap];
    [imgPhotoLarge setUserInteractionEnabled:YES];

    //Setup sliders for like received and time elapsed
    self.timeElapsedSlider.minimumValue = 0.0;
    self.timeElapsedSlider.maximumValue =24.0;
    self.timeElapsedSlider.value = 0;
    self.timeElapsedSlider.continuous = NO;
    [_timeElapsedSlider setThumbTintColor:[UIColor clearColor]];
    [_timeElapsedSlider setMinimumTrackTintColor:RED_STRIP_COLOR];
    [_timeElapsedSlider setMaximumTrackTintColor:[UIColor blackColor]];
    [_timeElapsedSlider setUserInteractionEnabled:NO];
    [_timeElapsedSlider setBackgroundColor:[UIColor clearColor]];
    
    self.likeReceivedSlider.minimumValue = 0;
    self.likeReceivedSlider.maximumValue = 1;
    self.likeReceivedSlider.value = 0;
    self.likeReceivedSlider.continuous = NO;
    [_likeReceivedSlider setThumbTintColor:[UIColor clearColor]];
    [_likeReceivedSlider setMinimumTrackTintColor:RED_STRIP_COLOR];
    [_likeReceivedSlider setMaximumTrackTintColor:[UIColor blackColor]];
    [_likeReceivedSlider setUserInteractionEnabled:NO];
    [_likeReceivedSlider setBackgroundColor:[UIColor clearColor]];
    
    //Rotate sliders by 90'
    double rads = DEGREES_TO_RADIANS(135);
    CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, rads);
    self.likeReceivedSlider.transform = transform;
    self.timeElapsedSlider.transform = transform;
    
    [_likeReceivedSlider setMinimumTrackTintColor:RED_STRIP_COLOR];
    [_likeReceivedSlider setMaximumTrackTintColor:[UIColor darkGrayColor]];
    [_timeElapsedSlider setMinimumTrackTintColor:RED_STRIP_COLOR];
    [_timeElapsedSlider setMaximumTrackTintColor:[UIColor darkGrayColor]];
    
    [vwMomentSubview setHidden:YES];
    
    //Setup like or Time Popup view
    vwSubvwOfLikeOrTime.hidden = YES;
    sliderLikeOrTimeRemain.userInteractionEnabled = NO;
    UIImage *empty = [UIImage new];
    [sliderLikeOrTimeRemain setThumbImage:empty forState:UIControlStateNormal];
}


#pragma mark -
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 100)
        return [_arrayActivities count];
    else
         return _arrayLikes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentiFier=@"ActivityTableCell";
    ActivityTableCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentiFier];
    if (cell==nil)
    {
        cell=[[[NSBundle mainBundle]loadNibNamed:cellIdentiFier owner:self options:nil]lastObject];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (tableView.tag == 100) {
       
        Activity *activity = [_arrayActivities objectAtIndex:indexPath.row];
        [cell setDataInCellForActivity:activity];
        
        [cell.btnMomentPicOutlet setTag:indexPath.row];
        [cell.btnUsePicOutlet setTag:indexPath.row];
        [cell.btnUsePicOutlet addTarget:self action:@selector(userPickTappedFromActivity:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnMomentPicOutlet addTarget:self action:@selector(momentPickTappedFromActivity:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    else
    {
        [cell setDataInCellForLike:_arrayLikes[indexPath.row]];
        
        [cell.btnUsePicOutlet setTag:indexPath.row];
        [cell.btnUsePicOutlet addTarget:self action:@selector(userPickTappedFromActivity:) forControlEvents:UIControlEventTouchUpInside];
      
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    selectedActivity = [_arrayActivities objectAtIndex:indexPath.row];
    [self showChatViewWithXmppFriend];
    
}

#pragma mark - Activity Cell Actions
-(IBAction)userPickTappedFromActivity:(UIButton *)sender
{
    selectedActivity = [_arrayActivities objectAtIndex:sender.tag];
    
    [self showChatViewWithXmppFriend];
   
}

-(IBAction)momentPickTappedFromActivity:(UIButton *)sender
{
    selectedActivity = [_arrayActivities objectAtIndex:sender.tag];
    
    CGRect rectOfCellInTableView = [self.tblActivity rectForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    //Rect For the Moment Image
    rectOfCellInTableView.origin.x = rectOfCellInTableView.origin.x + 270;
    rectOfCellInTableView.size.width = 40;
    CGRect rectOfCellInSuperview = [self.tblActivity convertRect:rectOfCellInTableView toView:[[[self.tblActivity superview] superview] superview]];

    selectedCellRect = rectOfCellInSuperview;
    
    if (selectedActivity.activity_momentDict && ![selectedActivity.activity_momentDict isEqual:[NSNull null]])
    {
        selectedMoment = [[Moment alloc]initWithDict:selectedActivity.activity_momentDict];
        [self showMomentDetailSubviewWithMoment:selectedMoment fromRect:rectOfCellInSuperview];
    }
  
}

-(void)showChatViewWithXmppFriend
{
    XmppFriend *xmppFriend = [[XmppFriendHandler sharedInstance]getXmppFriendWithName:selectedActivity.activity_Creator_id];
    
    JSDemoViewController *jsVC=[[JSDemoViewController alloc]init];
    jsVC.currentChatObj = xmppFriend;
    [[XmppCommunicationHandler sharedInstance] setCurrentFriendName:xmppFriend.friend_Name];
    
    [[XmppFriendHandler sharedInstance] updatePendingMessageCounter:xmppFriend.friend_Name isResetting:YES];
    
    [[APPDELEGATE navigationController] pushViewController:jsVC animated:YES];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)theCollectionView numberOfItemsInSection:(NSInteger)theSectionIndex
{
        return _arrayMyMoments.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    MomentsCell *cell = (MomentsCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                                                                               forIndexPath:indexPath];
    [cell.imgPhoto.layer setCornerRadius:5.0];
    [cell.imgPhoto.layer setMasksToBounds:YES];
    
    Moment *moment = [_arrayMyMoments objectAtIndex:indexPath.item];
    
    [cell.imgPhoto setShowActivity:YES];
    [cell.imgPhoto setImageURL : [NSURL URLWithString:moment.moment_img_url]];
    
    if (moment.moment_likersArray && ![moment.moment_likersArray isEqual:[NSNull null]])
    {
         [cell.lblLikeReceived setText:[NSString stringWithFormat:@"%d",moment.moment_likersArray.count]];
    }
   
    if ([[moment.moment_expiration_time stringByReplacingOccurrencesOfString:@":" withString:@"."] floatValue]>0.0) {
        [cell.lblMomentExpiration setText:moment.moment_expiration_time];
    }
    else
    {
        [cell.lblMomentExpiration setText:@"0"];
    }
    
    [cell.btnMoment setTag:indexPath.item];
    [cell.btnMoment addTarget:self action:@selector(btnMomentOnCellTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
   /* if ([UIScreen mainScreen].bounds.size.width <= 320)
    {
        return CGSizeMake(73.5f, 73.5f);
    }
    else
    {
        return CGSizeMake(87.f, 87.f);
    }
    */
    return CGSizeMake(70 , 70);
}

-(IBAction)btnMomentOnCellTapped:(UIButton *)sender
{
    selectedMoment = [_arrayMyMoments objectAtIndex:sender.tag];
    
    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:sender.tag inSection:0]];
    CGRect cellRect = attributes.frame;
    // CGRect cellFrameInSuperview = [collectionView convertRect:cellRect toView:[[collectionView superview] superview]];
    
    CGRect cellFrameInSuperview = [self.collectionView  convertRect:cellRect toView:[[[self.collectionView  superview] superview] superview]];
    
    selectedCellRect = cellFrameInSuperview;
    
    [self showMomentDetailSubviewWithMoment:selectedMoment fromRect:cellFrameInSuperview];

}

#pragma mark - Moment Detail
-(void)showMomentDetailSubviewWithMoment : (Moment *)moment fromRect:(CGRect)rect
{
    [imgPhotoLarge setShowActivity:YES];
    [imgPhotoLarge setImageURL:[NSURL URLWithString:moment.moment_img_url]];
    
    if ([[moment.moment_expiration_time stringByReplacingOccurrencesOfString:@":" withString:@"."] floatValue]>0.0) {
        [lblMomentExpiration setText:moment.moment_expiration_time];
    }
    else
    {
        [lblMomentExpiration setText:@"0"];
    }
    
    
    if (moment.moment_likersArray && ![moment.moment_likersArray isEqual:[NSNull null]])
    {
        [lblLikeReceived setText:[NSString stringWithFormat:@"%d",moment.moment_likersArray.count]];
        [_likeReceivedSlider setValue:moment.moment_likersArray.count];
    }
    
    [_timeElapsedSlider setValue :[[moment.moment_expiration_time stringByReplacingOccurrencesOfString:@":" withString:@"."] floatValue]];
    
    [vwMomentSubview setHidden:NO];
    
    [self zoomOutView:vwMomentSubview fromRect:rect WithImage:imgPhotoLarge.image];
   
}


-(void)zoomOutView:(UIView *)view fromRect:(CGRect)fromRect WithImage:(UIImage *)imgToZoom
{
    
    /*
    [view setFrame:fromRect];
    view.userInteractionEnabled = NO;
    view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    
    [UIView animateWithDuration:0.6 animations:^{
        view.transform = CGAffineTransformIdentity;
        [view setFrame:[APPDELEGATE window].frame];
        
    } completion:^(BOOL finished) {
        view.transform = CGAffineTransformIdentity;
        [view setCenter:[APPDELEGATE window].center];
        [view setFrame:[APPDELEGATE window].frame];
        view.userInteractionEnabled = YES;
        [view setAlpha:1.0];
    }];
     */
  
    UIImageView *imgScreenShot = nil;
    
    if (imgToZoom) {
        imgScreenShot = [[UIImageView alloc]initWithImage:imgToZoom];
    }
    else
    {
        imgScreenShot = [self customSnapshoFromView:view];
    }
    
    [imgScreenShot setFrame:fromRect];
    [self.view addSubview:imgScreenShot];
    [view setHidden:YES];
  
    [UIView animateWithDuration:0.3 animations:^{
        [imgScreenShot setFrame:[APPDELEGATE window].frame];
        
    } completion:^(BOOL finished) {
        [view setCenter:[APPDELEGATE window].center];
        [view setFrame:[APPDELEGATE window].frame];
        [view setHidden:NO];
        [imgScreenShot removeFromSuperview];
    }];
    
}

-(void)zoomInView:(UIView *)view toRect:(CGRect)toRect WithImage:(UIImage *)imgToZoomIn
{
    UIImageView *imgScreenShot = nil;
    
    if (imgToZoomIn) {
        imgScreenShot = [[UIImageView alloc]initWithImage:imgToZoomIn];
    }
    else
    {
        imgScreenShot = [self customSnapshoFromView:view];
    }
  
    [imgScreenShot setFrame:[APPDELEGATE window].frame];
   // [[APPDELEGATE window] addSubview:imgScreenShot];
    [self.view addSubview:imgScreenShot];
    [view setHidden:YES];
    
    [UIView animateWithDuration:0.3 animations:^{
        [imgScreenShot setFrame:toRect];
    }completion:^(BOOL finished) {
        [imgScreenShot removeFromSuperview];
    }];
}

-(UIImageView *)customSnapshoFromView:(UIView *)inputView
{
    
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, YES, 0);
    
    [inputView drawViewHierarchyInRect:inputView.bounds afterScreenUpdates:YES];
    
    UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    
    UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, inputView.frame.size.width, inputView.frame.size.height)];
    [img setBackgroundColor:[UIColor clearColor]];
    [img setImage:screenShot];
    return img;
}


-(void)hideMomentDetailSubview
{
    [self zoomInView:vwMomentSubview toRect:selectedCellRect WithImage:imgPhotoLarge.image];
}


- (IBAction)btnOtherOptionsTapped:(UIButton *)sender
{
    selectedRectForTimer_Like = sender.frame;
  
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Save to Camera Roll", @"Delete this Moment", nil];
    [actionSheet setDelegate:self];
    [actionSheet setTag:ActionSheetOtherOptionsMoment];
    [actionSheet showInView:self.view];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == ActionSheetOtherOptionsMoment) {
        if (buttonIndex == 0) {
            [self saveImageToCameraRoll];
        }
        else if (buttonIndex == 1)
            [self btnDeleteMomentTapped:nil];
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    
    SEL selector = NSSelectorFromString(@"_alertController");
    if ([actionSheet respondsToSelector:selector])
    {
        UIAlertController *alertController = [actionSheet valueForKey:@"_alertController"];
        if ([alertController isKindOfClass:[UIAlertController class]])
        {
            alertController.view.tintColor = ACTION_SHEET_COLOR;
        }
    }
    else
    {
        // use other methods for iOS 7 or older.
        for (UIView *subview in actionSheet.subviews) {
            if ([subview isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)subview;
                [button setTitleColor:ACTION_SHEET_COLOR forState:UIControlStateNormal];
            }
        }
        
    }
    
}

- (void)saveImageToCameraRoll
{
    imgVwSaveImg =[[UIImageView alloc]initWithFrame:[APPDELEGATE window].frame];
    [self.view addSubview:imgVwSaveImg];
    [imgVwSaveImg setImage:imgPhotoLarge.image];
   // CGRect frame = [btn convertRect:sender.bounds toView:self.view];
    
    [self zoomInView:imgVwSaveImg toRect:selectedRectForTimer_Like WithImage:imgPhotoLarge.image];
    
    [self.library saveImage:imgPhotoLarge.image toAlbum:@"Tinder Photos" withCompletionBlock:^(NSError *error) {
        if (error!=nil) {
            NSLog(@"Big error: %@", [error description]);
        }
        else
        {
            [imgVwSaveImg removeFromSuperview];
             [[TinderAppDelegate sharedAppDelegate]showToastMessage:@"Image Saved Succesfully"];
            //Show_AlertView(nil, @"Image Saved Succesfully");
        }
    }];
}

- (IBAction)btnDeleteMomentTapped:(id)sender
{
    [self callForWebseviceToDeleteMomentWithId:selectedMoment.moment_id];
}


- (IBAction)btnActionsOrMomentsTapped:(UIButton *)sender
{
    if (![sender isSelected])
    {
        for (UIButton *btn in btnActionsOrMoment)
        {
            [btn setSelected:NO];
        }
        [sender setSelected:YES];
    }
    
    if (sender.tag == 10)
    {
        isMyMomentsSelected =NO;
        [self.collectionView setHidden:YES];
        [self.tblActivity setHidden:NO];
    }
    else
    {
        isMyMomentsSelected =YES;
        [self.collectionView setHidden:NO];
        [self.tblActivity setHidden:YES];
        
    }
    
}


#pragma mark - Create moment

- (IBAction)btnCaptureMomentTapped:(id)sender
{
    CaptureMomentVC *captureMmntVC = [[CaptureMomentVC alloc]init];
    [captureMmntVC setDelegate:self];
    [self presentViewController:captureMmntVC animated:YES completion:nil];
}

#pragma mark - CaptureMomentVC Delegate
-(void)hideCaptureVcWithMomentImage:(UIImage *)imgMomentCreated
{
    /*
    CGRect frame = [btnMoment convertRect:btnMoment.bounds toView:self.view];
    UIImageView *imgVw = [[UIImageView alloc]initWithFrame:self.view.frame];
    [imgVw setImage:imgMomentCreated];
    [self zoomInView:imgVw toRect:frame WithImage:imgMomentCreated vibrateView:btnMoment];
     */
}

#pragma mark - Websevices Call

-(void)callForWebseviceToGetAllMyMoments
{
    
    NSString *currentDateString = [[UtilityClass sharedObject]DateToString:[NSDate date] withFormate:@"yyyy-MM-dd HH:mm:ss"];
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    [dictParam setObject:@"mine"forKey:@"type"];
    
    //[dictParam setObject:currentDateString forKey:@"last_datetime"];
    
  //  [[ProgressIndicator sharedInstance] showPIOnView:self.view withMessage:nil];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_GET_MOMENTS withParamData:dictParam withBlock:^(id response, NSError *error) {
        if (response)
        {
            if ([[response objectForKey:@"errFlag"] intValue]==0)
            {
                _arrayMyMoments = [[NSMutableArray alloc]init];
                for(NSDictionary *dict in [response objectForKey:@"moments"])
                {
                    Moment *moment = [[Moment alloc]initWithDict:dict];
                    [_arrayMyMoments addObject:moment];
                }
                [self.collectionView reloadData];
            }
        }
        [[ProgressIndicator sharedInstance] hideProgressIndicator];
        
    }];
}

-(void)callForWebseviceToGetAllActivities
{
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    
   // [[ProgressIndicator sharedInstance] showPIOnView:self.view withMessage:nil];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_GET_ACTIVITIES withParamData:dictParam withBlock:^(id response, NSError *error) {
        if (response)
        {
            if ([[response objectForKey:@"errFlag"] intValue]==0)
            {
                _arrayActivities = [[NSMutableArray alloc]init];
                for(NSDictionary *dict in [response objectForKey:@"activities"])
                {
                    Activity *activity = [[Activity alloc]initWithDict:dict];
                    [_arrayActivities addObject:activity];
                }
                [self.tblActivity reloadData];
            }
        }
        [[ProgressIndicator sharedInstance] hideProgressIndicator];
        
    }];
}

-(void)callForWebseviceToDeleteMomentWithId:(NSString *)momentId
{
    
   // [[ProgressIndicator sharedInstance] showPIOnView:[APPDELEGATE window] withMessage:nil];
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    [dictParam setObject:momentId forKey:PARAM_ENT_MOMENT_ID];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    
    [afn getDataFromPath:METHOD_DELETE_MOMENT withParamData:dictParam withBlock:^(id response, NSError *error) {
       
        if (response)
        {
            if ([[response objectForKey:@"errFlag"] intValue]==0)
            {
                [self zoomInView:vwMomentSubview toRect:selectedRectForTimer_Like WithImage:imgPhotoLarge.image];
                [_arrayMyMoments removeObject:selectedMoment];
                [self.collectionView reloadData];
                
                [self handleForMomentCreateDeletedNotification];
                //[self hideMomentDetailSubview];
            }
        }
        [[ProgressIndicator sharedInstance] hideProgressIndicator];
        
    }];

    
}


#pragma mark - Actions On Moment Detail View
- (IBAction)btnLikeReceivedTapped:(UIButton *)sender
{
    if (selectedMoment.moment_likersArray && ![selectedMoment.moment_likersArray isEqual:[NSNull null]])
    {
        if (selectedMoment.moment_likersArray.count)
        {
            [vwSubvwOfLikeOrTime setHidden:NO];
            [vwSubvwOfLikeOrTime setFrame:vwMomentSubview.frame];
            [tblLikeReceived setHidden:NO];
            [vwTimer setHidden:YES];
            
            [sliderLikeOrTimeRemain setMinimumValue:0];
            [sliderLikeOrTimeRemain setMaximumValue:1];
            
            [imgHeartOrTimer setImage:[UIImage imageNamed:@"heart_like.png"]];
            
            if (selectedMoment.moment_likersArray && ![selectedMoment.moment_likersArray isEqual:[NSNull null]])
            {
                _arrayLikes = [NSMutableArray arrayWithArray:selectedMoment.moment_likersArray];
                
                [lblLikeOrTimer setText:[NSString stringWithFormat:@"%d likes",_arrayLikes.count]];
                [sliderLikeOrTimeRemain setValue:_arrayLikes.count];
            }
            [tblLikeReceived reloadData];

            selectedRectForTimer_Like = sender.frame;
            [self zoomOutView:vwSubvwOfLikeOrTime fromRect:sender.frame WithImage:nil];
        }
    }
}

- (IBAction)btnTimeRemainTapped:(UIButton *)sender
{
    [vwSubvwOfLikeOrTime setFrame:self.view.frame];
    [vwSubvwOfLikeOrTime setHidden:NO];
    [tblLikeReceived setHidden:YES];
    [vwTimer setHidden:NO];
    
    [sliderLikeOrTimeRemain setMinimumValue:0.0];
    [sliderLikeOrTimeRemain setMaximumValue:24.0];
    
   
    [imgHeartOrTimer setImage:[UIImage imageNamed:@"time_icon.png"]];
  
    NSString *dateDateExp = [[UtilityClass sharedObject]stringFromDateString:selectedMoment.moment_expires_at fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"EEE hh:mm a"];
    
    if ([[selectedMoment.moment_expiration_time stringByReplacingOccurrencesOfString:@":" withString:@"."] floatValue]>0.0)
    {
        [lblExpireTimeRemain setText:selectedMoment.moment_expiration_time];
        [lblExpireDayTime setText:[NSString stringWithFormat:@"Expires at %@",dateDateExp]];
    }
    else
    {
        [lblExpireTimeRemain setText:nil];
        [lblExpireDayTime setText:[NSString stringWithFormat:@"Expired at %@",dateDateExp]];
    }
    
    [lblLikeOrTimer setText:@"Time Left"];
    [sliderLikeOrTimeRemain setValue :[[selectedMoment.moment_expiration_time stringByReplacingOccurrencesOfString:@":" withString:@"."] floatValue]];
    
    selectedRectForTimer_Like = sender.frame;
    [self zoomOutView:vwSubvwOfLikeOrTime fromRect:sender.frame WithImage:nil];
    
}

- (IBAction)btnDownOnLike_TImeViewTapped:(id)sender
{
    [self zoomInView:vwSubvwOfLikeOrTime toRect:selectedRectForTimer_Like WithImage:nil];
}

#pragma mark - ScrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat yOffset = 0.0;
   
    if (scrollView.contentOffset.y < yOffset) {
        
        // scrolls down.
        yOffset = scrollView.contentOffset.y;
    }
    else
    {
        // scrolls up.
        yOffset = scrollView.contentOffset.y;

    }
    
    if (yOffset>0) {
        [vwCapture setHidden:YES];
    }
    else if (yOffset<=0)
    {
        [vwCapture setHidden:NO];
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (IBAction)btnBackTapped:(id)sender
{
    NSDictionary *dictInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:TagChatView] forKey:KeyForScreenNavigation];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_SCREEN_NAVIGATION_BUTTON_CLICKED object:nil userInfo:dictInfo];
}

#pragma mark - Methods To Hide StatusBar

-(void)navigationController:(UINavigationController *)navigationController
     willShowViewController:(UIViewController *)viewController
                   animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

-(BOOL)prefersStatusBarHidden   // iOS8 definitely needs this one. checked.
{
    return NO;
}

-(UIViewController *)childViewControllerForStatusBarHidden
{
    return nil;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
