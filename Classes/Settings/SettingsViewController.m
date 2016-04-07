//

//  SettingsViewController.m

//  Tinder

//

//  Created by Rahul Sharma on 30/11/13.

//  Copyright (c) 2013 3Embed. All rights reserved.

//

#import "SettingsViewController.h"
#import <FacebookSDK/FBSessionTokenCachingStrategy.h>
#import "RangeSlider.h"
#import "LoginViewController.h"
#import "Helper.h"
#import "ProgressIndicator.h"
#import "Service.h"
#import "UserSettings.h"
#import "User.h"
#import "EBTinderClient.h"

@interface SettingsViewController ()
{
    NSString *prefGender;
}
@end

@implementation SettingsViewController
@synthesize lblDistance;
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
    // self.navigationController.navigationBar.translucent = NO;
    CGRect screen = [[UIScreen mainScreen]bounds];
    appDelagte =(TinderAppDelegate*) [[UIApplication sharedApplication]delegate];

    // ui settings
    [Helper setToLabel:lblTitle Text:@"Discovery Settings" WithFont:HELVETICALTSTD_LIGHT FSize:16.0f Color:BLACK_COLOR];
    [Helper setButton:btnDone Text:@"Done" WithFont:HELVETICALTSTD_LIGHT FSize:12.0f TitleColor:ACTION_SHEET_COLOR ShadowColor:nil];
    [Helper setToLabel:lblAgeMin Text:Nil WithFont:HELVETICALTSTD_ROMAN FSize:19 Color:BLACK_COLOR];
    [Helper setToLabel:lblDistance Text:nil WithFont:HELVETICALTSTD_ROMAN FSize:19 Color:BLACK_COLOR];
    
    UIImage *minImage = [[UIImage imageNamed:@"slider_blue.png"]
                         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    
    UIImage *maxImage = [[UIImage imageNamed:@"slider_gray.png"]
                         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    
    UIImage *thumbImage = [UIImage imageNamed:@"slider_btn.png"];

    [[UISlider appearance] setMaximumTrackImage:maxImage
                                       forState:UIControlStateNormal];
    
    [[UISlider appearance] setMinimumTrackImage:minImage
                                       forState:UIControlStateNormal];
    
    [[UISlider appearance] setThumbImage:thumbImage
                                forState:UIControlStateNormal];
    
    slider = [[RangeSlider alloc] initWithFrame:CGRectMake(10, 270, 300, 26)];
    // the slider enforces a height of 30, although I'm not sure that this is necessary
    slider.minimumRangeLength = 0.1;
    
    [slider setMinThumbImage:[UIImage imageNamed:@"slider_btn.png"]]; // the two thumb controls are given custom images
    [slider setMaxThumbImage:[UIImage imageNamed:@"slider_btn.png"]];
    [scrollview addSubview:slider];
    
    [UserSettings currentSetting].sex= [NSString stringWithFormat:@"%@", [User currentUser].gender];
    [UserSettings currentSetting].prLAge =  [NSString stringWithFormat:@"%d", [[User currentUser].ageFilterMin intValue]];
    [UserSettings currentSetting].prUAge =  [NSString stringWithFormat:@"%d", [[User currentUser].ageFilterMax intValue]];
    [UserSettings currentSetting].prRad =  [NSString stringWithFormat:@"%d", [[User currentUser].distanceFilter intValue]];
    [self upDatePrefControls];
    
    //origin.
    /*[[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"User setting.."];
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_GETPREFERENCES withParamData:dictParam withBlock:^(id response, NSError *error)
     {
         if (response)
         {
             if ([[response objectForKey:@"errFlag"] intValue]==0)
             {
                 [UserSettings currentSetting].sex=[response objectForKey:@"sex"];
                 [UserSettings currentSetting].prRad=[response objectForKey:@"prRad"];
                 [UserSettings currentSetting].prSex=[response objectForKey:@"prSex"];
                 [UserSettings currentSetting].prLAge=[response objectForKey:@"prLAge"];
                 [UserSettings currentSetting].prUAge=[response objectForKey:@"prUAge"];
                 [UserSettings currentSetting].prDiscovery=[response objectForKey:@"ent_pref_discovery"];
                 [self upDatePrefControls];
             }
         }
         [[ProgressIndicator sharedInstance]hideProgressIndicator];
     }];*/
    scrollview.contentSize = CGSizeMake(screen.size.width, viewBG.frame.size.height);
}



#pragma mark -

#pragma mark - NavBar Methods

-(void)addrightButton:(UINavigationItem*)naviItem
{
    
    //UIImage *imgButton = [UIImage imageNamed:@"chat_icon_off_line.png"];
    
    UIButton *rightbarbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [rightbarbutton setFrame:CGRectMake(0, 0, 50, 23)];
    
    [rightbarbutton setTitle:@"Done" forState:UIControlStateNormal];
    
    [rightbarbutton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    [rightbarbutton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    
    [[rightbarbutton titleLabel] setFont:[UIFont systemFontOfSize:14.0]];
    
    
    
    [rightbarbutton addTarget:self action:@selector(doneEditing) forControlEvents:UIControlEventTouchUpInside];
    
    naviItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightbarbutton];
    
}

-(IBAction)doneEditing:(id)sender

{
    //[self sendRequestForUpdate];
    [self sendRequestProfile];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)upDatePrefControls{
    
    /***** settings For gender******/
    if ([UserSettings currentSetting].sex==nil) {
        [UserSettings currentSetting].sex=@"1";
    }
    
    /***** settings For Intrest ******/
    if ([UserSettings currentSetting].prSex==nil) {
        [UserSettings currentSetting].prSex=@"3";
    }
    
    if ([[UserSettings currentSetting].prSex intValue]==1) {
        [_btnGenderOutlet setTitle:@"Only Men" forState:UIControlStateNormal];
        prefGender = @"1";
    }
    else if ([[UserSettings currentSetting].prSex intValue]==2) {
        
        [_btnGenderOutlet setTitle:@"Only Women" forState:UIControlStateNormal];
        prefGender = @"2";
    }
    else{
        [_btnGenderOutlet setTitle:@"Men and Women" forState:UIControlStateNormal];
        prefGender = @"3";
        
    }
    
    /***** settings For distance slider******/
    sliderDistance.maximumValue =1000;
    sliderDistance.minimumValue = 0;
    if ([UserSettings currentSetting].prRad==nil) {
        [UserSettings currentSetting].prRad=@"4000";
    }
    
    [sliderDistance setValue:[[UserSettings currentSetting].prRad intValue] animated:YES];
    lblDistance.text = [NSString stringWithFormat:@"%d Km", [[UserSettings currentSetting].prRad intValue]];
    
    /***** settings For max and Min age slider******/
    if ([UserSettings currentSetting].prLAge==nil) {
        [UserSettings currentSetting].prLAge=@"18";
    }
    
    if ([UserSettings currentSetting].prUAge==nil) {
        [UserSettings currentSetting].prUAge=@"58";
    }
    
    int min = [[UserSettings currentSetting].prLAge intValue];
    int max = [[UserSettings currentSetting].prUAge intValue];
    [slider setTrackImage:[[UIImage imageNamed:@"slider_gray.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(9.0, 9.0, 9.0, 9.0)]];
    [slider setInRangeTrackImage:[UIImage imageNamed:@"slider_blue.png"]];
    [slider addTarget:self action:@selector(report:) forControlEvents:UIControlEventValueChanged];
    if (max>=58)
        lblAgeMin.text = [NSString stringWithFormat:@"%d-%d+",min,58];
    else
        lblAgeMin.text = [NSString stringWithFormat:@"%d-%d",min,max];
    
    if (min>18) {
        float val = (min-18.0)/40.0;
        [slider setMin:val];
    }
    
    if (max > 18 && max < 58){
        float val = (max-18.0)/40.0;
        [slider setMax:val];
    }
    
    if ([[UserSettings currentSetting].prDiscovery intValue]==1)
    {
        [UserSettings currentSetting].prDiscovery=@"1";
        [_switchDiscovery setSelected:YES];
        [_switchDiscovery setOn:YES];
    }
    else  if ([[UserSettings currentSetting].prDiscovery intValue]==0)
    {
        [UserSettings currentSetting].prDiscovery=@"0";
        [_switchDiscovery setSelected:NO];
        [_switchDiscovery setOn:NO];
    }

}

/*
-(void)saveUpdatedValue
{
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSDictionary * dictAge = [[[UserDefaultHelper sharedObject] facebookUserDetail] objectForKey:FACEBOOK_AGERANGE];
    NSArray * arrIntrest = [[[UserDefaultHelper sharedObject] facebookUserDetail] objectForKey:FACEBOOK_INTRESTED_IN];

 
    if ([ud integerForKey:@"INTREST"]==0)
    {
        if ( arrIntrest.count>1)
            Intested_in = 3;
        else{
            if ([[arrIntrest objectAtIndex:0] isEqualToString:@"female"])
                Intested_in = 2;
            else if([[arrIntrest objectAtIndex:0] isEqualToString:@"male"])
                Intested_in = 1;
            else
                Intested_in = 1;
        }
    }
    else
    {
        if ([ud integerForKey:@"INTREST"]==1)
            Intested_in = 1;
        else if([ud integerForKey:@"INTREST"]==2)
            Intested_in = 2;
        else if([ud integerForKey:@"INTREST"]==3)
            Intested_in = 3;
    }
    
 
    if ([ud integerForKey:@"GENDER"]==0) {
        if ([[[[UserDefaultHelper sharedObject] facebookUserDetail] objectForKey:FACEBOOK_GENDER] isEqualToString:@"female"])
            sex =FEMALE;
        else
            sex=MALE;
    }
    else
    {
        if ([ud integerForKey:@"GENDER"]==FEMALE)
            sex=FEMALE;
        else
            sex =MALE;
    }
    
 
    [sliderDistance setValue:50 animated:YES];
    sliderDistance.maximumValue =100;
    sliderDistance.minimumValue = 0;
    
    UIImage *minImage = [[UIImage imageNamed:@"slider_blue.png"]
                         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    
    UIImage *maxImage = [[UIImage imageNamed:@"slider_gray.png"]
                         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    UIImage *thumbImage = [UIImage imageNamed:@"slider_btn.png"];
    
    
    
    [[UISlider appearance] setMaximumTrackImage:maxImage
     
                                       forState:UIControlStateNormal];
    
    [[UISlider appearance] setMinimumTrackImage:minImage
     
                                       forState:UIControlStateNormal];
    
    [[UISlider appearance] setThumbImage:thumbImage
     
                                forState:UIControlStateNormal];
    
    
    
    if (![ud objectForKey:@"DISTANCE"])
        
    {
        
        if ([ud integerForKey:@"DIST"] ==3) {
            
            lblDistance.text = [NSString stringWithFormat:@"%d Mi", 50];
            
        }
        
        else if ([ud integerForKey:@"DIST"] ==4) {
            
            lblDistance.text = [NSString stringWithFormat:@"%d Km", 50];
            
        }
        
        else{
            
            lblDistance.text =@"50 Mi";
            
        }
        
        sliderDistance.value =50;
        
    }
    
    else{
        if ([ud integerForKey:@"DIST"] ==3) {
            lblDistance.text = [NSString stringWithFormat:@"%d Mi", [[ud objectForKey:@"DISTANCE"] intValue]];
        }
        else if ([ud integerForKey:@"DIST"] ==4) {
            lblDistance.text = [NSString stringWithFormat:@"%d Km", [[ud objectForKey:@"DISTANCE"] intValue]];
        }
        else{
            lblDistance.text =@"50 Mi";
        }
        sliderDistance.value =[[ud objectForKey:@"DISTANCE"]intValue];
        
    }
 
    int min = [[dictAge objectForKey:AGERANGE_MIN] intValue];
    int max = [[dictAge objectForKey:AGERANGE_MAX] intValue];
    // there are two track images, one for the range "track", and one for the filled in region of the track between the slider thumbs
    [slider setTrackImage:[[UIImage imageNamed:@"slider_gray.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(9.0, 9.0, 9.0, 9.0)]];
    [slider setInRangeTrackImage:[UIImage imageNamed:@"slider_blue.png"]];
    
    if ([ud integerForKey:@"PrefMin"] ||[ud integerForKey:@"PrefMax"]) {
        
        lblAgeMin.text = [NSString stringWithFormat:@"%d-%d",[ud integerForKey:@"PrefMin"],[ud integerForKey:@"PrefMax"]];
        
        if ([ud integerForKey:@"PrefMin"]>18) {
            
            float val = ([ud integerForKey:@"PrefMin"]-18.0)/40.0;
            
            [slider setMin:val];
            
        }
        
        if ([ud integerForKey:@"PrefMax"] > 18 && [ud integerForKey:@"PrefMax"] < 58)
            
        {
            
            float val = ([ud integerForKey:@"PrefMax"]-18.0)/40.0;
            
            [slider setMax:val];
            
        }
        
    }
    
    else{
        
        lblAgeMin.text = [NSString stringWithFormat:@"18-58"];
        
        if (min > 18) {
            
            float val = (min-18.0)/40.0;
            
            [slider setMin:val];
            
        }
        
        if (max > 18 && max < 58) {
            
            [slider setMax:(max-18.0)/40.0];
            
        }
    }
    
    //[self report:slider];
    
    [super viewDidLoad];
}*/

#pragma mark -Button Action(GENDER AND DISTANCE)
-(IBAction)btnAction:(id)sender
{
    UIButton * btn = (UIButton*)sender;
    switch (btn.tag) {
        case MALE:
        {
            [UserSettings currentSetting].sex=[NSString stringWithFormat:@"%d",MALE];
            break;
        }
            
        case FEMALE:
        {
            [UserSettings currentSetting].sex=[NSString stringWithFormat:@"%d",FEMALE];
            break;
        }
        default:
            break;
    }
    
    [self upDatePrefControls];
}

#pragma mark -
#pragma mark - slider Distance value Change method
-(IBAction)sliderChange:(UISlider*)sender {
    NSString *newText = [[NSString alloc] initWithFormat:@"%d",(int)[sender value]];
    lblDistance.text=[NSString stringWithFormat:@"%@ Km", newText];
    [UserSettings currentSetting].prRad=newText;
}

#pragma mark -
#pragma mark - slider age(MAX and MIN)
- (void)report:(RangeSlider *)sender {
    int min = sender.min*40+18;
    int max = sender.max*40+18;
    
    [UserSettings currentSetting].prLAge=[NSString stringWithFormat:@"%d",min];
    [UserSettings currentSetting].prUAge=[NSString stringWithFormat:@"%d",max];
    NSString *report = nil;
    if (max >= 58)
    {
        report = [NSString stringWithFormat:@"%d-58+", min];
    }
    else {
        report = [NSString stringWithFormat:@"%d-%d", min, max];
    }
    lblAgeMin.text = report;
}



#pragma mark -
#pragma mark - Request And Response For Update Prefrence

-(void)sendRequestProfile
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *myNumber = [f numberFromString:@"42"];
    
    User * currentUser = [User currentUser];
    currentUser.ageFilterMin = [f numberFromString:[UserSettings currentSetting].prLAge];
    currentUser.ageFilterMax = [f numberFromString:[UserSettings currentSetting].prUAge];
    currentUser.distanceFilter = [f numberFromString:[UserSettings currentSetting].prRad];
    
    // Tinder.
    [[EBTinderClient sharedClient] updateProfile: ^(BOOL bSuccess){
        
        [[ProgressIndicator sharedInstance]hideProgressIndicator];
        if (bSuccess)
        {
            
        }
        
    }];

}

-(void)sendRequestForUpdate
{
    ProgressIndicator * pi = [ProgressIndicator sharedInstance];
    [pi showPIOnView:self.view withMessage:@"updating.."];
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    
    if ([UserSettings currentSetting].sex) {
        [dictParam setObject:[UserSettings currentSetting].sex forKey:PARAM_ENT_SEX];
    }

    if ([UserSettings currentSetting].prSex) {
        [dictParam setObject:[UserSettings currentSetting].prSex forKey:PARAM_ENT_PREF_SEX];
    }

    if ([UserSettings currentSetting].prLAge) {
        [dictParam setObject:[UserSettings currentSetting].prLAge forKey:PARAM_ENT_PREF_LOWER_AGE];
    }
    
    if ([UserSettings currentSetting].prUAge) {
        if ([UserSettings currentSetting].prUAge.integerValue >= 58)
            [dictParam setObject:@"100" forKey:PARAM_ENT_PREF_UPPER_AGE];
        else
            [dictParam setObject:[UserSettings currentSetting].prUAge forKey:PARAM_ENT_PREF_UPPER_AGE];
    }
    if ([UserSettings currentSetting].prRad) {
            [dictParam setObject:[UserSettings currentSetting].prRad forKey:PARAM_ENT_PREF_RADIUS];
    }
    
    if ([UserSettings currentSetting].prDiscovery) {
        [dictParam setObject:[UserSettings currentSetting].prDiscovery forKey:@"ent_pref_discovery"];
    }
    
    for(id key in dictParam)
        
        NSLog(@"key=%@ value=%@", key, [dictParam objectForKey:key]);
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    
    [afn getDataFromPath:METHOD_UPDATEPREFERENCES withParamData:dictParam withBlock:^(id response, NSError *error) {
        
        [pi hideProgressIndicator];
        
        if (response)
            
        {
            
            if ([[response objectForKey:@"errFlag"] intValue]==0) {
                
                [[TinderAppDelegate sharedAppDelegate]showToastMessage:[response objectForKey:@"errMsg"]];
                
            }else{
                
                [[TinderAppDelegate sharedAppDelegate]showToastMessage:[response objectForKey:@"errMsg"]];
                
            }
            
            //[self settingResponse:response];
            
        }
        
        else{
            
            [[TinderAppDelegate sharedAppDelegate]showToastMessage:@"Failed to update, try again."];
            
        }
    }];
    
}


/*
-(void)settingResponse:(NSDictionary*)_response
{
    
    ProgressIndicator * pi = [ProgressIndicator sharedInstance];
    if (_response == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Connection Timeout." delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil, nil];
        alert.tag = 400;
        [alert show];
    }
    else{
        if (_response != nil) {
            NSDictionary *dict = [_response objectForKey:@"ItemsList"];
            if (!dict) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Connection Timeout." delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil, nil];
                [alert show];     
                [pi hideProgressIndicator];
            }
            else{
                if ([[dict objectForKey:@"errFlag"]intValue]==0 && [[dict objectForKey:@"errNum"]intValue]==13) {
                    [pi showMessage:[dict objectForKey:@"errMsg"] On:self.view];
                }
                else if ([[dict objectForKey:@"errFlag"]intValue]==1 && [[dict objectForKey:@"errNum"]intValue]==14){
                    [pi showMessage:[dict objectForKey:@"errMsg"] On:self.view];
                }
                else if ([[dict objectForKey:@"errFlag"]intValue]==1 && [[dict objectForKey:@"errNum"]intValue]==14)
                {
                    [pi showMessage:[dict objectForKey:@"errMsg"] On:self.view];
                }
                else{
                    [pi showMessage:[dict objectForKey:@"errMsg"] On:self.view];
                }
                [pi hideProgressIndicator];
            }
        }
    }
}
*/

- (IBAction)discovrySwitched:(UISwitch *)sender
{
    if (sender.selected) {
        sender.on = NO;
        sender.selected = NO;
        [UserSettings currentSetting].prDiscovery=@"0";
    }
    else
    {
        sender.on = YES;
        sender.selected = YES;
        [UserSettings currentSetting].prDiscovery=@"1";
    }
}

- (IBAction)btnGenderTapped:(UIButton *)sender
{
    UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                  @"Only Men",
                                  @"Only Women",
                                  @"Men and Women",
                                  nil];
    actionsheet.tag = 1;
    [actionsheet showInView:[UIApplication sharedApplication].keyWindow];
}


#pragma mark -- action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionsheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionsheet.tag == 1 && ![[actionsheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"])
    {
        [_btnGenderOutlet setTitle:[actionsheet buttonTitleAtIndex:buttonIndex] forState:UIControlStateNormal];
        prefGender = [NSString stringWithFormat:@"%d",(int)buttonIndex+1];
        [UserSettings currentSetting].prSex = prefGender;
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
        
    }else {
        // use other methods for iOS 7 or older.
        for (UIView *subview in actionSheet.subviews) {
            if ([subview isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)subview;
                [button setTitleColor:ACTION_SHEET_COLOR forState:UIControlStateNormal];
            }
        }
    }
}

#pragma mark -
#pragma mark - Memory Mgmt
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end

