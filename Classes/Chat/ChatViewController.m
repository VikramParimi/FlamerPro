//
//  ChatViewController.m
//  Tinder
//
//  Created by Sanskar on 26/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "ChatViewController.h"
#import "JSDemoViewController.h"
#import "User.h"
#import "EBTinderClient.h"

#define ScreenSize [UIScreen mainScreen].bounds.size
#define MomentViewHeight 146.0f
#define SearchBarHeight 44.0f
#define NavBarHeight 44.0f

@interface ChatViewController ()
{
    //NSMutableArray *arrayMoments;
    NSMutableArray *arrayMatchedUsers;
    IBOutlet UIButton *btnMoment;
}

//@property (nonatomic,retain)  MomentsDetailsViewController *momentdetailVc;

@end

@implementation ChatViewController

@synthesize tblView; //,momentdetailVc;

#pragma mark -
#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -
#pragma mark - ViewLife Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    self.navigationController.navigationBarHidden = YES;
    
    filteredContentList = [[NSMutableArray alloc] init];
    
   /* [vwMoment1.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [vwMoment1.layer setBorderWidth: 0.7];
    [vwMoment1.layer setCornerRadius:10.0];
    [vwMoment1.layer setMasksToBounds:YES];
    [vwMoment2.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [vwMoment2.layer setBorderWidth: 0.7];
    [vwMoment2.layer setCornerRadius:10.0];
    [vwMoment2.layer setMasksToBounds:YES];
    [imgMoment setClipsToBounds:YES];*/
    
    self.searchBar.barTintColor = [UIColor whiteColor];
    self.searchBar.tintColor = ACTION_SHEET_COLOR;
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:ACTION_SHEET_COLOR];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setBackgroundColor:[UIColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:0.3]];
    
    [self.searchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.8]];
    
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(presenceUpdated:) name:NOTIFICATION_XMPP_FRIENDS_PRESENCE_UPDATE object:nil] ;
    [[NSNotificationCenter defaultCenter ]addObserver:self selector:@selector(getMessageNotification:) name:NOTIFICATION_TINDER_UPDATE_MESSAGE_COUNTER object:nil];
    
     //  [[NSNotificationCenter defaultCenter ]addObserver:self selector:@selector(lastMessageStatusUpdate:) name:NOTIFICATION_XMPP_LAST_MESSAGE_STATUS_CHANGED object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(chatScreenRefresh) name:NOTIFICATION_CHATSCREEN_REFRESH object:nil];
    ///[self loginToXmppInBackground];
    [self chatScreenRefresh];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
   /* vwContainer.frame = CGRectMake(0, NavBarHeight, ScreenSize.width, ScreenSize.height-NavBarHeight);
    if (self.momentdetailVc) {
        [self.momentdetailVc.view setHidden:NO];
    }*/
}

/*
-(void)loginToXmppInBackground
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        [self loginToXmpp];
    });
}*/

//Notification to Call Webservices For Data Updation
-(void)chatScreenRefresh
{
    [self getAllFriendsFromDB];
    
    // [self resetFrameForContainerView];
    ///[self webServiceCallForFriendListAndMoments];
}

-(void)presenceUpdated:(NSNotification *)_notificationObj
{
    User *friendObj= (XmppFriend *)[[_notificationObj userInfo] valueForKey:@"friendObj"];
    //NSString *presentStatus = [[_notificationObj userInfo] valueForKey:@"status"];
    int indx = (int)[arrayXmppFriends indexOfObject:friendObj];
    
    if (indx <= arrayXmppFriends.count)
    {
        //[friendObj setPresenceStatus:presentStatus];
        [arrayXmppFriends replaceObjectAtIndex:indx withObject:friendObj];
        [tblView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
    //origin.
    /*XmppFriend *friendObj= (XmppFriend *)[[_notificationObj userInfo] valueForKey:@"friendObj"];
    NSString *presentStatus = [[_notificationObj userInfo] valueForKey:@"status"];
    int indx = (int)[arrayXmppFriends indexOfObject:friendObj];
    
    if (indx <= arrayXmppFriends.count)
    {
        [friendObj setPresenceStatus:presentStatus];
        [arrayXmppFriends replaceObjectAtIndex:indx withObject:friendObj];
        [tblView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }*/
}

-(void)getMessageNotification: (NSNotification *)_notificationObj
{
    [self getAllFriendsFromDB];
}

/*
-(void)lastMessageStatusUpdate:(NSNotification *)_notificationObj
{
    if ([[[XmppCommunicationHandler sharedInstance] currentVC] isEqualToString:@"matches"])
    {
        XmppFriend *friendObj= (XmppFriend *)[[_notificationObj userInfo] valueForKey:@"friendObj"];
        NSString *msgStatus = [[_notificationObj userInfo] valueForKey:@"lastMsgStatus"];
        
        int indx = (int)[arrayXmppFriends indexOfObject:friendObj];
        if (indx <= arrayXmppFriends.count)
        {
            [friendObj setLastMessageStatus:msgStatus];
            [arrayXmppFriends replaceObjectAtIndex:indx withObject:friendObj];
            [tblView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}*/

//Notification Action
-(void)removeProgressHud : (NSNotification *)_notificationObj
{
    [[ProgressIndicator sharedInstance]hideProgressIndicator];
}

#pragma mark - Fetch friends From DB
-(void)getAllFriendsFromDB
{
    arrayXmppFriends = [NSMutableArray arrayWithArray:[EBTinderClient sharedClient].recommendations];
    [tblView reloadData];
    
    //// origin.
    /*arrayXmppFriends = [NSMutableArray arrayWithArray:[[XmppFriendHandler sharedInstance] getAllXmppFriendsFromDB]];
    
    NSMutableArray *arrayTemp = [NSMutableArray arrayWithArray:arrayXmppFriends];
    for (XmppFriend *friendOBJ in arrayTemp) {
        
        if (!friendOBJ.friend_DisplayName.length)
        {
            [arrayXmppFriends removeObject:friendOBJ];
        }
    }
    
    [arrayXmppFriends sortUsingDescriptors:
     [NSArray arrayWithObjects:
      [NSSortDescriptor sortDescriptorWithKey:@"lastMessageTime" ascending:NO],
      [NSSortDescriptor sortDescriptorWithKey:@"friend_Name" ascending:YES], nil]];
    [tblView reloadData];
    
    [[XmppCommunicationHandler sharedInstance]setCurrentVC:@"matches"];*/
}

/*

#pragma mark - Layout ContainerView

- (void)resetFrameForContainerView
{
    self.searchBar.placeholder = [NSString stringWithFormat:@"Search %d Matches",arrayXmppFriends.count];
    
    if (arrayMoments.count == 0)
    {
        vwMoments.hidden = YES;
        if (arrayXmppFriends.count == 0) {
            tblView.frame = CGRectMake(0,0, ScreenSize.width, ScreenSize.height-NavBarHeight);
            _searchBar.hidden = YES;
            
        }
        else
        {
            tblView.frame = CGRectMake(0, SearchBarHeight, ScreenSize.width, ScreenSize.height-77);
            _searchBar.hidden = NO;
        }
    }
    else
    {
        CGRect frameMomentView = vwMoments.frame;
        vwMoments.hidden = NO;
        if (arrayXmppFriends.count == 0)
        {
            
            _searchBar.hidden = YES;
            
            frameMomentView.origin.y = 0;
            vwMoments.frame = frameMomentView;
            
            tblView.frame = CGRectMake(0, MomentViewHeight, ScreenSize.width, ScreenSize.height-frameMomentView.origin.y-MomentViewHeight);
            
        }
        else
        {
            _searchBar.hidden = NO;
            
            frameMomentView.origin.y = SearchBarHeight;
            vwMoments.frame = frameMomentView;
            
            tblView.frame = CGRectMake(0, SearchBarHeight+MomentViewHeight, ScreenSize.width, ScreenSize.height-frameMomentView.origin.y-MomentViewHeight);
        }
    }
}




#pragma mark - Webservice Call

-(void)webServiceCallForFriendListAndMoments
{
   
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        [self callForWebseviceToGetAllFriendsMoments];
    });
    
    dispatch_group_async(group,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        [self getAllMatchedFriendsFromServer];
    });
    
    dispatch_group_notify(group,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        NSLog(@"Completed");
    });
    
}

#pragma mark-- find matches

-(void)getAllMatchedFriendsFromServer
{
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_GETPROFILEMATCHES withParamData:dictParam withBlock:^(id response, NSError *error) {
        if (response)
        {
            if ([[response objectForKey:@"errFlag"] intValue]==0)
            {
                arrayMatchedUsers = [NSMutableArray arrayWithArray:[response objectForKey:@"likes"]];
                
                if (arrayMatchedUsers.count)
                {
                    
                    NSMutableDictionary *dictFriend = [[NSMutableDictionary alloc] init];
                    
                    for (NSDictionary *dictObj in arrayMatchedUsers)
                    {
                        NSString *fbid = [[dictObj valueForKey:@"fName"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        
                        if (fbid.length)
                        {
                            NSString *jid = [NSString stringWithFormat:@"%@@%@/%@",[NSString stringWithFormat:@"%@%@",XmppJidPrefix,[dictObj valueForKey:@"fbId"]],CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
                            
                            [dictFriend setObject:[NSString stringWithFormat:@"%@%@",XmppJidPrefix,[dictObj valueForKey:@"fbId"]] forKey:@"friendName"];
                            [dictFriend setObject:jid forKey:@"friendJid"];
                            [dictFriend setObject:[NSNumber numberWithInt:0] forKey:@"messageCount"];
                            // [dictFriend setObject:@"You 're a match! Now say Hi :)" forKey:@"lastMessage"];
                            [dictFriend setObject:[dictObj valueForKey:@"ladt"] forKey:@"lastMessageTime"];
                            [dictFriend setObject:@"Offline" forKey:@"presenceStatus"];
                            [dictFriend setObject:[dictObj valueForKey:@"fName"] forKey:@"friendDisplayName"];
                            
                            NSString *matchedDate = [dictObj valueForKey:@"ladt"];
                            
                            if (matchedDate.length)
                            {
                                matchedDate = [[UtilityClass sharedObject]stringFromDateString:matchedDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"MM/dd"];
                                [dictFriend setObject:[NSString stringWithFormat:@"Matched on %@",matchedDate] forKey:@"lastMessage"];
                            }
                            else
                            {
                                [dictFriend setObject:[NSString stringWithFormat:@"Matched Just Now"] forKey:@"lastMessage"];
                            }
                            
                            
                            NSData * imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[dictObj valueForKey:@"pPic"]]];
                            
                            if (imgData)
                            {
                                [dictFriend setObject:imgData forKey:@"friendImage"];
                            }
                            else
                            {
                                [dictFriend setObject:[NSData dataFromBase64String:@""] forKey:@"friendImage"];
                            }
                            
                            if ([[dictObj objectForKey:@"flag"] intValue]==3)
                            {
                                [dictFriend setObject:@"NO" forKey:@"isBlocked"];
                                [[XmppFriendHandler sharedInstance] insertOrUpdateFriendInfoInDatabase:dictFriend];
                            }
                            else
                            {
                                [dictFriend setObject:@"YES" forKey:@"isBlocked"];
                            }
                            
                        }
                    }
                    
                    //Remove Friends From DB Which are not in matches
                    
                    NSMutableArray *arrayAllXmppFrnds = arrayXmppFriends;
                    for (XmppFriend *xmppFriend in arrayAllXmppFrnds)
                    {
                        BOOL isExistInMatches = NO;
                        for (NSDictionary *matchFrnd in arrayMatchedUsers)
                        {
                            NSString *frndName = [NSString stringWithFormat:@"%@%@",XmppJidPrefix,[matchFrnd valueForKey:@"fbId"]];
                            if ([frndName isEqualToString:xmppFriend.friend_Name])
                            {
                                isExistInMatches = YES;
                                break;
                            }
                        }
                        if (!isExistInMatches)
                        {
                            [[XmppFriendHandler sharedInstance] removeFriendFromDatabase:xmppFriend.friend_Name];
                        }
                    }
                }
                else
                {
                    [[XmppFriendHandler sharedInstance]deleteAllFriendsRecordsFromDb];
                    [arrayXmppFriends removeAllObjects];
                }
            }
            else if([[response objectForKey:@"errNum"] integerValue]==51)
            {
                [[XmppFriendHandler sharedInstance]deleteAllFriendsRecordsFromDb];
                [arrayXmppFriends removeAllObjects];
            }
            
            [self getAllFriendsFromDB];
            [self resetFrameForContainerView];
            
        }
    }];
}
*/
 
-(void)callForWebseviceToGetAllFriendsMoments
{
    
    [self getAllFriendsFromDB];
    //[self resetFrameForContainerView];
    
   /* NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    [dictParam setObject:@"friends" forKey:@"type"];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_GET_MOMENTS withParamData:dictParam withBlock:^(id response, NSError *error)
     {
         if (response)
         {
             arrayMoments = [[NSMutableArray alloc]init];
             
             if ([[response objectForKey:@"errFlag"] intValue]==0)
             {
                 
                 NSArray *moments = [response objectForKey:@"moments"];
                 
                 for (NSDictionary *dict in moments)
                 {
                     Moment *moment = [[Moment alloc]initWithDict:dict];
                     [arrayMoments addObject:moment];
                 }
                 
                 if (moments.count)
                 {
                     Moment *moment = [[Moment alloc]initWithDict:[moments firstObject]];
                     lblMomentsCount.text = [NSString stringWithFormat:@"%d moments",moments.count];
                     
                     NSDate *dateCreated = [[UtilityClass sharedObject]stringToDate:moment.moment_Created_Time withFormate:@"yyyy-MM-dd HH:mm:ss"];
                     NSString *difference = [[UtilityClass sharedObject]prettyTimestampSinceDate:dateCreated];
                     
                     lblMomentTime.text = difference;
                     
                     
                     [imgMoment setShowActivity:YES];
                     [imgMoment setImageURL:[NSURL URLWithString:moment.moment_img_url]];
                     
                 }
                 
             }
         }
         
         [self getAllFriendsFromDB];
         [self resetFrameForContainerView];
     }];*/
}

#pragma mark -
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (isSearching) {
        return [filteredContentList count];
    }
    else {
        return [arrayXmppFriends count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *cellIdentiFier=@"FriendsListCell";
    FriendsListCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentiFier];
    if (cell==nil)
    {
        cell=[[[NSBundle mainBundle]loadNibNamed:cellIdentiFier owner:self options:nil]lastObject];
    }
    
    User *xmppFriend ;
    
    if (isSearching) {
        xmppFriend = [filteredContentList objectAtIndex:indexPath.row];
    }
    else
    {
        xmppFriend = [arrayXmppFriends objectAtIndex:indexPath.row];
    }
    
    [cell setData:indexPath.row dictForChat:xmppFriend];
    
    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

-(CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //XmppFriend *xmppFriend = [arrayXmppFriends objectAtIndex:indexPath.row];
    
     User *xmppFriend ;
    
    if (isSearching) {
        xmppFriend = [filteredContentList objectAtIndex:indexPath.row];
    }
    else
    {
        xmppFriend = [arrayXmppFriends objectAtIndex:indexPath.row];
    }

    
    [self pushToChatViewWithXmppFriend:xmppFriend];
    
    if (isSearching) {
        [self.searchDisplayController setActive:NO];
    }
    
     vwContainer.frame = CGRectMake(0, 44, ScreenSize.width, ScreenSize.height-44);
    [filteredContentList removeAllObjects];
    isSearching = NO;
    [self.tblView reloadData];
}

/*
- (IBAction)btnMomentTapped:(id)sender
{
    
    momentdetailVc = [[MomentsDetailsViewController alloc]initWithNibName:@"MomentsDetailsViewController" bundle:nil];
    [momentdetailVc setArrayMoments:arrayMoments];
    [momentdetailVc setDelegate:self];
    
    [momentdetailVc.view setFrame:[APPDELEGATE window].frame];
    [[APPDELEGATE window] addSubview:momentdetailVc.view];
    
    CGRect rectView = [vwContainer  convertRect:vwMoments.frame toView:[[vwMoments  superview] superview]];
    
    [self zoomOutView:momentdetailVc.view fromRect:rectView WithImage:imgMoment.image];
    
}


#pragma mark - MomentDetailVC Delegate

-(void)hideMomentsDetailView:(NSMutableArray *)arrayMomentsUpdated
{
    arrayMoments = [NSMutableArray arrayWithArray:arrayMomentsUpdated];
    
    if (arrayMoments.count)
    {
        Moment *moment = [arrayMoments firstObject];
        lblMomentsCount.text = [NSString stringWithFormat:@"%d moments",arrayMoments.count];
        
        [imgMoment setImageURL:[NSURL URLWithString:moment.moment_img_url]];
        [imgMoment setShowActivity:YES];
        
        [self resetFrameForContainerView];
        
        CGRect rectView = [vwContainer  convertRect:vwMoments.frame toView:[[vwMoments  superview] superview]];
        [self zoomInView:momentdetailVc.view toRect:rectView WithImage:imgMoment.image vibrateView:vwMoments];
    }
    else
    {
        [momentdetailVc.view removeFromSuperview];
        [self resetFrameForContainerView];
    }
}

-(void)zoomOutView:(UIView *)view fromRect:(CGRect)fromRect WithImage:(UIImage *)imgToZoom
{
    UIImageView *imgScreenShot = nil;
    
    if (imgToZoom) {
        imgScreenShot = [[UIImageView alloc]initWithImage:imgToZoom];
    }
    else
    {
        imgScreenShot = [self customSnapshoFromView:view];
    }
    
    [imgScreenShot setFrame:fromRect];
    
    [view setHidden:YES];
    
    // [[APPDELEGATE window] addSubview:imgScreenShot];
    [[APPDELEGATE window] addSubview:imgScreenShot];
    
    [UIView animateWithDuration:0.3 animations:^{
        [imgScreenShot setFrame:[APPDELEGATE window].frame];
        
    } completion:^(BOOL finished) {
        [view setCenter:[APPDELEGATE window].center];
        [view setFrame:[APPDELEGATE window].frame];
        [view setHidden:NO];
        [imgScreenShot removeFromSuperview];
    }];
    
}

-(void)zoomInView:(UIView *)view toRect:(CGRect)toRect WithImage:(UIImage *)imgToZoomIn vibrateView:(UIView *)vibView
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
    [[APPDELEGATE window] addSubview:imgScreenShot];
    [view removeFromSuperview];
    
    [UIView animateWithDuration:0.3 animations:^{
        [imgScreenShot setFrame:toRect];
    }completion:^(BOOL finished){
        
        [imgScreenShot removeFromSuperview];
        
        if (vibView)
        {
            //Vibrating the view
            [UIView animateWithDuration:0.9/1.5 animations:^{
                vibView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.5);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3/2 animations:^{
                    vibView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 0.5);
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.3/2 animations:^{
                        vibView.transform = CGAffineTransformIdentity;
                    }];
                }];
            }];
        }
        
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
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, inputView.frame.size.width, inputView.frame.size.height)];
    [view addSubview:img];
    
    return img;
}

-(void)chatButtonTappedWithMoment:(Moment *)moment
{
    XmppFriend *xmppFriend = [[XmppFriendHandler sharedInstance]getXmppFriendWithName:moment.moment_Creator_id];
    
    [self pushToChatViewWithXmppFriend:xmppFriend];
    
    [momentdetailVc.view setHidden:YES];
    //[momentdetailVc.view removeFromSuperview];
}
*/

-(void)pushToChatViewWithXmppFriend:(User *)xmppFriend
{
    JSDemoViewController *jsVC=[[JSDemoViewController alloc]init];
    jsVC.currentChatObj = xmppFriend;
  
    /*[[XmppCommunicationHandler sharedInstance] setCurrentFriendName:xmppFriend.friend_Name];
    [[XmppFriendHandler sharedInstance] updatePendingMessageCounter:xmppFriend.friend_Name isResetting:YES];*/
    
    [[APPDELEGATE navigationController] pushViewController:jsVC animated:YES];
}


/*
#pragma mark - XMPP LOGIN

- (void)loginToXmpp
{
    if (![[[XmppCommunicationHandler sharedInstance] xmppStream]isConnected])
    {
        [[XmppCommunicationHandler sharedInstance] setXMPPDelegate:self];
        [[XmppCommunicationHandler sharedInstance]loginOnXMPPWithUsername:MY_USER_NAME andPassword:MY_PASSWORD];
    }
    else
    {
        [self getAllFriendsFromDB];
    }
}*/

/*
#pragma mark - XMPP handler delegate

-(void) XMPPDidLogin:(XMPPStream *)Stream
{
    NSLog(@"XMPP DidLogin");
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_XMPP_LOGGED_IN object:nil];
}

-(void) XMPPDidAuthenticate:(XMPPStream *)Stream
{
    NSLog(@"xmpp Did Authenticate");
}

-(void) XMPPDidConnect:(XMPPStream *)Stream
{
    NSLog(@"XMPP Did  Connect");
}

-(void) XMPPDidNotAuthenticate:(XMPPStream *)Stream
{
    [[XmppCommunicationHandler sharedInstance] disconnect];
    
    NSLog(@"XMPP Did Not Authenticate");
    
    Show_AlertView(@"Error!", @"Server cannot Athenticate with this username");
}

#pragma mark - Capture Moments
- (IBAction)btnCaptureMomentTapped:(id)sender
{
    CaptureMomentVC *captureMmntVC = [[CaptureMomentVC alloc]init];
    [captureMmntVC setDelegate:self];
    // captureMmntVC.view.frame = self.view.frame;
    [self presentViewController:captureMmntVC animated:YES completion:nil];
}

#pragma mark - CaptureMomentVC Delegate
-(void)hideCaptureVcWithMomentImage:(UIImage *)imgMomentCreated
{
    CGRect frame = [btnMoment convertRect:btnMoment.bounds toView:self.view];
    UIImageView *imgVw = [[UIImageView alloc]initWithFrame:self.view.frame];
    [imgVw setImage:imgMomentCreated];
    [self zoomInView:imgVw toRect:frame WithImage:imgMomentCreated vibrateView:btnMoment];
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
}*/

#pragma mark - Search Implementation

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.8]];
    vwContainer.frame = CGRectMake(0, 0, ScreenSize.width, ScreenSize.height);
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"Text change - %d",isSearching);
    
    //Remove all objects first.
    [filteredContentList removeAllObjects];
    
    if([searchText length] != 0) {
        isSearching = YES;
        [self searchTableList];
        [self.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor whiteColor]];
    }
    else {
        isSearching = NO;
    }
    [self.tblView reloadData];
}

- (void)searchTableList
{
    NSString *searchString = _searchBar.text;
    for (User *friendObj in arrayXmppFriends) {
     NSComparisonResult result = [friendObj.name compare:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchString length])];
     if (result == NSOrderedSame) {
     [filteredContentList addObject:friendObj];
     }
    }
    
    //origin.
    /*for (XmppFriend *friendObj in arrayXmppFriends) {
        NSComparisonResult result = [friendObj.friend_DisplayName compare:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchString length])];
        if (result == NSOrderedSame) {
            [filteredContentList addObject:friendObj];
        }
    }*/
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Cancel clicked");
    //  [searchBar resignFirstResponder];
    vwContainer.frame = CGRectMake(0, 44, ScreenSize.width, ScreenSize.height-44);
    [filteredContentList removeAllObjects];
    isSearching = NO;
    [self.tblView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Search Clicked");
    [self searchTableList];
    vwContainer.frame = CGRectMake(0, 44, ScreenSize.width, ScreenSize.height-44);
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    UISearchBar *searchBar = controller.searchBar;
    [searchBar removeFromSuperview];
    [vwContainer addSubview:searchBar];
    
    vwContainer.frame = CGRectMake(0, 44, ScreenSize.width, ScreenSize.height-44);
    [filteredContentList removeAllObjects];
    isSearching = NO;
    [self.tblView reloadData];
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

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [filteredContentList removeAllObjects];
    isSearching = NO;
    [self.tblView reloadData];
}

- (IBAction)btnHomeTapped:(id)sender
{
    NSDictionary *dictInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:TagHomeView] forKey:KeyForScreenNavigation];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_SCREEN_NAVIGATION_BUTTON_CLICKED object:nil userInfo:dictInfo];
}

/*
- (IBAction)btnMomentsTapped:(id)sender
{
    NSDictionary *dictInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:TagMomentsView] forKey:KeyForScreenNavigation];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_SCREEN_NAVIGATION_BUTTON_CLICKED object:nil userInfo:dictInfo];
}*/


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    //[[XmppCommunicationHandler sharedInstance]setCurrentVC:@""];
}

@end
