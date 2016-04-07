//
//  MenuViewController.m
//  Tinder
//
//  Created by Sanskar on 26/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "MenuViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>

#define HeightScrollView 152.0

@interface MenuViewController ()
{
  
    IBOutlet UILabel *lblFriendMsgCounter;
    AVAudioPlayer *player;
    
    IBOutlet UIScrollView *scrContainer;
    IBOutlet UIView *vwContainer;
    
    IBOutlet EGOImageView *imgProfilePic;
    IBOutlet EGOImageView *imgCoverPic;
    IBOutlet UILabel *lblUserName;
    IBOutlet UIButton *btnVwProfile;
    
    NSMutableArray *blurImages_;
    UIImage *coverImage;
}
@end

@implementation MenuViewController

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
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateFriendsWithMsgCounter:) name:@"updateFriendsWithMsgMessageCounter" object:nil];
    //sanket nagar for chat
    lblFriendMsgCounter.layer.cornerRadius = 7.0;
    lblFriendMsgCounter.layer.masksToBounds = YES;
    
    imgProfilePic.layer.borderWidth = 2.0;
    imgProfilePic.layer.borderColor = [UIColor whiteColor].CGColor;
    imgProfilePic.layer.cornerRadius = imgProfilePic.frame.size.width/2;
    imgProfilePic.layer.masksToBounds = YES;
    
    [scrContainer setContentSize:CGSizeMake(self.view.bounds.size.width, vwContainer.frame.size.height)];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(menuScreenRefresh) name:NOTIFICATION_MENUSCREEN_REFRESH object:nil];
    
    [Helper setToLabel:lblUserName Text:[[User currentUser]first_name] WithFont:HELVETICALTSTD_ROMAN FSize:19 Color:WHITE_COLOR];
    
    [scrContainer setDelegate:self];
    blurImages_ = [[NSMutableArray alloc]init];
  
    [self setUserProfileData];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

//Notification To Refresh Screen
-(void)menuScreenRefresh
{
    [self setUserProfileData];
}

-(void)setUserProfileData
{
    if ([User currentUser].profile_pic!=nil)
    {
        [imgProfilePic setShowActivity:YES];
        [imgProfilePic setImageURL:[NSURL URLWithString:[User currentUser].profile_pic]];
    }
    
    /*
    NSString *strCoverPic = [USERDEFAULT objectForKey:@"fbUserCoverPic"];
    if ([strCoverPic length])
    {
        [imgCoverPic setImageURL:[NSURL URLWithString:[USERDEFAULT objectForKey:@"fbUserCoverPic"]]];
        [imgCoverPic setClipsToBounds:YES];
    }
    else
    {
        NSString *coverPic = [self getFbFriendsCoverPhotoForUserID:FBId];
        [USERDEFAULT setObject:coverPic forKey:@"fbUserCoverPic"];
      
        [imgCoverPic setImageURL:[NSURL URLWithString:[USERDEFAULT objectForKey:@"fbUserCoverPic"]]];
        [imgCoverPic setClipsToBounds:YES];
    }
    [imgCoverPic setShowActivity:YES];
     */
    
    coverImage = imgProfilePic.image;
    if (coverImage) {
        [self setImage:coverImage];
        [imgCoverPic setImage:[blurImages_ lastObject]];
    }
   
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
    NSString *strFBImageUrl=[[topDictionary valueForKey:@"cover"] valueForKey:@"source"];
    return strFBImageUrl;
}

- (NSString *)imageURLForCoverPhotoObject:(NSString *)FB_Id
{
    NSString *imageURL   =   [[NSString alloc] initWithFormat:@"http://graph.facebook.com/%@?fields=cover&access_token=%@",FB_Id,[[FBSession activeSession] accessTokenData]];
    
    return imageURL;
}

-(void)viewDidAppear:(BOOL)animated
{
   // [self updateFriendBadgeCounter:NO];
}

#pragma mark -Handling Notification For Messages

-(void)updateFriendsWithMsgCounter: (NSNotification *)_notificationObj
{
   // [self updateFriendBadgeCounter:YES];
}

-(void)updateFriendBadgeCounter: (BOOL)isNewMsgArrived
{
    
   /* NSArray *arrayFriendsWithMsgs = [[XmppFriendHandler sharedInstance]getFriendsWithPendingMsgs];
    
    
    int countForFriendWithMsgsPending = 0;
    
     for (XmppFriend *obj in arrayFriendsWithMsgs )
     {
        countForFriendWithMsgsPending  = (int)(countForFriendWithMsgsPending + [obj.messageCount intValue]);
     }
    
   // countForFriendWithMsgsPending = (int)[arrayFriendsWithMsgs count];
    
    if (countForFriendWithMsgsPending)
    {
        [lblFriendMsgCounter setText:[NSString stringWithFormat:@"%d",countForFriendWithMsgsPending]];
        
        CGRect rect = lblFriendMsgCounter.frame;
        CGFloat width = [self getWidthOfString:[NSString stringWithFormat:@"%d",countForFriendWithMsgsPending] forSize:CGSizeMake(233, 1000.0f)];
        if (width<19)
        {
            rect.size.width = width+7;
        }
        else
        {
            rect.size.width = 26;
        }
        [lblFriendMsgCounter setFrame:rect];
        
        [lblFriendMsgCounter setHidden:NO];
      
        if(isNewMsgArrived)
        {
            [self playSoundForNotification];
        }
        
    }
    else
    {
        [lblFriendMsgCounter setHidden:YES];
    }*/
    
 }

- (CGFloat) getWidthOfString: (NSString *) string forSize: (CGSize) size
{
    CGSize stringSize = [string sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    return stringSize.width;
}

-(void)playSoundForNotification
{
    NSString *path;
    
    NSURL *url;
    
    path =[[NSBundle mainBundle] pathForResource:@"sms-received" ofType:@"wav"];
    
    url = [NSURL fileURLWithPath:path];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
    [player setVolume:1.0];
    [player play];
}

#pragma  mark -
#pragma  mark - Button Action Method

-(IBAction)btnAction:(id)sender
{
    UIButton * btn =(UIButton*)sender;
    switch (btn.tag)
    {
        case PROFILE:{
        
            ProfileVC *vc=[[ProfileVC alloc]initWithNibName:@"ProfileVC" bundle:nil];
            UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:vc];
            [self presentViewController:n animated:YES completion:^{
            }];
            break;
        }
        case HOME:
        {
            NSDictionary *dictInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:TagHomeView] forKey:KeyForScreenNavigation];
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_SCREEN_NAVIGATION_BUTTON_CLICKED object:nil userInfo:dictInfo];
            
            break;
        }
        case DISCOVERY_PREFERENCE:
        {
            SettingsViewController *settingVC= [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
            [self presentViewController:settingVC animated:YES completion:^{
            }];
            break;
        }
        case APP_SETTINGS:
        {
            AppSettingsViewController *settingVC= [[AppSettingsViewController alloc] initWithNibName:@"AppSettingsViewController" bundle:nil];
            [self presentViewController:settingVC animated:YES completion:^{
            }];
            break;
            
        }
        case INVITE:{
            [self showActionSheet];
            break;
        }
        case QUESTION:{
//            QuestionVC *vcQue=[[QuestionVC alloc]initWithNibName:@"QuestionVC" bundle:nil];
//            [self presentViewController:vcQue animated:YES completion:^{
//            }];
            break;
        }
       
        default:
            break;
    }
}

-(void)showActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Invite" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Mail ",@"Message",nil];
    actionSheet.tag = 200;
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

#pragma mark - ActionSheet Delegate

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
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

-(void) actionSheet:(UIActionSheet *)actSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actSheet.tag == 200)
    {
        if(buttonIndex == 0){
            [super sendMailSubject:@"Flamer Pro App!" toRecipents:[NSArray arrayWithObject:@""] withMessage:@"I am using Flamer Pro App ! Whay don't you try it out…<br/>Install Flamer now !<br/><b>Google Play :-</b> <a href='https://play.google.com/store/apps/details?id=com.appdupe.flamernofb'>https://play.google.com/store/apps/details?id=com.appdupe.flamernofb</a><br/><b>iTunes :-</b>"];
        }
        else if(buttonIndex == 1){
            [super sendMessage:@"I am using Flamer Pro App ! Whay don't you try it out…\nInstall TinderClone now !\nGoogle Play :- https://play.google.com/store/apps/details?id=com.appdupe.flamernofb\niTunes :-"];
        }
    }
}

- (void)setImage:(UIImage *)image
{
    [blurImages_ removeAllObjects];
    [self prepareForBlurImages];
}

- (void)prepareForBlurImages
{
    CGFloat factor = 0.1;
    [blurImages_ addObject:coverImage];
    for (NSUInteger i = 0; i < 20; i++) {
        [blurImages_ addObject:[coverImage boxblurImageWithBlur:factor]];
        factor+=0.04;
    }
}

#pragma mark - UIScrollView delegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat yPos = -scrContainer.contentOffset.y;
    
    if (yPos > 0)
    {
        CGRect imgRect = imgCoverPic.frame;
        imgRect.origin.y = scrContainer.contentOffset.y;
        imgRect.size.height = HeightScrollView+yPos;
        imgCoverPic.frame = imgRect;
        
        NSInteger index = blurImages_.count * 8 /yPos - 1;
        
        if (index < 0) {
            index = 0;
        }
        else if(index >= blurImages_.count) {
            index = blurImages_.count - 1;
        }
        
        NSLog(@"Index %d yPos %f",index,yPos);
        
        UIImage *image = blurImages_[index];
        [imgCoverPic setImage:image];
        
        if (index>0)
        {
            [imgProfilePic setAlpha:index/10.0];
            [lblUserName setAlpha:index/10.0];
            [btnVwProfile setAlpha:index/10.0];
        }
        else
        {
            [imgProfilePic setAlpha:0.0];
            [lblUserName setAlpha:0.0];
            [btnVwProfile setAlpha:0.0];
        }
        if (yPos>120.0) {
            [self showProfileScreenAnimately];
        }
    }
    else
    {
        UIImage *image = [blurImages_ lastObject];
        [imgCoverPic setImage:image];
        [imgProfilePic setAlpha:1.0];
        [lblUserName setAlpha:1.0];
        [btnVwProfile setAlpha:1.0];
    }

}

-(void)showProfileScreenAnimately
{
    ProfileVC *vc=[[ProfileVC alloc]initWithNibName:@"ProfileVC" bundle:nil];
    UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:n animated:NO completion:^{
    }];
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end;


@implementation UIImage (Blur)

-(UIImage *)boxblurImageWithBlur:(CGFloat)blur {

    NSData *imageData = UIImageJPEGRepresentation(self, 1); // convert to jpeg
    UIImage* destImage = [UIImage imageWithData:imageData];
    
    
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = destImage.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    
    vImage_Error error;
    
    void *pixelBuffer;
    
    
    //create vImage_Buffer with data from CGImageRef
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    // Create a third buffer for intermediate processing
    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    vImage_Buffer outBuffer2;
    outBuffer2.data = pixelBuffer2;
    outBuffer2.width = CGImageGetWidth(img);
    outBuffer2.height = CGImageGetHeight(img);
    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
    
    //perform convolution
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    free(pixelBuffer2);
    CFRelease(inBitmapData);
    
    CGImageRelease(imageRef);
    
    return returnImage;
}

@end
