//
//  MomentsDetailsViewController.m
//  Tinder
//
//  Created by Sanskar on 01/01/15.
//  Copyright (c) 2015 AppDupe. All rights reserved.
//

#import "MomentsDetailsViewController.h"
#import "Moment.h"
#import "XmppSingleChatHandler.h"
#import "XmppFriend.h"
#import "XmppFriendHandler.h"

@interface MomentsDetailsViewController ()
{
    CGPoint originalPositionOfvwMoment1;
    CGPoint originalPositionOfvwMoment2;
    CGPoint originalPositionOfvwMoment3;
    CGRect orifinalFrameOfVWMoment1;
    CGRect orifinalFrameOfVWMoment2;
    CGRect orifinalFrameOfVWMoment3;
    
    CGFloat xDistanceForSnapShot;
    CGFloat yDistanceForSnapShot;
   
}

@property (nonatomic, strong) IBOutlet UILabel *decision;
@property (nonatomic, strong) IBOutlet UILabel *liked;
@property (nonatomic, strong) IBOutlet UILabel *nope;

@end

@implementation MomentsDetailsViewController
@synthesize liked,nope,decision;

- (void)viewDidLoad
{
    
    
    UISwipeGestureRecognizer * recognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    [recognizerRight setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizerRight];
    
    UISwipeGestureRecognizer * recognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    [recognizerLeft setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.view addGestureRecognizer:recognizerLeft];
    
    [super viewDidLoad];
    [vwMoment1.layer setCornerRadius:10.0];
    [vwMoment2.layer setCornerRadius:10.0];
    [vwMoment3.layer setCornerRadius:10.0];
    [vwMoment4.layer setCornerRadius:10.0];
    
    [vwMoment1.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [vwMoment1.layer setBorderWidth: 1.0];
    [vwMoment2.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [vwMoment2.layer setBorderWidth: 1.0];
    [vwMoment3.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [vwMoment3.layer setBorderWidth: 1.0];
    [vwMoment4.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [vwMoment4.layer setBorderWidth: 1.0];
    
    [vwMoment1.layer setMasksToBounds:YES];
    [vwMoment2.layer setMasksToBounds:YES];
    [vwMoment3.layer setMasksToBounds:YES];
    [vwMoment4.layer setMasksToBounds:YES];
    
    [imgUserMoment1.layer setCornerRadius:imgUserMoment1.frame.size.width/2];
    [imgUserMoment2.layer setCornerRadius:imgUserMoment2.frame.size.width/2];
   
    [imgUserMoment1.layer setMasksToBounds:YES];
    [imgUserMoment2.layer setMasksToBounds:YES];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:0.8]];
   
    orifinalFrameOfVWMoment1 = vwMoment1.frame;
    orifinalFrameOfVWMoment2 = vwMoment2.frame;
    orifinalFrameOfVWMoment3 = vwMoment3.frame;
    originalPositionOfvwMoment2 = vwMoment2.center;
    originalPositionOfvwMoment3 = vwMoment3.center;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self setupMomentsView];
}

-(void)callForWebseviceToGetAllFriendsMoments
{
    
    [_arrayMoments removeAllObjects];
    
    NSString *currentDateString = [[UtilityClass sharedObject]DateToString:[NSDate date] withFormate:@"yyyy-MM-dd HH:mm:ss"];
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    [dictParam setObject:@"friends" forKey:@"type"];
    
    [[ProgressIndicator sharedInstance] showPIOnView:self.view withMessage:nil];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_GET_MOMENTS withParamData:dictParam withBlock:^(id response, NSError *error)
     {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_CHATSCREEN_REFRESH object:nil];
       
         if (response)
         {
             if ([[response objectForKey:@"errFlag"] intValue]==0)
             {
                 NSArray *moments = [response objectForKey:@"moments"];
                 
                 for (NSDictionary *dict in moments)
                 {
                     Moment *moment = [[Moment alloc]initWithDict:dict];
                     [_arrayMoments addObject:moment];
                 }
             }
            
         }
         
         [[ProgressIndicator sharedInstance] hideProgressIndicator];
         [self setupMomentsView];
       
     }];
}

#pragma mark - setup Moments View
-(void)setupMomentsView
{
    self.decision.hidden = YES;
   
    if ([_arrayMoments count] > 0)
    {
        Moment *moment1 = [_arrayMoments objectAtIndex:0];
        
        [imgMoment1 setShowActivity:YES];
        [imgMoment1 setImageURL:[NSURL URLWithString:moment1.moment_img_url]];
        [imgMoment1 setShowActivity:YES];
        [imgUserMoment1 setImageURL:[NSURL URLWithString:moment1.moment_Creator_profilePic]];
        
        [lblUsernameMoment1 setText:moment1.moment_Creator_firstName];
        
        NSDate *dateCreated = [[UtilityClass sharedObject]stringToDate:moment1.moment_Created_Time withFormate:@"yyyy-MM-dd HH:mm:ss"];
        NSString *difference = [[UtilityClass sharedObject]prettyTimestampSinceDate:dateCreated];
        [lblTimeMoment1  setText:difference];
        
        originalPositionOfvwMoment1 = vwMoment1.center;
        
        if ([_arrayMoments count] > 1)
        {
            vwMoment2.hidden = NO;
            Moment *moment2 = [_arrayMoments objectAtIndex:1];
            [imgMoment2 setShowActivity:YES];
            [imgMoment2 setImageURL:[NSURL URLWithString:moment2.moment_img_url]];
            [imgMoment2 setShowActivity:YES];
            [imgUserMoment2 setImageURL:[NSURL URLWithString:moment2.moment_Creator_profilePic]];
            
            [lblUsernameMoment2 setText:moment2.moment_Creator_firstName];
            
            NSDate *dateCreated = [[UtilityClass sharedObject]stringToDate:moment2.moment_Created_Time withFormate:@"yyyy-MM-dd HH:mm:ss"];
            NSString *difference1 = [[UtilityClass sharedObject]prettyTimestampSinceDate:dateCreated];
            [lblTimeMoment2  setText:difference1];
            
            if ([_arrayMoments count] > 2)
            {
                vwMoment3.hidden = NO;
                
                if ([_arrayMoments count] > 3)
                {
                    vwMoment4.hidden = NO;
                }
                else
                {
                    vwMoment4.hidden = YES;
                }
            }
            else
            {
                vwMoment3.hidden = YES;
                vwMoment4.hidden = YES;
            }
        }
        else
        {
            vwMoment2.hidden = YES;
            vwMoment3.hidden = YES;
            vwMoment4.hidden = YES;
        }
    }
    else
    {
        [self performSelector:@selector(hideMomentSubview) withObject:nil afterDelay:0.2];
       
    }
}

-(void)hideMomentSubview
{
    if ([self.delegate respondsToSelector:@selector(hideMomentsDetailView:)]) {
        [self.delegate hideMomentsDetailView:_arrayMoments];
    }
}

#pragma mark - Tap On Image
- (IBAction)tapDetected:(UITapGestureRecognizer *)sender
{
    [self performSelector:@selector(hideMomentSubview) withObject:nil afterDelay:0.2];
    
}


#pragma mark -
#pragma mark - actionForNopeAndLike

-(IBAction)pan:(UIPanGestureRecognizer*)gs
{
    CGPoint curLoc = vwMoment1.center;
    CGPoint translation = [gs translationInView:gs.view.superview];
    float diff = 0;
    
    if (gs.state == UIGestureRecognizerStateBegan) {
        
        xDistanceForSnapShot = vwMoment1.center.x;
        yDistanceForSnapShot = vwMoment1.center.y;

    }
    else if (gs.state == UIGestureRecognizerStateChanged) {
        if (curLoc.x < originalPositionOfvwMoment1.x) {
            diff = originalPositionOfvwMoment1.x - curLoc.x;
            if (diff > 50)
                [nope setAlpha:1];
            else {
                [nope setAlpha:diff/50];
            }
            [liked setHidden:YES];
            [nope setHidden:NO];
            
        }
        else if (curLoc.x > originalPositionOfvwMoment1.x) {
            diff = curLoc.x - originalPositionOfvwMoment1.x;
            if (diff > 50)
                [liked setAlpha:1];
            else {
                [liked setAlpha:diff/50];
            }
            
            [liked setHidden:NO];
            [nope setHidden:YES];
        }
        /*
        gs.view.center = CGPointMake(gs.view.center.x + translation.x,
                                     gs.view.center.y + translation.y);
        [gs setTranslation:CGPointMake(0, 0) inView:self.view];
         
        
        
        CGFloat tran = diff/3000;
        NSLog(@"tran %f",tran);
        
        
        if (tran <=0.05) {
            vwMoment2.transform = CGAffineTransformMakeScale(1.0+tran,1.0);
        }
        CGPoint centerForVW2 = CGPointMake(originalPositionOfvwMoment2.x, originalPositionOfvwMoment2.y-diff/50);
        vwMoment2.center = centerForVW2;
        */
        
        
        //Updated By Sanskar
        
        CGFloat xDistance = [gs translationInView:self.view].x;
        CGFloat yDistance = [gs translationInView:self.view].y;
        
        CGFloat rotationStrength = MIN(xDistance / ScreenSize.width, 1);
        CGFloat rotationAngel = - (CGFloat) (2*M_PI * rotationStrength / 8);
        CGFloat scaleStrength = 1 - fabsf(rotationStrength) / 8;
        CGFloat scale = MAX(scaleStrength, 0.93);
        
        gs.view.center = CGPointMake(xDistanceForSnapShot + xDistance, yDistanceForSnapShot + yDistance);
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
        CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
        gs.view.transform = scaleTransform;
        
        
        CGFloat tran = diff/3000;
        
        if (tran <=0.02) {
            vwMoment2.transform = CGAffineTransformMakeScale(1.0+tran,1.0);
            vwMoment3.transform = CGAffineTransformMakeScale(1.0+tran,1.0);
        }
        CGPoint centerForVW2 = CGPointMake(originalPositionOfvwMoment2.x, originalPositionOfvwMoment2.y-diff/50);
        vwMoment2.center = centerForVW2;
        
        CGPoint centerForVW3 = CGPointMake(originalPositionOfvwMoment3.x, originalPositionOfvwMoment3.y-diff/50);
        vwMoment3.center = centerForVW3;
        
    }
    else if (gs.state == UIGestureRecognizerStateEnded)
    {
        if (![nope isHidden] || ![liked isHidden])
        {
            vwMoment1.transform = CGAffineTransformIdentity;
            
            vwMoment1.frame = orifinalFrameOfVWMoment1;
            vwMoment2.frame = orifinalFrameOfVWMoment2;
            vwMoment3.frame = orifinalFrameOfVWMoment3;
            
            [nope setHidden:YES];
            [liked setHidden:YES];
            [vwMoment1 setHidden:YES];
            vwMoment1.center = originalPositionOfvwMoment1;
             
            [vwMoment1 setHidden:NO];
            diff = curLoc.x - originalPositionOfvwMoment1.x;
            
//            if (abs(diff) > 50) {
                imgMoment1.image = nil;
                imgMoment1.image = imgMoment2.image;
                
                int tag = 0;
                if (diff > 0) {
                    tag = TagLike;
                }
                else {
                    tag = TagDislike;
                }
                
                self.decision.text = @"";

                [self likeDislikeAction:tag];

//            }

        }
    }

}

-(void)likeDislikeAction:(int)tag
{
     Moment *moment = [_arrayMoments objectAtIndex:0];
   
     [self callForWebseviceToLikeDislikeMomentWithId:moment.moment_id actionTag:tag];
  
     self.decision.hidden = NO;
     [self.view bringSubviewToFront:self.decision];
     if (tag == TagLike) {
            self.decision.text = @"Liked";
            self.decision.textColor = [UIColor colorWithRed:0.001 green:0.548 blue:0.002 alpha:1.000];
      }
      else {
            self.decision.text = @"Noped";
            self.decision.textColor = [UIColor redColor];
      }
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

    });
      [self performSelector:@selector(updateNextProfileView) withObject:nil afterDelay:0.2];
  
}

-(void)updateNextProfileView
{
    //self.decision.hidden = YES;
    [_arrayMoments removeObjectAtIndex:0];
    [self setupMomentsView];
}

#pragma mark - Webservice Call

-(void)callForWebseviceToLikeDislikeMomentWithId:(NSString *)momentId actionTag:(int)actionTag
{
    
   // [[ProgressIndicator sharedInstance] showPIOnView:[APPDELEGATE window] withMessage:nil];
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    [dictParam setObject:momentId forKey:PARAM_ENT_MOMENT_ID];
    [dictParam setObject:[NSString stringWithFormat:@"%d",actionTag] forKey:@"like_flag"];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    
    [afn getDataFromPath:METHOD_LIKE_DISLIKE_MOMENT withParamData:dictParam withBlock:^(id response, NSError *error) {
        
        if (response)
        {
            if ([[response objectForKey:@"errFlag"] intValue]==0)
            {
                
            }
        
        }
        [[ProgressIndicator sharedInstance] hideProgressIndicator];
        
    }];
}


#pragma mark - IBActions
- (IBAction)btnChatTapped:(id)sender
{
  
    if ([self.delegate respondsToSelector:@selector(chatButtonTappedWithMoment:)]) {
        [self.delegate chatButtonTappedWithMoment:[_arrayMoments firstObject]];
    }
}

- (IBAction)btnOtherOptionsTapped:(UIButton *)sender
{
    Moment *moment = [_arrayMoments firstObject];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Like & Message", [NSString stringWithFormat:@"Block %@",moment.moment_Creator_firstName],[NSString stringWithFormat:@"Unmatch %@"
                                                                                                                                                            ,moment.moment_Creator_firstName],@"Report", nil];
    [actionSheet setDelegate:self];
    [actionSheet showInView:self.view];

}

#pragma mark - ActionSheet Delegate
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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self likeDislikeAction:TagLike];
        [self btnChatTapped:nil];
    }
    else if (buttonIndex == 1)
    {
        [self blockUserWithCurrentMoment];
    }
    else if(buttonIndex == 2)
        [self unmatchUserWithCurrentMoment];
    else if (buttonIndex == 3)
        [self reportUserWithCurrentMoment];
}

-(void)blockUserWithCurrentMoment
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Alert!" message:@"Are you sure you want to block this user?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alertView.tag =200;
    [alertView show];
   
}

-(void)unmatchUserWithCurrentMoment
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Alert!" message:@"Are you sure you want to Unmatch this user?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alertView.tag =300;
    [alertView show];
}

-(void)reportUserWithCurrentMoment
{
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"Tinder App!"];
    [controller setMessageBody:@"" isHTML:NO];
    NSMutableArray *emails = [[NSMutableArray alloc] initWithObjects:@"info@appdupe.com", nil];
    [controller setToRecipients:[NSArray arrayWithArray:(NSArray *)emails]];
    if (controller) [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark- MailDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent)
    {
        NSLog(@"It's away!");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    Moment *moment = [_arrayMoments firstObject];
    NSString *fbId = moment.moment_Creator_id;
    NSString *xmppJid = [NSString stringWithFormat:@"%@%@",XmppJidPrefix,fbId];
    
    if(buttonIndex == 1)
    {
        if (alertView.tag == 100)
        {
            // unblock user
            
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            
            [dictParam setObject:[NSString stringWithFormat:@"%d",EntFlagUnblock] forKey:PARAM_ENT_FLAG];
            [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
            [dictParam setObject:fbId forKey:PARAM_ENT_USER_BLOCK_FBID];
            
            AFNHelper *afn=[[AFNHelper alloc]init];
            [afn getDataFromPath:METHOD_BLOCKUSER withParamData:dictParam withBlock:^(id response, NSError *error)
             {
                 if (response)
                 {
                     if ([[response objectForKey:@"errFlag"] intValue]==0)
                     {
                         [[TinderAppDelegate sharedAppDelegate]showToastMessage:[response objectForKey:@"errMsg"]];
                         
                     }
                 }
             }];
            
        }
        else if(alertView.tag == 200)
        {/*block user service call */
            
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            
            [dictParam setObject:[NSString stringWithFormat:@"%d",EntFlagBlock] forKey:PARAM_ENT_FLAG];
            [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
            [dictParam setObject:fbId forKey:PARAM_ENT_USER_BLOCK_FBID];
            
            
            AFNHelper *afn=[[AFNHelper alloc]init];
            [afn getDataFromPath:METHOD_BLOCKUSER withParamData:dictParam withBlock:^(id response, NSError *error)
             {
                 if (response)
                 {
                     if ([[response objectForKey:@"errFlag"] intValue]==0)
                     {
                         [[TinderAppDelegate sharedAppDelegate]showToastMessage:[response objectForKey:@"errMsg"]];
                         [self clearConversationWithFriend:xmppJid];
                         [self callForWebseviceToGetAllFriendsMoments];
                         [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_CHATSCREEN_REFRESH object:nil];
                     }
                 }
             }];
            
        }
        else if(alertView.tag == 300)
        {/*Unmatch user service call */
            
            
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            
            [dictParam setObject:@"submit" forKey:@"ent_submit"];
            [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
            [dictParam setObject:fbId forKey:@"ent_unmatch_user_fbid"];
            
            
            AFNHelper *afn=[[AFNHelper alloc]init];
            [afn getDataFromPath:METHOD_UNMATCH withParamData:dictParam withBlock:^(id response, NSError *error)
             {
                 if (response)
                 {
                     if ([[response objectForKey:@"errFlag"] intValue]==0)
                     {
                         [[TinderAppDelegate sharedAppDelegate]showToastMessage:[response objectForKey:@"errMsg"]];
                         [self clearConversationWithFriend:xmppJid];
                         [self callForWebseviceToGetAllFriendsMoments];
                        
                     }
                 }
             }];
            
        }
    }
}

#pragma mark - Clear Conversation From DB
-(void)clearConversationWithFriend:(NSString *)friendName
{
   XmppFriend *friendObj = [[XmppFriendHandler sharedInstance]getXmppFriendWithName:friendName];
    
   NSMutableArray *currentChatMessageArray = [[NSMutableArray alloc] init];
    currentChatMessageArray = [[XmppSingleChatHandler sharedInstance] loadAllMesssagesForFriendName:[[XmppCommunicationHandler sharedInstance] currentFriendName]];
    
    if ([currentChatMessageArray count] > 0)
    {
        NSString *recieverName = [friendObj friend_Name];
        
        NSManagedObjectContext *context = [APPDELEGATE managedObjectContext];
        
        NSError*        error        = nil;
        NSFetchRequest* request      = [NSFetchRequest fetchRequestWithEntityName:@"SingleChatMessages"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"(sender = %@) OR (reciever = %@)",recieverName,recieverName ]];
        NSArray*         deleteArray = [context executeFetchRequest:request error:&error];
        
        if (deleteArray != nil)
        {
            for (NSManagedObject* object in deleteArray)
            {
                [context deleteObject:object];
            }
            
            [context save:&error];
            //### Error handling.
        }
        else
        {
            //### Error handling.
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)swipeRight:(id)sender {
    
    
    [nope setHidden:YES];
    [liked setHidden:YES];
    [vwMoment1 setHidden:YES];
    
    int tag = 0;
    tag = TagLike;
    [self likeDislikeAction:tag];
    
    
}
- (IBAction)swipeLeft:(id)sender
{
    [nope setHidden:YES];
    [liked setHidden:YES];
    [vwMoment1 setHidden:YES];
    
    int tag = 0;
    tag = TagDislike;
    [self likeDislikeAction:tag];
}
@end
