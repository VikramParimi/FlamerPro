//
//  AppSettingsViewController.m
//  Karmic
//
//  Created by AC on 20/11/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "AppSettingsViewController.h"
#import "LoginViewController.h"
#import "WebViewController.h"

@interface AppSettingsViewController ()
{
    NSString *postUrl;
    NSString *postMsg;
    
    IBOutlet UIScrollView *scrollVw;
    IBOutlet UIView *vwContainer;
    
}

@property (weak, nonatomic) IBOutlet UISwitch *matchesNewSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *msgsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *momentLikesSwitch;

@end

@implementation AppSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    stdDefaults = [NSUserDefaults standardUserDefaults];
    [scrollVw setContentSize:CGSizeMake(self.view.bounds.size.width, vwContainer.frame.size.height)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self performSelector:@selector(getAppSettings) withObject:nil afterDelay:0.1];
}

-(void) getAppSettings
{
    
    [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"App Settings.."];
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_GET_APPSETTINGS withParamData:dictParam withBlock:^(id response, NSError *error)
     {
         if (response)
         {
             if ([[response objectForKey:@"errFlag"] intValue]==0)
             {
                 NSDictionary *dictSettings = [response objectForKey:@"setting"];
                 
                 if ([[dictSettings objectForKey:@"notification_new_matches"] boolValue] == YES)
                 {
                     [self.matchesNewSwitch setOn:YES animated:NO];
                 }
                 else {
                     [self.matchesNewSwitch setOn:NO animated:NO];
                 }
                 
                 if ([[dictSettings objectForKey:@"notification_messages"] boolValue] == YES) {
                     [self.msgsSwitch setOn:YES animated:NO];
                 }
                 else {
                     [self.msgsSwitch setOn:NO animated:NO];
                 }
                 
                 if ([[dictSettings objectForKey:@"notification_moment_likes"] boolValue] == YES) {
                     [self.momentLikesSwitch setOn:YES animated:NO];
                 }
                 else {
                     [self.momentLikesSwitch setOn:NO animated:NO];
                 }

             }
         }
        
         [[ProgressIndicator sharedInstance]hideProgressIndicator];
     }];
}

-(void) setAppSettings
{
    
    NSString *matchesNewState;
    if (self.matchesNewSwitch.isOn)
        matchesNewState = @"1";
    else
        matchesNewState = @"0";
    
    NSString *msgsState;
    if (self.msgsSwitch.isOn)
        msgsState = @"1";
    else
        msgsState = @"0";
    
    NSString *momentLikes;
    if (self.momentLikesSwitch.isOn)
        momentLikes = @"1";
    else
        momentLikes = @"0";
    
    
    [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"App Settings.."];
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:@"ent_user_fbid"];
    [dictParam setObject:matchesNewState forKey:@"notification_new_matches"];
    [dictParam setObject:msgsState forKey:@"notification_messages"];
    [dictParam setObject:momentLikes forKey:@"notification_moment_likes"];
    
   /* AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_UPDATE_APPSETTINGS withParamData:dictParam withBlock:^(id response, NSError *error)
     {
         if (response)
         {
             if ([[response objectForKey:@"errFlag"] intValue]==0)
             {
                 [[TinderAppDelegate sharedAppDelegate]showToastMessage:[response objectForKey:@"errMsg"]];
             }
         }
         
         [[ProgressIndicator sharedInstance]hideProgressIndicator];
     }];*/
}

- (IBAction)btnDoneTapped:(id)sender {
     [self setAppSettings];
     [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)logoutSession:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Notice" message:@"Are you sure to logout from your account?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag =101;
    [alert show];
}

- (IBAction)btnContactUsTapped:(id)sender
{
    [self openMail];
}

- (IBAction)btnPrivacyPolicyTapped:(id)sender
{
    WebViewController *webVC = [[WebViewController alloc]init];
    [webVC setTypeString:@"Privacy Policy"];
    [self presentViewController:webVC animated:YES completion:nil];
  
}

- (IBAction)btnTermsOfServiceTapped:(id)sender
{
    WebViewController *webVC = [[WebViewController alloc]init];
    [webVC setTypeString:@"Terms of Service"];
    [self presentViewController:webVC animated:YES completion:nil];
    
}

#pragma mark -
#pragma mark - Mail Methods

- (void)openMail
{
    [super sendMailSubject:@"TinderClone App!" toRecipents:[NSArray arrayWithObject:@"info@tinderClone.com"] withMessage:@""];
}

#pragma mark -
#pragma mark - UIALertView Delegte method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==101) {
        if (buttonIndex!=0) {
            [self logout];
        }
    }
   else if (alertView.tag==102) {
        if (buttonIndex!=0) {
            [self deleteAccount];
        }
    }
}

-(void)logout{
    
    [[FacebookUtility sharedObject]logOutFromFacebook];
    
    [self resetDefaults];
    
    LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [TinderAppDelegate sharedAppDelegate].navigationController = [[UINavigationController alloc] initWithRootViewController:login];
    
    [TinderAppDelegate sharedAppDelegate].window.rootViewController = [TinderAppDelegate sharedAppDelegate].navigationController;
    
    [[TinderAppDelegate sharedAppDelegate].window makeKeyAndVisible];
}

- (void)resetDefaults
{
    /*
     NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
     [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
     */
    
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        if ([key isEqualToString:UD_UUID] || [key isEqualToString:UD_DEVICETOKEN]) {
            
        }else{
            [defs removeObjectForKey:key];
        }
        
    }
    [defs synchronize];
}

#pragma mark -
#pragma mark - Request And Response For Delete Account

- (IBAction)btnDeleteAccountTapped:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Notice" message:@"You are about to delete all your account details incliuding matches and chat too. Are you sure?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag =102;
    [alert show];
    
}

-(void)deleteAccount
{
    
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    [paramDict setObject:[[User currentUser] fbid]  forKey:PARAM_ENT_USER_FBID];
    
    WebServiceHandler *handler = [[WebServiceHandler alloc] init];
    handler.requestType = eParseKey;
    NSMutableURLRequest * request = [Service parseDeleteAccount:paramDict];
    
    [handler placeWebserviceRequestWithString:request Target:self Selector:@selector(DeleteAccount:)];
}

-(void)DeleteAccount:(NSDictionary*)_response
{
    ProgressIndicator * pi = [ProgressIndicator sharedInstance];
    if (_response == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Connection Timeout." delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil, nil];
        alert.tag = 400;
        [alert show];
    }
    else
    {
        if (_response != nil)
        {
            NSDictionary *dict = [_response objectForKey:@"ItemsList"];
            
             if ([[dict objectForKey:@"errFlag"]intValue]==0)
             {
                  [pi showMessage:[dict objectForKey:@"errMsg"] On:self.view];
                  [self logout];
             }
            
            
            /*
            if ([[dict objectForKey:@"errFlag"]intValue]==0 && [[dict objectForKey:@"errNum"]intValue]==61)
            {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Message" message:@"You are about to delete all your account details incliuding matches and chat too. Are you sure?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                alert.tag =102;
                [alert show];
            }
            else if ([[dict objectForKey:@"errFlag"]intValue]==1 && [[dict objectForKey:@"errNum"]intValue]==31)
            {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Message" message:@"You are about to delete all your account details incliuding matches and chat too. Are you sure?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                alert.tag =102;
                [alert show];
            }
            else if ([[dict objectForKey:@"errFlag"]intValue]==1 && [[dict objectForKey:@"errNum"]intValue]==62)
            {
                [pi showMessage:[dict objectForKey:@"errMsg"] On:self.view];
            }
             */
        }
    }
    [pi hideProgressIndicator];
}



@end
