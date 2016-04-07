//
//  LoginViewController.m
//  Tinder
//
//  Created by Rahul Sharma on 24/11/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import "LoginViewController.h"
#import "TinderAppDelegate.h"
#import "Helper.h"
#import "ProgressIndicator.h"
#import "Service.h"
#import "LocationHelper.h"
#import "LoginInfoVC.h"
#import "EBTinderClient.h"

//XMPP
//#import "XMPPvCardTempModule.h"
//#import "XMPPvCardTemp.h"

@interface LoginViewController ()

@property (nonatomic ,strong) NSMutableDictionary *paramDict;
@end

@implementation LoginViewController

@synthesize paramDict;


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
    //if ([[FacebookUtility sharedObject]isLogin])
    if ([[UserDefaultHelper sharedObject]facebookUserDetail])
    {
        [[self btnInfo] setHidden:YES];
        [[self btnFBLogin] setHidden:YES];
        [[self pageControl] setHidden:YES];
        [[self viewDatePic] setHidden:YES];
        [[self imgShadow] setHidden:YES];
        [[self scrImages] setHidden:YES];
        [[self picDate] setHidden:YES];
        [[self viewInfo] setHidden:YES];
    }
    else
    {
        [[self btnInfo] setHidden:NO];
        [[self btnFBLogin] setHidden:NO];
        [[self pageControl] setHidden:NO];
        [[self viewDatePic] setHidden:YES];
        [[self imgShadow] setHidden:NO];
        [[self scrImages] setHidden:NO];
        [[self picDate] setHidden:NO];
    }
    
    self.navigationController.navigationBarHidden = YES;
    
    [self getLocation];
    
    arrImages=[[NSMutableArray alloc]init];
    
    self.scrImages.delegate = self;
    [self.scrImages setPagingEnabled:YES];
    [self.scrImages setScrollEnabled:YES];
    
    /* Configure Help screens */
    [self setHelpScreens];
    
    /*Make custom Info and Facebook Buttons*/
    [Helper setButton:self.btnInfo Text:@"We'll never post anything to facebook." WithFont:SEGOUE_UI FSize:10 TitleColor:[UIColor darkGrayColor] ShadowColor:nil];
    
    if ([[UserDefaultHelper sharedObject] facebookToken]){
        [self onClickbtnFBLogin:nil];
    }
    
    if ([[UserDefaultHelper sharedObject]facebookUserDetail]){
        [self onClickbtnFBLogin:nil];
    }
    
}


-(void)viewWillAppear:(BOOL)animated
{
  
}

#pragma mark -
#pragma mark - Methods

-(void)setHelpScreens
{
    if (IS_iPhone5)
    {
        [arrImages addObject:[UIImage imageNamed:@"background_screen_three_vt_txt.png"]];
        [arrImages addObject:[UIImage imageNamed:@"background_screen_one_vt_txt.png"]];
        [arrImages addObject:[UIImage imageNamed:@"background_screen_two_vt_screen.png"]];
    }
    else
    {
        [arrImages addObject:[UIImage imageNamed:@"profile_signup_screen.png"]];
        [arrImages addObject:[UIImage imageNamed:@"itamactch_signup_screen.png"]];
        [arrImages addObject:[UIImage imageNamed:@"chat_signup_screen.png"]];
    }
    self.scrImages.contentSize = CGSizeMake(self.scrImages.frame.size.width * arrImages.count, self.scrImages.frame.size.height);
    
    [self performSelector:@selector(setScrollViewForImage) withObject:nil afterDelay:0.3];
    
    self.pageControl.pageIndicatorTintColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"slider_indicator_off.png"]];
    self.pageControl.currentPageIndicatorTintColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"slider_indicator_on.png"]];
}

-(void)setScrollViewForImage
{
    for (int i = 0; i < arrImages.count; i++)
    {
        CGRect frame;
        frame.origin.x = self.scrImages.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = self.scrImages.frame.size;
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:frame];
        imgView.image = [arrImages objectAtIndex:i];
        [self.scrImages addSubview:imgView];
    }
}

#pragma mark -
#pragma mark - Actions

-(IBAction)changePage:(id)sender
{
    int page = self.pageControl.currentPage;
    CGRect frame = self.scrImages.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrImages scrollRectToVisible:frame animated:YES];
}

-(IBAction)onClickbtnInfo:(id)sender
{
    LoginInfoVC *vc=[[LoginInfoVC alloc]initWithNibName:@"LoginInfoVC" bundle:nil];
    vc.parent=self;
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

-(void)showHomeScreen
{
    [super updateLocation];
    [[User currentUser]setUser];
    
    HomeViewController *home = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
  
    NSMutableArray *navigationarray = [[NSMutableArray alloc]initWithArray:self.navigationController.viewControllers];
    [navigationarray removeAllObjects];
    [navigationarray addObject:home];
    
    [APPDELEGATE performSelector:@selector(callNotificationForScreenUpdates:) withObject:NOTIFICATION_HOMESCREEN_REFRESH afterDelay:0.1];

    [self.navigationController setViewControllers:navigationarray animated:YES];
}

-(IBAction)onClickbtnFBLogin:(id)sender
{
    if ([[UserDefaultHelper sharedObject]facebookUserDetail])
    {
        [self showHomeScreen];
    }
    else
    {
        self.scrImages.hidden = YES;
       self.viewDatePic.hidden=NO;
       // [self loginWithFb];
    }
}

-(IBAction)onClickDone:(id)sender
{
    self.viewDatePic.hidden=YES;
    
    NSDate *birthDate = self.picDate.date;
    NSDate *currentDate = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit; //|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:birthDate toDate:currentDate options:0];
    
    NSInteger days = [dateComponents day];
    NSInteger months = [dateComponents month];
    NSInteger years = [dateComponents year];
    
    NSLog(@"%d Years , %d Months , %d Days", years, months, days);
    
    if(years < 18)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error !!!"
                                                        message:@"You should be a minimum of 18 yrs old to Sign Up !"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [alert dismissWithClickedButtonIndex:0 animated:YES];
        });
    }
    else
    {
        strBdate=[[UtilityClass sharedObject]DateToString:birthDate withFormate:@"yyyy-MM-dd"]; //0000-00-00
        
        if ([FacebookUtility sharedObject].session.state!=FBSessionStateOpen)
        {
            [[FacebookUtility sharedObject] getFBToken];
        }
        
        if ([[FacebookUtility sharedObject] isLogin])
        {
            [self getFacebookUserDetails];
        }
        else
        {
            [[FacebookUtility sharedObject]loginInFacebook:^(BOOL success, NSError *error)
             {
                 if (success)
                 {
                     if ([FacebookUtility sharedObject].session.state==FBSessionStateOpen)
                     {
                         [self getFacebookUserDetails];
                     }
                 }
                 else
                 {
                     UIAlertView *alertView = [[UIAlertView alloc]
                                               initWithTitle:@"Error"
                                               message:error.localizedDescription
                                               delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
                     [alertView show];
                 }
             }];
        }
    }
}


-(void)getFacebookUserDetails
{
    //me?fields=id,birthday,gender,first_name,age_range,last_name,name,picture.type(normal)
    
    ProgressIndicator *pi = [ProgressIndicator sharedInstance];
    [pi showPIOnView:self.view withMessage:@"Logging In.."];
    
    if ([[FacebookUtility sharedObject]isLogin])
    {
        [[FacebookUtility sharedObject]fetchMeWithFields:@"id,birthday,gender,first_name,age_range,last_name,name,picture.type(large),cover" FBCompletionBlock:^(id response, NSError *error)
         {
             if (!error)
             {
                 [[UserDefaultHelper sharedObject] setFacebookUserDetail:[NSMutableDictionary dictionaryWithDictionary:response]];
                 [self parseLogin:response];
             }
             else
             {
                 [pi hideProgressIndicator];
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Please try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                 alert.tag = 202;
                 [alert show];
             }
         }];
    }
    else
    {
        [pi hideProgressIndicator];
    }
}

#pragma mark -
#pragma mark -  login Parse methods

-(void)parseLogin :(NSDictionary*)FBUserDetailDict
{
    EntSex sex;
    if ([[FBUserDetailDict objectForKey:@"gender"] isEqualToString:@"female"])
    {
        sex= EntSexFemale;
    }
    else
    {
        sex =EntSexMale;
    }
    
    NSString *strPushToken =[[UserDefaultHelper sharedObject] deviceToken];
    if (!([strPushToken length] > 0))
    {
        strPushToken = @"SIMULATOR_TEST";
    }
    NSString *lat=@"0.0";
    if ([[UserDefaultHelper sharedObject] currentLatitude]!=nil)
    {
        lat=[[UserDefaultHelper sharedObject] currentLatitude];
    }
    NSString *log=@"0.0";
    if ([[UserDefaultHelper sharedObject] currentLongitude]!=nil)
    {
        log=[[UserDefaultHelper sharedObject] currentLongitude];
    }

    NSString *BDAy =strBdate;
    
 
    ///NSString  *BDAy = [Helper getBirthDate:[FBUserDetailDict objectForKey:FACEBOOK_BIRTHDAY]];
    ///if (BDAy.length ==0 || [BDAy isEqualToString:@""] || BDAy == nil) {
    ///    BDAy  =@"0000-00-00";
    ///}
    ///else{
    ///    BDAy = [Helper getBirthDate:[FBUserDetailDict objectForKey:FACEBOOK_BIRTHDAY]];
    ///}
    ///
    
    NSString *proPic=@"https://fbcdn-profile-a.akamaihd.net/static-ak/rsrc.php/v2/yL/r/HsTZSDw4avx.gif";
    if ([[[FBUserDetailDict objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"]!=nil)
    {
        proPic=[[[FBUserDetailDict objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
    }

    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:proPic]];
    [USERDEFAULT setObject:imgData forKey:PARAM_ENT_PROFILE_PIC_DATA];
    
    NSString *coverPic = [self getFbFriendsCoverPhotoForUserID:[FBUserDetailDict objectForKey:@"id"]];
    [USERDEFAULT setObject:coverPic forKey:@"fbUserCoverPic"];
    
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    
    [dictParam setObject:[FBUserDetailDict objectForKey:@"id"] forKey:PARAM_ENT_FBID];
    [dictParam setObject:[FBUserDetailDict objectForKey:@"first_name"] forKey:PARAM_ENT_FIRST_NAME];
    [dictParam setObject:[FBUserDetailDict objectForKey:@"last_name"] forKey:PARAM_ENT_LAST_NAME];
    [dictParam setObject:[NSString stringWithFormat:@"%lu",(unsigned long)sex] forKey:PARAM_ENT_SEX];
    [dictParam setObject:strPushToken forKey:PARAM_ENT_PUSH_TOKEN];
    
    [dictParam setObject:lat forKey:PARAM_ENT_CURR_LAT];
    [dictParam setObject:log forKey:PARAM_ENT_CURR_LONG];
    [dictParam setObject:BDAy forKey:PARAM_ENT_DOB];
    [dictParam setObject:proPic forKey:PARAM_ENT_PROFILE_PIC];
    [dictParam setObject:@"1" forKey:PARAM_ENT_DEVICE_TYPE];
    
    [[UserDefaultHelper sharedObject]setFacebookLoginRequest:dictParam];

    // Tinder.
    [[EBTinderClient sharedClient] authenticateWithTinderCompletion: (AuthenticateBlock)^(BOOL success){
        
        [[ProgressIndicator sharedInstance]hideProgressIndicator];
        
        if (success)
        {
            // not completed.
            NSString *profPic = @"http://xxxx";
            [USERDEFAULT setObject:profPic forKey:PARAM_ENT_PROFILE_PIC];
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:profPic]];
            [USERDEFAULT setObject:imgData forKey:PARAM_ENT_PROFILE_PIC_DATA];
            
            [self showHomeScreen];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_TINDER_LOGGED_IN object:nil];
            });
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Please try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.tag = 202;
            [alert show];
        }
    }];


    //origin.
    /*AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_LOGIN withParamData:dictParam withBlock:^(id response, NSError *error)
    {
        [[ProgressIndicator sharedInstance]hideProgressIndicator];
        if (response)
        {
            if ([[response objectForKey:@"errFlag"] intValue]==0)
            {
            
                NSString *profPic = [response objectForKey:@"profilePic"];
                
                if (!(profPic == (id)[NSNull null] || profPic.length == 0 ))
                {
                    
                   [USERDEFAULT setObject:profPic forKey:PARAM_ENT_PROFILE_PIC];
                    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:profPic]];
                   [USERDEFAULT setObject:imgData forKey:PARAM_ENT_PROFILE_PIC_DATA];
                }
              
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    
                    [self registerToXmpp];
                    
                });
                
                [self showHomeScreen];
            }
        }
    }];*/
    
    [USERDEFAULT synchronize];
}

#pragma mark - fetch cover photo

-(NSString  *)getFbFriendsCoverPhotoForUserID:(NSString *)fbFriendsId
{
    
    NSString *imageFb= [self imageURLForCoverPhotoObject:fbFriendsId];
    
    //through asynchronus request
    NSString *strUrl  = imageFb;
    
    NSError *jsonError = nil;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    NSData *jsonData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&jsonError];
    NSError *jsonParsingError = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&jsonParsingError];
    NSDictionary *topDictionary = (NSDictionary *)jsonObject;
    // NSLog(@"response from the server :\n\n %@",jsonData);
    NSString *strFBImageUrl=[[topDictionary valueForKey:@"cover"] valueForKey:@"source"];
    //  NSLog(@"strFBImageUrl is %@",strFBImageUrl);
    return strFBImageUrl;
}

- (NSString *)imageURLForCoverPhotoObject:(NSString *)FB_Id
{
    NSString *imageURL   =   [[NSString alloc] initWithFormat:@"http://graph.facebook.com/%@?fields=cover",FB_Id];
    
    return imageURL;
}

-(void)getLocation
{
    [[LocationHelper sharedObject]startLocationUpdatingWithBlock:^(CLLocation *newLocation, CLLocation *oldLocation, NSError *error)
    {
        if (!error)
        {
            [[LocationHelper sharedObject]stopLocationUpdating];
        }
    }];
}

#pragma mark -
#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 202)
    {
        [self getFacebookUserDetails];
    }
}

#pragma mark -
#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth = self.scrImages.frame.size.width;
    float fractionalPage = self.scrImages.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    self.pageControl.currentPage = page;
}

/*
-(void)registerToXmpp
{
    NSString *fbID = [[User currentUser]fbid];
   
    // [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[XmppCommunicationHandler sharedInstance] setXMPPDelegate:self];
    
    [[XmppCommunicationHandler sharedInstance] registerOnXMPPWithUsername:[NSString stringWithFormat:@"%@%@",XmppJidPrefix,fbID] andPassword:@"123456"];
    
}


#pragma mark - XMPP handler delegate

-(void) XMPPDidLogin:(XMPPStream *)Stream
{
    NSLog(@"XMPP DidLogin");
    
    //[MBProgressHUD hideHUDForView:self.view animated:YES];
    
    // [self performSelectorOnMainThread:@selector(showHome) withObject:self waitUntilDone:YES];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_XMPP_LOGGED_IN object:nil];
    
}

-(void) XMPPDidRegistered:(XMPPStream *)Stream
{
    NSLog(@"XMPP Did Registered");
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [self performSelectorOnMainThread:@selector(showHome) withObject:self waitUntilDone:YES];
    
 
     //FriendsVc *hVC = [[FriendsVc alloc]init];
     //[self.navigationController pushViewController:hVC animated:YES];
 
    
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error{
    
    DDXMLElement *errorXML = [error elementForName:@"error"];
    NSString *errorCode  = [[errorXML attributeForName:@"code"] stringValue];
    
    NSString *regError = [NSString stringWithFormat:@"ERROR :- %@",error.description];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration Failed!" message:regError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    if([errorCode isEqualToString:@"409"]){
        
        [alert setMessage:@"Username Already Exists!"];
    }
    [alert show];
}

-(void) XMPPDidAuthenticate:(XMPPStream *)Stream
{
    NSLog(@"xmpp Did Authenticate");
}

-(void) XMPPDidNotAuthenticate:(XMPPStream *)Stream
{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[XmppCommunicationHandler sharedInstance] disconnect];
    
    NSLog(@"XMPP Did Not Authenticate");
    
    Show_AlertView(@"Error!", @"Server cannot Athenticate with this username");
    
    
}
-(void) XMPPDidConnect:(XMPPStream *)Stream
{
    
    NSLog(@"XMPP Did  Connect");
    
}
-(void) XMPPDidReceiveMessage:(XMPPStream *)Stream
{
    NSLog(@"XMPP Did Receive Message");
}
-(void) XMPPDidDisconnect:(XMPPStream *)Stream
{
    NSLog(@"xmpp Did Disconnect");
}*/

#pragma mark -
#pragma mark - Memory mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end